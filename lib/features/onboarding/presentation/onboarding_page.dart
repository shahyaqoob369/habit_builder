import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/features/onboarding/data/onboarding_repository.dart';
import 'package:habit_builder/features/onboarding/domain/onboarding_slide.dart';
import 'package:habit_builder/features/onboarding/presentation/widgets/onboarding_controls.dart';
import 'package:habit_builder/features/onboarding/presentation/widgets/onboarding_slide_view.dart';

/// Onboarding (Figma "Introduction 1–4"): four swipeable pages with fixed
/// bottom controls.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  /// Gaps from the design: subtitle → controls (49) and controls → bottom
  /// safe area (54).
  static const _controlsTop = 49.0;
  static const _controlsBottom = 54.0;

  static const List<OnboardingSlide> _slides = OnboardingSlide.values;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    unawaited(
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _previous() {
    unawaited(
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingRepositoryProvider).complete();
    if (!mounted) return;
    // Becomes the sign-up screen in plan step 4.
    context.goNamed(AppRoute.designSystem.name);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Android back steps through the pages before leaving the app.
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _previous();
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) =>
                      OnboardingSlideView(slide: _slides[index]),
                ),
              ),
              const SizedBox(height: _controlsTop),
              OnboardingControls(
                pageCount: _slides.length,
                pageIndex: _page,
                onSkip: _finish,
                onNext: _next,
                onGetStarted: _finish,
              ),
              const SizedBox(height: _controlsBottom),
            ],
          ),
        ),
      ),
    );
  }
}
