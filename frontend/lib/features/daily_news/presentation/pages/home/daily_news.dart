import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/utils/date_formatter.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_state.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/dimensions.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/featured_article_card.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return _DailyNewsView();
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
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFD6E4F0),
          child: Text(
            'U',
            style: TextStyle(
              color: const Color(0xFF2D2D54),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      centerTitle: false,
      title: Text(
        DateFormatter.format(DateTime.now().toIso8601String()),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () {
              //TODO: búsqueda
            },
            child: const Icon(
              Icons.search,
              color: Color(0xFF2D2D54),
              size: 30,
            ),
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
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: AppDimensions.screenPadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0, top: 12.0),
                child: Text(
                  'Breaking News',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Butler',
                    color: AppColors.titleDark,
                  ),
                ),
              ),
              FeaturedArticleCard(
                article: articles.first,
                onArticlePressed: (article) => Navigator.pushNamed(
                  context,
                  '/ArticleDetails',
                  arguments: article,
                ),
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = articles[index + 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ArticleWidget(
                    article: article,
                    onArticlePressed: (article) => Navigator.pushNamed(
                      context,
                      '/ArticleDetails',
                      arguments: article,
                    ),
                  ),
                );
              },
              childCount: articles.length - 1,
            ),
          ),
        ),
      ],
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
