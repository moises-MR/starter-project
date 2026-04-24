import 'dart:io';

import 'package:news_app_clean_architecture/features/firebase_articles/data/data_sources/firestore_article_data_source.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/data_sources/storage_data_source.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/models/firebase_article_model.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';

class FirebaseArticleRepositoryImpl implements FirebaseArticleRepository {
  final FirestoreArticleDataSource _firestoreDataSource;
  final StorageDataSource _storageDataSource;

  FirebaseArticleRepositoryImpl(
    this._firestoreDataSource,
    this._storageDataSource,
  );

  @override
  Future<List<ArticleEntity>> getArticles() async {
    final models = await _firestoreDataSource.getArticles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> createArticle(CreateArticleParams params) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${timestamp}_${params.authorId}.jpg';

    final thumbnailURL = await _storageDataSource.uploadArticleThumbnail(
      fileName,
      File(params.thumbnailPath),
    );

    final model = FirebaseArticleModel(
      documentId: '',
      author: params.author,
      authorId: params.authorId,
      title: params.title,
      urlToImage: thumbnailURL,
      publishedAt: DateTime.now().toIso8601String(),
      content: params.content,
    );

    await _firestoreDataSource.createArticle(model.toFirestore());
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    await _firestoreDataSource.deleteArticle(articleId);
  }
}
