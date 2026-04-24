import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';

class CreateArticleUseCase implements UseCase<void, CreateArticleParams> {
  final FirebaseArticleRepository _repository;

  CreateArticleUseCase(this._repository);

  @override
  Future<void> call({CreateArticleParams? params}) {
    return _repository.createArticle(params!);
  }
}
