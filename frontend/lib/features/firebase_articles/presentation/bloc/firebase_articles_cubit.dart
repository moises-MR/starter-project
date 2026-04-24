import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/create_article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/delete_firebase_article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/get_firebase_articles.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_state.dart';
import '../../../../shared/article/domain/entities/article.dart';

class FirebaseArticlesCubit extends Cubit<FirebaseArticlesState> {
  final GetFirebaseArticlesUseCase _getFirebaseArticlesUseCase;
  final CreateArticleUseCase _createArticleUseCase;
  final DeleteFirebaseArticleUseCase _deleteFirebaseArticleUseCase;

  FirebaseArticlesCubit(
    this._getFirebaseArticlesUseCase,
    this._createArticleUseCase,
    this._deleteFirebaseArticleUseCase,
  ) : super(const FirebaseArticlesInitial());

  Future<void> getArticles() async {
    emit(const FirebaseArticlesLoading());
    try {
      final articles = await _getFirebaseArticlesUseCase();
      emit(FirebaseArticlesDone(articles));
    } catch (e) {
      emit(FirebaseArticlesError(e.toString()));
    }
  }

  Future<void> createArticle(CreateArticleParams params) async {
    final currentArticles = state is FirebaseArticlesDone
        ? (state as FirebaseArticlesDone).articles
        : <ArticleEntity>[];

    emit(const FirebaseArticlesLoading());
    try {
      final newArticle = await _createArticleUseCase(params: params);

      emit(const FirebaseArticleCreated());
      emit(FirebaseArticlesDone([newArticle, ...currentArticles]));
    } catch (e) {
      emit(FirebaseArticlesError(e.toString()));
    }
  }

  Future<void> deleteArticle(String articleId) async {
    emit(const FirebaseArticlesLoading());
    try {
      await _deleteFirebaseArticleUseCase(params: articleId);
      await getArticles();
    } catch (e) {
      emit(FirebaseArticlesError(e.toString()));
    }
  }
}
