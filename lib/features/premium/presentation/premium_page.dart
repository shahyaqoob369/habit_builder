import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/config/app_config.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/links/link_launcher.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/app_icon.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/core/widgets/state_views.dart';
import 'package:habit_builder/features/community/application/community_providers.dart';
import 'package:habit_builder/features/premium/application/premium_providers.dart';
import 'package:habit_builder/features/premium/data/fake_premium_repository.dart';
import 'package:habit_builder/features/premium/domain/premium.dart';
import 'package:habit_builder/features/premium/presentation/widgets/offer_card.dart';
import 'package:habit_builder/features/premium/presentation/widgets/plan_card.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Premium (Figma "Subscription Page"): the offer, what Premium unlocks,
/// the three plans, Subscribe Now, Restore Purchase and the legal links.
class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  String? _selectedId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _log(const AnalyticsEvent.paywallShown());
  }

  // Read up front: a purchase can finish after the page has closed.
  late final Analytics _analytics = ref.read(analyticsProvider);

  void _log(AnalyticsEvent event) => unawaited(_analytics.logEvent(event));

  Future<void> _run(
    Future<void> Function() action,
    String success,
    AnalyticsEvent event,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await action();
      _log(event);
      messenger.showSnackBar(SnackBar(content: Text(success)));
      if (mounted) context.pop();
    } on PurchaseException catch (e) {
      final message = switch (e.failure) {
        PurchaseFailure.cancelled => null,
        PurchaseFailure.nothingToRestore => l10n.premiumNothingToRestore,
        PurchaseFailure.unknown => l10n.premiumFailed,
      };
      if (message != null) {
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openLink(String url) {
    unawaited(ref.read(openLinkProvider)(Uri.parse(url)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offering = ref.watch(offeringProvider);
    final isPremium = ref.watch(isPremiumProvider).value ?? false;
    final repository = ref.read(premiumRepositoryProvider);

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: l10n.premiumTitle,
            leading: HeaderIconButton(
              icon: AppIcons.back,
              tooltip: l10n.backTooltip,
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: switch (offering) {
              AsyncValue(value: final offer?) => _Content(
                offering: offer,
                selectedId:
                    _selectedId ??
                    offer.plans
                        .firstWhere(
                          (p) => p.isMostPopular,
                          orElse: () => offer.plans.first,
                        )
                        .id,
                busy: _busy,
                isPremium: isPremium,
                clock: ref.watch(clockProvider),
                onSelect: (id) => setState(() => _selectedId = id),
                onSubscribe: (plan) => unawaited(
                  _run(
                    () => repository.purchase(plan),
                    l10n.premiumWelcome,
                    AnalyticsEvent.premiumPurchase(plan.id),
                  ),
                ),
                onRestore: () => unawaited(
                  _run(
                    repository.restore,
                    l10n.premiumRestored,
                    const AnalyticsEvent.premiumRestore(),
                  ),
                ),
                onTerms: () => _openLink(AppConfig.termsUrl),
                onPrivacy: () => _openLink(AppConfig.privacyPolicyUrl),
              ),
              AsyncValue(hasError: true) => MessageView.error(
                context,
                onRetry: () => ref.invalidate(offeringProvider),
              ),
              _ => const LoadingView(),
            },
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.offering,
    required this.selectedId,
    required this.busy,
    required this.isPremium,
    required this.clock,
    required this.onSelect,
    required this.onSubscribe,
    required this.onRestore,
    required this.onTerms,
    required this.onPrivacy,
  });

  final PremiumOffering offering;
  final String selectedId;
  final bool busy;
  final bool isPremium;
  final DateTime Function() clock;
  final ValueChanged<String> onSelect;
  final ValueChanged<PremiumPlan> onSubscribe;
  final VoidCallback onRestore;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final selected = offering.plans.firstWhere((p) => p.id == selectedId);
    final discount = offering.discountPercent;
    final expiresAt = offering.expiresAt;
    final store = defaultTargetPlatform == TargetPlatform.android
        ? l10n.premiumStoreGoogle
        : l10n.premiumStoreApple;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppHeader.bottomGap + 18,
        AppSpacing.screen,
        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      children: [
        if (discount != null && expiresAt != null) ...[
          OfferCard(
            discountPercent: discount,
            expiresAt: expiresAt,
            clock: clock,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        _Benefits(
          title: l10n.premiumUnlock,
          items: [
            l10n.premiumUnlimitedHabits,
            l10n.premiumAllCourses,
            l10n.premiumAllAvatars,
          ],
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            for (final plan in offering.plans)
              Expanded(
                child: PlanCard(
                  plan: plan,
                  selected: plan.id == selectedId,
                  onTap: () => onSelect(plan.id),
                ),
              ),
          ],
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: isPremium ? l10n.premiumActive : l10n.premiumSubscribe,
          isLoading: busy,
          onPressed: isPremium ? null : () => onSubscribe(selected),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 7,
          children: [
            AppIcon(AppIcons.shield, color: colors.textPrimary),
            Flexible(
              child: Text(
                l10n.premiumSecured(store),
                style: AppTextStyles.captionStrong.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Center(
          child: TextButton(
            onPressed: busy ? null : onRestore,
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              textStyle: AppTextStyles.legal,
            ),
            child: Text(l10n.premiumRestore),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Link(label: l10n.premiumTerms, onTap: onTerms),
            Text(
              l10n.premiumAnd,
              style: AppTextStyles.legal.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.textMuted,
              ),
            ),
            _Link(label: l10n.settingsPrivacy, onTap: onPrivacy),
          ],
        ),
      ],
    );
  }
}

/// "Unlock Monumental Habits" with its checklist (Figma "Benefits").
class _Benefits extends StatelessWidget {
  const _Benefits({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                title,
                style: AppTextStyles.cardHeading.copyWith(height: 1),
              ),
            ),
          ),
          for (final item in items) ...[
            const Divider(),
            SizedBox(
              height: 45,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  spacing: 20,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                      ),
                      child: AppIcon(
                        AppIcons.check,
                        color: colors.textPrimary,
                      ),
                    ),
                    Expanded(child: Text(item, style: AppTextStyles.body)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: context.colors.textPrimary,
        textStyle: AppTextStyles.legal.copyWith(
          decoration: TextDecoration.underline,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size(0, 36),
      ),
      child: Text(label),
    );
  }
}
