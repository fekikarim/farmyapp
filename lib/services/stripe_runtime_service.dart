import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeRuntimeException implements Exception {
  final String message;

  const StripeRuntimeException(this.message);

  @override
  String toString() => message;
}

class StripeRuntimeService {
  static const String _defaultUrlScheme = 'farmyapp';

  static Completer<void>? _configureCompleter;
  static Completer<void>? _paymentSheetFlowCompleter;
  static String? _activePublishableKey;

  static Future<void> bootstrap() async {
    // Always set the URL scheme early so redirect-based payment methods can return.
    Stripe.urlScheme = _defaultUrlScheme;

    final envPublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']?.trim();
    if (envPublishableKey != null && envPublishableKey.isNotEmpty) {
      await configure(publishableKey: envPublishableKey);
    }
  }

  static Future<void> configure({required String publishableKey}) async {
    final normalizedKey = publishableKey.trim();
    if (normalizedKey.isEmpty) {
      throw const StripeRuntimeException('Stripe publishable key is missing.');
    }

    if (_configureCompleter != null && !_configureCompleter!.isCompleted) {
      await _configureCompleter!.future;
      if (_activePublishableKey == normalizedKey) {
        return;
      }
    }

    if (_activePublishableKey == normalizedKey) {
      return;
    }

    final completer = Completer<void>();
    _configureCompleter = completer;

    try {
      Stripe.publishableKey = normalizedKey;
      Stripe.urlScheme = _defaultUrlScheme;

      final merchantIdentifier = dotenv.env['STRIPE_MERCHANT_IDENTIFIER']
          ?.trim();
      if (merchantIdentifier != null && merchantIdentifier.isNotEmpty) {
        Stripe.merchantIdentifier = merchantIdentifier;
      }

      await Stripe.instance.applySettings();
      _activePublishableKey = normalizedKey;
      completer.complete();
    } catch (error, stackTrace) {
      debugPrint('Stripe runtime configuration failed: $error');
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
      rethrow;
    } finally {
      if (identical(_configureCompleter, completer)) {
        _configureCompleter = null;
      }
    }
  }

  static Future<T> runSerializedPaymentSheet<T>(
    Future<T> Function() operation,
  ) async {
    while (_paymentSheetFlowCompleter != null &&
        !_paymentSheetFlowCompleter!.isCompleted) {
      await _paymentSheetFlowCompleter!.future;
    }

    final completer = Completer<void>();
    _paymentSheetFlowCompleter = completer;

    try {
      return await operation();
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }

      if (identical(_paymentSheetFlowCompleter, completer)) {
        _paymentSheetFlowCompleter = null;
      }
    }
  }
}
