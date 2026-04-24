import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_state.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/widgets/markdown_toolbar.dart';

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _thumbnailFile;
  bool _showPreview = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FirebaseArticlesCubit, FirebaseArticlesState>(
      listener: (context, state) {
        if (state is FirebaseArticleCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.black,
              content: Text('Article published successfully!'),
            ),
          );
          Navigator.pop(context);
        }
        if (state is FirebaseArticlesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red[700],
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _showPreview ? _buildPreview() : _buildEditor(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Ionicons.chevron_back, color: Colors.black),
      ),
      title: Text(
        _showPreview ? 'Preview' : 'New Article',
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _showPreview = !_showPreview),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              _showPreview ? Ionicons.create_outline : Ionicons.eye_outline,
              color: Colors.black,
            ),
          ),
        ),
        _buildPublishButton(),
      ],
    );
  }

  Widget _buildPublishButton() {
    return BlocBuilder<FirebaseArticlesCubit, FirebaseArticlesState>(
      builder: (context, state) {
        final isLoading = state is FirebaseArticlesLoading;

        return GestureDetector(
          onTap: isLoading ? null : _handlePublish,
          child: Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Publish',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnailPicker(),
          const SizedBox(height: 20),
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildContentLabel(),
          const SizedBox(height: 8),
          MarkdownToolbar(
            controller: _contentController,
            onImageTap: _pickThumbnail,
          ),
          const SizedBox(height: 8),
          _buildContentField(),
        ],
      ),
    );
  }

  Widget _buildThumbnailPicker() {
    return GestureDetector(
      onTap: _pickThumbnail,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          image: _thumbnailFile != null
              ? DecorationImage(
                  image: FileImage(_thumbnailFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _thumbnailFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Ionicons.image_outline,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add cover image',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        fontFamily: 'Butler',
      ),
      maxLines: null,
      decoration: const InputDecoration(
        hintText: 'Article title...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContentLabel() {
    return Text(
      'Content',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      maxLines: null,
      minLines: 12,
      style: const TextStyle(fontSize: 15, height: 1.6),
      decoration: InputDecoration(
        hintText: 'Write your article using markdown...\n\n'
            '## Use headings\n'
            '**Bold text** for emphasis\n'
            '- Bullet points for lists',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_thumbnailFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _thumbnailFile!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          if (_thumbnailFile != null) const SizedBox(height: 16),
          Text(
            _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFamily: 'Butler',
            ),
          ),
          const SizedBox(height: 16),
          MarkdownBody(
            data: _contentController.text.isEmpty
                ? '_No content yet_'
                : _contentController.text,
            styleSheet: MarkdownStyleSheet(
              h2: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              p: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickThumbnail() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _thumbnailFile = File(pickedFile.path));
    }
  }

  void _handlePublish() {
    final title = _titleController.text.trim();

    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text('Please fill in title and content'),
        ),
      );
      return;
    }

    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text('Please add a cover image'),
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return;

    context.read<FirebaseArticlesCubit>().createArticle(
          CreateArticleParams(
            title: title,
            content: content,
            author: authState.user.displayName ?? 'Unknown',
            authorId: authState.user.uid,
            thumbnailPath: _thumbnailFile!.path,
          ),
        );
  }
}
