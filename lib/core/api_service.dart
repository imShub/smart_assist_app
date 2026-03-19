import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

/// Simulates backend APIs for the assignment.
///
/// Every method uses `Future.delayed` so the UI behaves as if it is talking to
/// a real server, while still returning deterministic dummy data in the
/// expected response shape.
class ApiService {
  static const int _pageSize = 6;

  static const List<Map<String, dynamic>> _allSuggestions = [
    {
      'id': 1,
      'title': 'Summarize my notes',
      'description': 'Turn long study notes into a short, readable summary.',
    },
    {
      'id': 2,
      'title': 'Write a polite email reply',
      'description': 'Draft a professional response with a friendly tone.',
    },
    {
      'id': 3,
      'title': 'Plan my day',
      'description': 'Organize tasks into a realistic and focused schedule.',
    },
    {
      'id': 4,
      'title': 'Brainstorm presentation ideas',
      'description': 'Generate clear talking points for a quick presentation.',
    },
    {
      'id': 5,
      'title': 'Simplify a complex topic',
      'description': 'Explain something technical in plain, simple language.',
    },
    {
      'id': 6,
      'title': 'Create interview questions',
      'description': 'Prepare useful questions for a practice interview round.',
    },
    {
      'id': 7,
      'title': 'Review my to-do list',
      'description': 'Prioritize tasks and highlight what matters most first.',
    },
    {
      'id': 8,
      'title': 'Turn ideas into action steps',
      'description': 'Break a rough idea into practical next steps.',
    },
    {
      'id': 9,
      'title': 'Draft social post captions',
      'description': 'Write concise captions with a clean, modern tone.',
    },
    {
      'id': 10,
      'title': 'Prepare meeting notes',
      'description': 'Convert raw notes into a structured summary.',
    },
    {
      'id': 11,
      'title': 'Improve this message',
      'description': 'Make a message clearer, warmer, and more effective.',
    },
    {
      'id': 12,
      'title': 'Make a study checklist',
      'description': 'Create a simple checklist for exam preparation.',
    },
    {
      'id': 13,
      'title': 'Outline a project proposal',
      'description': 'Build a neat structure for a short proposal document.',
    },
    {
      'id': 14,
      'title': 'Explain pros and cons',
      'description': 'Compare options in a balanced and easy way.',
    },
    {
      'id': 15,
      'title': 'Generate follow-up questions',
      'description': 'Suggest smart follow-up prompts to continue the task.',
    },
  ];

  Future<Map<String, dynamic>> getSuggestions({
    int page = 1,
    int limit = _pageSize,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final startIndex = (page - 1) * limit;
    final endIndex = min(startIndex + limit, _allSuggestions.length);
    final data = startIndex >= _allSuggestions.length
        ? <Map<String, dynamic>>[]
        : _allSuggestions.sublist(startIndex, endIndex);
    final totalPages = (_allSuggestions.length / limit).ceil();

    return {
      'status': 'success',
      'data': data,
      'pagination': {
        'current_page': page,
        'total_pages': totalPages,
        'total_items': _allSuggestions.length,
        'limit': limit,
        'has_next': page < totalPages,
        'has_previous': page > 1,
      },
    };
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final normalizedMessage = message.trim().toLowerCase();
    String reply;

    if (normalizedMessage.contains('summarize')) {
      reply =
          'Absolutely. Start by pulling out the main idea, then group supporting points into two or three short bullets. If you share the notes, I can turn them into a compact summary.';
    } else if (normalizedMessage.contains('email')) {
      reply =
          'Here is a clean starting point: thank them for the message, answer the main point directly, and close with a clear next step. I can also rewrite it to sound more formal or more friendly.';
    } else if (normalizedMessage.contains('plan') ||
        normalizedMessage.contains('schedule')) {
      reply =
          'A strong plan starts with the top priority, then two supporting tasks, then buffer time. If you want, I can turn your tasks into a realistic schedule for today.';
    } else {
      reply =
          'I can help with that. Share a little more context and I will turn it into something clear, structured, and useful right away.';
    }

    return {
      'status': 'success',
      'reply': reply,
    };
  }

  Future<Map<String, dynamic>> getChatHistory() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'status': 'success',
      'data': [
        {
          'sender': 'user',
          'message': 'Can you help me summarize my meeting notes?',
        },
        {
          'sender': 'assistant',
          'message':
              'Sure. Send the notes and I will convert them into key decisions, action items, and follow-ups.',
        },
        {
          'sender': 'user',
          'message': 'I also need a short email update for the team.',
        },
        {
          'sender': 'assistant',
          'message':
              'I can draft that too. A concise update with progress, blockers, and next steps usually works well.',
        },
      ],
    };
  }
}
