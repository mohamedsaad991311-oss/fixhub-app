// lib/core/l10n/l10n_ext.dart
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
