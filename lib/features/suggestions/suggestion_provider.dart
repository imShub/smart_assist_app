import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_service.dart';
import 'suggestion_model.dart';

class SuggestionState {
  const SuggestionState({
    required this.suggestions,
    required this.currentPage,
    required this.hasNextPage,
    required this.isInitialLoading,
    required this.isLoadingMore,
    this.errorMessage,
  });

  final List<Suggestion> suggestions;
  final int currentPage;
  final bool hasNextPage;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get isEmpty => suggestions.isEmpty;

  factory SuggestionState.initial() {
    return const SuggestionState(
      suggestions: [],
      currentPage: 0,
      hasNextPage: true,
      isInitialLoading: false,
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  SuggestionState copyWith({
    List<Suggestion>? suggestions,
    int? currentPage,
    bool? hasNextPage,
    bool? isInitialLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SuggestionState(
      suggestions: suggestions ?? this.suggestions,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SuggestionNotifier extends StateNotifier<SuggestionState> {
  SuggestionNotifier(this._apiService) : super(SuggestionState.initial()) {
    fetchSuggestions();
  }

  final ApiService _apiService;

  Future<void> fetchSuggestions() async {
    if (state.isInitialLoading || state.isLoadingMore || !state.hasNextPage) {
      return;
    }

    final nextPage = state.currentPage + 1;
    final isFirstPage = nextPage == 1;

    state = state.copyWith(
      isInitialLoading: isFirstPage,
      isLoadingMore: !isFirstPage,
      clearError: true,
    );

    try {
      final response = await _apiService.getSuggestions(page: nextPage);
      final data = (response['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(Suggestion.fromJson)
          .toList();
      final pagination = response['pagination'] as Map<String, dynamic>;

      state = state.copyWith(
        suggestions: [...state.suggestions, ...data],
        currentPage: pagination['current_page'] as int,
        hasNextPage: pagination['has_next'] as bool,
        isInitialLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        errorMessage: 'Unable to load suggestions right now.',
      );
    }
  }

  Future<void> refresh() async {
    state = SuggestionState.initial().copyWith(isInitialLoading: true);

    try {
      final response = await _apiService.getSuggestions(page: 1);
      final data = (response['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(Suggestion.fromJson)
          .toList();
      final pagination = response['pagination'] as Map<String, dynamic>;

      state = state.copyWith(
        suggestions: data,
        currentPage: pagination['current_page'] as int,
        hasNextPage: pagination['has_next'] as bool,
        isInitialLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isInitialLoading: false,
        errorMessage: 'Unable to refresh suggestions.',
      );
    }
  }
}

final suggestionProvider =
    StateNotifierProvider<SuggestionNotifier, SuggestionState>((ref) {
  return SuggestionNotifier(ref.read(apiServiceProvider));
});
