import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/app_theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/suggestion_card.dart';
import '../chat/chat_screen.dart';
import '../history/history_screen.dart';
import 'suggestion_model.dart';
import 'suggestion_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      ref.read(suggestionProvider.notifier).fetchSuggestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suggestionProvider);
    final theme = Theme.of(context);
    final showFooter = state.isLoadingMore || !state.hasNextPage;

    return Scaffold(
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () => ref.read(suggestionProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: _HeroHeader(
                onHistoryTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            if (state.isInitialLoading && state.isEmpty)
              SliverToBoxAdapter(child: _buildShimmer(theme.brightness))
            else if (state.errorMessage != null && state.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _HomeFeedbackState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Suggestions are unavailable',
                  description: state.errorMessage!,
                  actionLabel: 'Try again',
                  onPressed: () =>
                      ref.read(suggestionProvider.notifier).refresh(),
                ),
              )
            else if (state.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _HomeFeedbackState(
                  icon: Icons.inbox_outlined,
                  title: 'Nothing to show yet',
                  description: 'Pull to refresh and load assistant suggestions.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= state.suggestions.length) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 32,
                        ),
                        child: Center(
                          child: state.isLoadingMore
                              ? const AppLoadingIndicator()
                              : Text(
                                  'You are all caught up.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      );
                    }

                    final suggestion = state.suggestions[index];
                    return SuggestionCard(
                      suggestion: suggestion,
                      onTap: () => _openChat(context, suggestion),
                    );
                  },
                  childCount: state.suggestions.length + (showFooter ? 1 : 0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, Suggestion suggestion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(initialSuggestion: suggestion),
      ),
    );
  }

  Widget _buildShimmer(Brightness brightness) {
    final baseColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.shade300;
    final highlightColor = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 102,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.onHistoryTap});

  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.28),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Smart Assistant',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.16),
                      child: InkWell(
                        onTap: onHistoryTap,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Hello',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a suggestion to start a natural assistant conversation, or keep scrolling for more prompts.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFeedbackState extends StatelessWidget {
  const _HomeFeedbackState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 42,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
