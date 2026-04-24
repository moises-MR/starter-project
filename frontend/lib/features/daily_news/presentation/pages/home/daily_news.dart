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
import '../../../../../core/constants/dimensions.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../widgets/article_tile.dart';

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
    return Expanded(
      child: ListView.builder(
        padding: AppDimensions.screenPadding,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            final ArticleEntity article = articles[index];
            return Container(
              margin: EdgeInsets.only(
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      article.urlToImage!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        Text(
                          article.title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff312F5C),
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                article.urlToImage!,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              article.author ?? 'Unknown Author',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            Spacer(),
                            Text(
                              DateFormatter.format(
                                article.publishedAt!,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ArticleWidget(
              article: articles[index],
              onArticlePressed: (article) => Navigator.pushNamed(
                  context, '/ArticleDetails',
                  arguments: article),
            ),
          );
        },
      ),
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
