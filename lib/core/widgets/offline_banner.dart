import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/connectivity/connectivity.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Shows a small note at the top of every screen while the device is
/// offline. Habits keep working (Firestore saves them locally) and sync
/// later; the note says so. Not in the design.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(onlineProvider).value == false;
    final colors = context.colors;
    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.paddingOf(context).top + 4,
          left: AppSpacing.screen,
          right: AppSpacing.screen,
          child: IgnorePointer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: offline
                  ? Center(
                      child: Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.textPrimary,
                            borderRadius: AppRadii.card,
                            boxShadow: AppShadows.small,
                          ),
                          child: Text(
                            context.l10n.offlineBanner,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: colors.surface,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
