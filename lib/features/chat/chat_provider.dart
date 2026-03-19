import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_service.dart';
import '../suggestions/suggestion_model.dart';
import 'chat_model.dart';

class ChatState {
  const ChatState({
    required this.messages,
    required this.isSending,
    required this.hasInitializedFromSuggestion,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final bool hasInitializedFromSuggestion;
  final String? errorMessage;

  factory ChatState.initial() {
    return const ChatState(
      messages: [],
      isSending: false,
      hasInitializedFromSuggestion: false,
      errorMessage: null,
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    bool? hasInitializedFromSuggestion,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      hasInitializedFromSuggestion:
          hasInitializedFromSuggestion ?? this.hasInitializedFromSuggestion,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._apiService) : super(ChatState.initial());

  final ApiService _apiService;

  Future<void> initializeFromSuggestion(Suggestion suggestion) async {
    if (state.hasInitializedFromSuggestion) {
      return;
    }

    state = state.copyWith(hasInitializedFromSuggestion: true);
    await sendMessage(_buildPromptFromSuggestion(suggestion));
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || state.isSending) {
      return;
    }

    final userMessage = ChatMessage(
      sender: MessageSender.user,
      message: trimmedText,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      clearError: true,
    );

    try {
      final response = await _apiService.sendMessage(trimmedText);
      final reply = ChatMessage(
        sender: MessageSender.assistant,
        message: response['reply'] as String,
      );

      state = state.copyWith(
        messages: [...state.messages, reply],
        isSending: false,
      );
    } catch (_) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'The assistant could not reply. Please try again.',
      );
    }
  }

  String _buildPromptFromSuggestion(Suggestion suggestion) {
    final title = suggestion.title.toLowerCase();
    if (title.contains('summarize')) {
      return 'Can you help me summarize my notes?';
    }
    if (title.contains('email')) {
      return 'Can you help me draft a polite email reply?';
    }
    if (title.contains('plan')) {
      return 'Can you help me plan my day?';
    }
    return 'Can you help me with ${suggestion.title.toLowerCase()}?';
  }
}

final chatProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>((ref, conversationId) {
  return ChatNotifier(ref.read(apiServiceProvider));
});
