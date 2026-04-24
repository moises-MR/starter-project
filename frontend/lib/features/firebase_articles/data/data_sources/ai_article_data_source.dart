import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/entities/generated_article.dart';
import 'package:path_provider/path_provider.dart';

class AiArticleDataSource {
  final GenerativeModel _textModel;
  final Dio _dio;
  final String _apiKey;

  AiArticleDataSource(String apiKey)
      : _apiKey = apiKey,
        _dio = Dio(),
        _textModel = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: Schema(
              SchemaType.object,
              requiredProperties: ['title', 'description', 'content'],
              properties: {
                'title': Schema(
                  SchemaType.string,
                  description: 'A compelling headline, max 100 characters',
                ),
                'description': Schema(
                  SchemaType.string,
                  description: 'A brief summary, max 200 characters',
                ),
                'content': Schema(
                  SchemaType.string,
                  description:
                      'Full article body, 3-5 well structured paragraphs',
                ),
              },
            ),
          ),
        );

  Future<GeneratedArticle> generateArticle(String prompt) async {
    final response = await _textModel.generateContent([
      Content.text(
        'You are a professional journalist. Based on the following prompt, '
        'generate a news article with a compelling title, brief description, '
        'and full content body. Always write in English regardless of the '
        'language of the prompt.\n\nPrompt: $prompt',
      ),
    ]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('AI returned empty response');
    }

    try {
      final Map<String, dynamic> json = jsonDecode(text);

      final title = json['title'];
      final description = json['description'];
      final content = json['content'];

      if (title == null || description == null || content == null) {
        throw Exception('AI response missing required fields');
      }

      return GeneratedArticle(
        title: title.toString(),
        description: description.toString(),
        content: content.toString(),
      );
    } on FormatException {
      throw Exception('AI returned invalid format');
    }
  }

  Future<File> generateArticleImage(String articleTitle) async {
    final response = await _dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.5-flash-image:generateContent',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
      ),
      data: {
        'contents': [
          {
            'parts': [
              {
                'text': 'Generate a professional, clean, modern editorial '
                    'photo that would work as a news article thumbnail. '
                    'The image should be relevant to this headline: '
                    '"$articleTitle". '
                    'Style: photojournalistic, high quality, no text overlay.'
              }
            ]
          }
        ],
        'generationConfig': {
          'responseModalities': ['IMAGE', 'TEXT'],
        },
      },
    );

    final candidates = response.data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('AI returned no image');
    }

    final parts = candidates[0]['content']['parts'] as List;
    final imagePart = parts.firstWhere(
      (part) => part['inlineData'] != null,
      orElse: () => throw Exception('No image in AI response'),
    );

    final base64Data = imagePart['inlineData']['data'] as String;
    final mimeType = imagePart['inlineData']['mimeType'] as String;

    final extension = mimeType.contains('png') ? 'png' : 'jpg';
    final Uint8List bytes = base64Decode(base64Data);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/ai_thumbnail_$timestamp.$extension');
    await file.writeAsBytes(bytes);

    return file;
  }
}
