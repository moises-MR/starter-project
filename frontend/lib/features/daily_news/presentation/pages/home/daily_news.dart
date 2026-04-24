import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_state.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FirebaseArticlesCubit>()..getArticles(),
      child: _DailyNewsView(),
    );
  }
}

class _DailyNewsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddArticleTapped(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/SavedArticles'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark, color: Colors.black),
          ),
        ),
        GestureDetector(
          onTap: () => context.read<AuthCubit>().signOut(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.logout, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, remoteState) {
        return BlocBuilder<FirebaseArticlesCubit, FirebaseArticlesState>(
          builder: (context, firebaseState) {
            final List<ArticleEntity> allArticles = [];

            // Add Firebase articles first (newest)
            if (firebaseState is FirebaseArticlesDone) {
              allArticles.addAll(firebaseState.articles);
            }

            // Add API articles
            if (remoteState is RemoteArticlesDone) {
              allArticles.addAll(remoteState.articles!);
            }

            // Both loading
            if (remoteState is RemoteArticlesLoading &&
                firebaseState is FirebaseArticlesLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            // Both failed and no articles
            if (allArticles.isEmpty) {
              if (remoteState is RemoteArticlesError ||
                  firebaseState is FirebaseArticlesError) {
                return const Center(child: Icon(Icons.refresh));
              }
              return const Center(child: CupertinoActivityIndicator());
            }

            return _buildArticlesList(context, allArticles);
          },
        );
      },
    );
  }

  Widget _buildArticlesList(
    BuildContext context,
    List<ArticleEntity> articles,
  ) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return ArticleWidget(
          article: articles[index],
          onArticlePressed: (article) => Navigator.pushNamed(
              context, '/ArticleDetails',
              arguments: article),
        );
      },
    );
  }

  void _onAddArticleTapped(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    if (authState is AuthSuccess && !authState.user.isAnonymous) {
      Navigator.pushNamed(context, '/AddArticle');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: const Text('Sign in to create articles'),
          action: SnackBarAction(
            label: 'Sign In',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/Welcome'),
          ),
        ),
      );
    }
  }
}
