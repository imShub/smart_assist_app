import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_service.dart';
import '../chat/chat_model.dart';

final historyProvider = FutureProvider.autoDispose<List<ChatMessage>>((ref) async {
  final response = await ref.read(apiServiceProvider).getChatHistory();
  final data = (response['data'] as List<dynamic>).cast<Map<String, dynamic>>();
  return data.map(ChatMessage.fromJson).toList();
});
