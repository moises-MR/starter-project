import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';

abstract class FirebaseArticleRepository {
  Future<List<ArticleEntity>> getArticles();

  Future<void> createArticle(CreateArticleParams params);

  Future<void> deleteArticle(String articleId);
}
