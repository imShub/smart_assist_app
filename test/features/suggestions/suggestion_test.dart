import 'package:flutter_test/flutter_test.dart';
import 'package:smart_assist_app/features/suggestions/suggestion_model.dart';

void main() {
  group('Suggestion Model Tests', () {
    test('fromJson should return a valid Suggestion object', () {
      final json = {
        "id": 1,
        "title": "Test Title",
        "description": "Test Description"
      };

      final suggestion = Suggestion.fromJson(json);

      expect(suggestion.id, 1);
      expect(suggestion.title, "Test Title");
      expect(suggestion.description, "Test Description");
    });
  });
}
