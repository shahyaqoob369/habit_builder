import 'package:flutter/widgets.dart';
import 'package:habit_builder/l10n/gen/app_localizations.dart';

export 'package:habit_builder/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  /// Localized strings. Add new ones to `lib/l10n/arb/app_en.arb`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
