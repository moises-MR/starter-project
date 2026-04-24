import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/welcome_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/screens/add_article_screen.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_cubit.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
        );

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());

      case '/Welcome':
        return _materialRoute(const WelcomeScreen());

      case '/SignIn':
        return _materialRoute(const SignInScreen());

      case '/SignUp':
        return _materialRoute(const SignUpScreen());

      case '/AddArticle':
        return _materialRoute(
          BlocProvider(
            create: (_) => sl<FirebaseArticlesCubit>(),
            child: const AddArticleScreen(),
          ),
        );

      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
