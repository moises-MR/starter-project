import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/core/constants/colors.dart';

import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(
                  photoUrl: null,
                  name: user.displayName ?? 'Unknown',
                  email: user.email ?? '',
                ),
                const SizedBox(height: 24),
                _buildStatsCard(),
                const SizedBox(height: 28),
                _buildPublicationsSection(),
                const SizedBox(height: 28),
                _buildMenuItem(
                  icon: Ionicons.bookmark_outline,
                  label: 'My Bookmarks',
                  badge: '1',
                  onTap: () => _onShowSavedArticlesViewTapped(context),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Ionicons.log_out_outline,
                  label: 'Logout',
                  onTap: () => _onSignOutTapped(context),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSignOutTapped(BuildContext context) {
    Navigator.pop(context);
    context.read<AuthCubit>().signOut();
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Ionicons.arrow_back,
          color: AppColors.textPrimary,
        ),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required String? photoUrl,
    required String name,
    required String email,
  }) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.secondary.withOpacity(0.2),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? const Icon(
                    Ionicons.person,
                    size: 40,
                    color: AppColors.primary,
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.captionText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(count: '42', label: 'Saved Articles'),
            ),
            VerticalDivider(
              color: AppColors.divider,
              thickness: 1,
              width: 1,
            ),
            Expanded(
              child: _buildStatItem(count: '115', label: 'My Publications'),
            ),
            VerticalDivider(
              color: AppColors.divider,
              thickness: 1,
              width: 1,
            ),
            Expanded(
              child: _buildStatItem(count: '250', label: 'Reading History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String count, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.captionText,
          ),
        ),
      ],
    );
  }

  Widget _buildPublicationsSection() {
    // TODO: Replace with real data from a cubit/bloc
    final publications = [
      _PublicationItem(
        title: 'The Future of AI',
        date: 'Oct 26, 2023',
        imageUrl: 'https://picsum.photos/seed/ai/300/200',
      ),
      _PublicationItem(
        title: 'Climate Change Report',
        date: 'Oct 24, 2023',
        imageUrl: 'https://picsum.photos/seed/climate/300/200',
      ),
      _PublicationItem(
        title: 'Local Tech Boom',
        date: 'Oct 20, 2023',
        imageUrl: 'https://picsum.photos/seed/tech/300/200',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Publications',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: publications.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final pub = publications[index];
              return _buildPublicationCard(
                title: pub.title,
                date: pub.date,
                imageUrl: pub.imageUrl,
                onTap: () {
                  // TODO: Navigate to article detail
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPublicationCard({
    required String title,
    required String date,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 130,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 130,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Ionicons.image_outline,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.captionText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PublicationItem {
  final String title;
  final String date;
  final String imageUrl;

  _PublicationItem({
    required this.title,
    required this.date,
    required this.imageUrl,
  });
}
