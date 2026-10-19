import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/widgets/highlighted_text.dart';

void main() {
  group('HighlightedText', () {
    const orange = Color(0xFFFC9D45);

    HighlightedText build(String text, {bool uppercase = false}) =>
        HighlightedText(
          text,
          style: const TextStyle(),
          highlightColor: orange,
          uppercase: uppercase,
        );

    test('splits the text at <h> markers and colors the marked parts', () {
      final spans = build(
        'We can <h>help you</h> to be a better version of <h>yourself.</h>',
      ).spans();

      expect(spans.map((s) => s.text), [
        'We can ',
        'help you',
        ' to be a better version of ',
        'yourself.',
      ]);
      expect(spans.map((s) => s.style?.color), [null, orange, null, orange]);
    });

    test('uppercases every part when asked', () {
      final spans = build('a <h>b</h> c', uppercase: true).spans();

      expect(spans.map((s) => s.text), ['A ', 'B', ' C']);
    });

    test('plain text without markers stays one span', () {
      expect(build('Just text').spans().single.text, 'Just text');
    });
  });
}
