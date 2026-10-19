import 'package:flutter/material.dart';

/// Text with some words in another color, marked with `<h>…</h>` in the
/// string, for example `We can <h>help you</h> to be…`.
///
/// Keeping the markers in the localized string lets translators move the
/// highlighted words.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    required this.style,
    required this.highlightColor,
    this.textAlign,
    this.uppercase = false,
    super.key,
  });

  final String text;
  final TextStyle style;
  final Color highlightColor;
  final TextAlign? textAlign;

  /// Uppercases the text, as the design does for some styles.
  final bool uppercase;

  static final _tag = RegExp('<h>(.*?)</h>');

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(style: style, children: spans()),
      textAlign: textAlign,
    );
  }

  /// The parsed spans; highlighted ones carry [highlightColor].
  @visibleForTesting
  List<TextSpan> spans() {
    String format(String value) => uppercase ? value.toUpperCase() : value;
    final highlight = TextStyle(color: highlightColor);
    final result = <TextSpan>[];
    var start = 0;
    for (final match in _tag.allMatches(text)) {
      if (match.start > start) {
        result.add(TextSpan(text: format(text.substring(start, match.start))));
      }
      result.add(TextSpan(text: format(match[1]!), style: highlight));
      start = match.end;
    }
    if (start < text.length) {
      result.add(TextSpan(text: format(text.substring(start))));
    }
    return result;
  }
}
