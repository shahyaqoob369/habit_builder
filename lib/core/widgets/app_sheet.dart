import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';

/// Shows a bottom sheet in the design's style: white, 12 pt top corners,
/// over the dark scrim, covering the bottom bar.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final colors = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: colors.surface,
    barrierColor: colors.scrim,
    shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheet),
    clipBehavior: Clip.antiAlias,
    builder: builder,
  );
}
