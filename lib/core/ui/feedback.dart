import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../features/menu/data/menu_repository.dart';
import '../../features/orders/data/orders_repository.dart';
import '../../features/tables/data/tables_repository.dart';
import '../../l10n/app_localizations.dart';

/// Turns a failure of a repository call into a message for the user.
String describeError(AppLocalizations l, Object error) {
  if (error is OrderException) {
    return switch (error.failure) {
      OrderFailure.emptyOrder => l.cartEmpty,
      OrderFailure.notFound => l.errOrderNotFound,
      OrderFailure.invalidTransition => l.errInvalidTransition,
      OrderFailure.itemUnavailable => l.errItemUnavailable(error.detail),
      OrderFailure.insufficientStock => l.errInsufficientStock(error.detail),
      OrderFailure.billNotReady => l.errBillNotReady,
      OrderFailure.nothingToPay => l.errNothingToPay,
    };
  }
  if (error is TableAlreadyExistsException) return l.errTableExists;
  if (error is CategoryInUseException) return l.errCategoryInUse;
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' => l.errPermissionDenied,
      'unavailable' || 'network-request-failed' => l.authNetworkError,
      _ => l.error(error.message ?? error.code),
    };
  }
  return l.error('$error');
}

void showMessage(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red[700] : null,
      behavior: SnackBarBehavior.floating,
    ));
}

/// Runs a write and reports the outcome in a snack bar. Returns whether the
/// action succeeded so callers can close dialogs or clear forms.
Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
}) async {
  // Resolved up front: the context may be gone once the write completes.
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l = AppLocalizations.of(context);
  try {
    await action();
    if (successMessage != null) {
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(successMessage),
          behavior: SnackBarBehavior.floating,
        ));
    }
    return true;
  } catch (error) {
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l == null ? '$error' : describeError(l, error)),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ));
    return false;
  }
}

/// Yes/no confirmation; resolves to false when dismissed.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final l = AppLocalizations.of(dialogContext);
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l?.no ?? ''),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l?.yes ?? ''),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

String formatMoney(AppLocalizations l, double amount) =>
    '${amount.toStringAsFixed(0)} ${l.som}';

/// Formats a stock or recipe quantity without a trailing ".0".
String formatQuantity(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(2);

String formatTime(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

/// Parses user-entered decimals, accepting a comma as the separator.
double? parseDecimal(String input) =>
    double.tryParse(input.trim().replaceAll(',', '.'));

extension L10nX on BuildContext {
  /// The app always installs [AppLocalizations.delegate], so this only
  /// throws on a wiring mistake (a MaterialApp without the delegate).
  AppLocalizations get l10n {
    final l = AppLocalizations.of(this);
    if (l == null) {
      throw FlutterError('AppLocalizations is not available in this context');
    }
    return l;
  }
}
