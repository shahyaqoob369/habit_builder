import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Text field from the design (Figma "Input …"): 56 pt tall, radius 12, an
/// optional icon cell divided off by a hairline, bold orange input text.
///
/// The base look (fill, placeholder, error border) comes from the theme's
/// `inputDecorationTheme`. The icon turns orange while the field is focused
/// or filled, as in the design. [obscurable] fields get a Show/Hide toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.hintText,
    this.icon,
    this.controller,
    this.fillColor,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.obscurable = false,
    this.enabled = true,
    this.validator,
    this.onFieldSubmitted,
    super.key,
  });

  final String hintText;

  /// An `AppIcons` asset shown in the leading cell.
  final String? icon;

  final TextEditingController? controller;

  /// Defaults to `surface` (white); use `surfaceTinted` on a white card.
  final Color? fillColor;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  /// Hides the text, with a Show/Hide toggle (passwords).
  final bool obscurable;

  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();
  TextEditingController? _ownController;
  bool _obscured = true;
  bool _wasActive = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  bool get _isActive => _focusNode.hasFocus || _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onChanged);
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.controller ?? _ownController;
    if (old != _controller) {
      old?.removeListener(_onChanged);
      _controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _ownController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Rebuild only when the icon color would change.
  void _onChanged() {
    if (_isActive != _wasActive) setState(() => _wasActive = _isActive);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icon = widget.icon;
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscurable && _obscured,
      autocorrect: !widget.obscurable && widget.keyboardType == null,
      enableSuggestions: !widget.obscurable,
      style: AppTextStyles.button.copyWith(color: colors.primary),
      cursorHeight: 18,
      cursorWidth: 1.5,
      decoration: InputDecoration(
        hintText: widget.hintText,
        fillColor: widget.fillColor,
        prefixIcon: icon == null
            ? null
            : _IconCell(
                icon: icon,
                color: _isActive ? colors.primary : colors.textMuted,
              ),
        prefixIconConstraints: _IconCell.constraints,
        suffixIcon: widget.obscurable
            ? _VisibilityToggle(
                obscured: _obscured,
                onTap: () => setState(() => _obscured = !_obscured),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minHeight: 56),
      ),
    );
  }
}

/// The 49 pt icon cell and the hairline that closes it.
///
/// With a prefix icon, Material 3 ignores the content padding's start and
/// puts the text 4 pt after the icon; the 11 pt tail brings the text to the
/// design's 16 pt after the hairline.
class _IconCell extends StatelessWidget {
  const _IconCell({required this.icon, required this.color});

  static const constraints = BoxConstraints.tightFor(width: 61, height: 56);

  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 49,
          child: Center(child: AppIcon(icon, color: color)),
        ),
        VerticalDivider(width: 1, color: context.colors.divider),
        const SizedBox(width: 11),
      ],
    );
  }
}

/// "Show" / "Hide": underlined, 20 pt from the field's right edge.
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscured, required this.onTap});

  final bool obscured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: obscured ? l10n.fieldShowPassword : l10n.fieldHidePassword,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 20, 20, 20),
          child: Text(
            obscured ? l10n.fieldShow : l10n.fieldHide,
            style: AppTextStyles.label.copyWith(
              color: context.colors.textPrimary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
