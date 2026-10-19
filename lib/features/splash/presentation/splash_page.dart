import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_images.dart';
import 'package:habit_builder/features/onboarding/domain/onboarding_slide.dart';
import 'package:habit_builder/features/splash/application/splash_controller.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Splash (Figma "Splash Screen"): full-bleed illustration with the title.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  var _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode the onboarding illustrations while the splash is up, so the
    // first swipes are smooth.
    if (_precached) return;
    _precached = true;
    for (final slide in OnboardingSlide.values) {
      unawaited(precacheImage(AssetImage(slide.image), context));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(splashDestinationProvider, (_, next) {
      if (next case AsyncData(:final value)) context.goNamed(value.name);
    });
    return const Scaffold(body: _SplashView());
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  /// Figma frame size and title position.
  static const _frame = Size(414, 896);
  static const _titleTop = 96.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The background covers the screen like BoxFit.cover; place the
        // title at the same spot of the scaled artwork.
        final size = constraints.biggest;
        final scale = math.max(
          size.width / _frame.width,
          size.height / _frame.height,
        );
        final cropTop = (_frame.height * scale - size.height) / 2;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppImages.splashBackground,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            Positioned(
              top: _titleTop * scale - cropTop,
              left: AppSpacing.screen,
              right: AppSpacing.screen,
              child: Text(
                context.l10n.splashTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.displayLarge,
              ),
            ),
          ],
        );
      },
    );
  }
}
