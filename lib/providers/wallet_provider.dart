import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/auth_service.dart';

class PaymentMethod {
  final String id;
  final String type;
  final String last4;
  final String brand;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      last4: json['last4'] ?? '',
      brand: json['brand'] ?? '',
      expiryMonth: json['expiry_month'] ?? '',
      expiryYear: json['expiry_year'] ?? '',
      isDefault: json['is_default'] ?? false,
    );
  }
}

class WalletProvider with ChangeNotifier {
  double _credits = 0.0;
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;

  double get credits => _credits;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;

  Future<void> fetchWalletStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('${AuthService.baseUrl}/api/v1/wallet/me'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        _credits = double.parse(data['credits'].toString());
        _paymentMethods = (data['payment_methods'] as List)
            .map((e) => PaymentMethod.fromJson(e))
            .toList();
      } else {
        print('Failed to fetch wallet status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching wallet status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCard() async {
    try {
      // 1. Create SetupIntent on backend
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/v1/wallet/create-setup-intent'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create setup intent');
      }

      final data = jsonDecode(response.body)['data'];
      final clientSecret = data['setupIntent'];
      final ephemeralKey = data['ephemeralKey'];
      final customerId = data['customer'];
      final publishableKey = data['publishableKey'];

      Stripe.publishableKey = publishableKey;

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Farmy',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
          setupIntentClientSecret: clientSecret,
          style: ThemeMode.system,
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. If successful, refresh wallet status (backend webhook would normally handle this, 
      // but we can also optimistically refresh or manual trigger if needed, 
      // though SetupIntent confirmation is enough for Stripe to save card)
      await fetchWalletStatus(); 
      return true;

    } catch (e) {
      if (e is StripeException) {
        print('Stripe Error: ${e.error.localizedMessage}');
      } else {
        print('Error adding card: $e');
      }
      return false;
    }
  }

  Future<bool> chargeCredits(double amount) async {
    try {
      // 1. Create PaymentIntent on backend
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/v1/wallet/create-payment-intent'),
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent');
      }

      final data = jsonDecode(response.body)['data'];
      final clientSecret = data['paymentIntent'];
      final ephemeralKey = data['ephemeralKey'];
      final customerId = data['customer'];
      final publishableKey = data['publishableKey'];

      Stripe.publishableKey = publishableKey;

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Farmy',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.system,
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Create "Charge" on backend to update local credits (since we are not using webhooks for this simplified flow)
      // Ideally, backend verifies PaymentIntent status before crediting.
      // For now, we trust the client flow or assume backend verification happens in 'charge' endpoint if we were to send intent ID.
      // BUT current backend 'charge' is just a mock that takes amount. 
      // To properly link, we should call a confirm endpoint.
      // Let's call the existing "charge" endpoint as a "confirmation" that payment succeeded. 
      // NOTE: This is insecure for production (client can fake it), but fits the "mock" transition plan request.
      
      final chargeResponse = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/v1/wallet/charge'),
        body: jsonEncode({'amount': amount}),
      );

      if (chargeResponse.statusCode == 200) {
        await fetchWalletStatus(); // Refresh balance
        return true;
      }
      return false;

    } catch (e) {
      if (e is StripeException) {
         print('Stripe Payment Error: ${e.error.localizedMessage}');
      } else {
        print('Error charging credits: $e');
      }
      return false;
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    try {
      await AuthService.authenticatedRequest(
        'DELETE',
        Uri.parse('${AuthService.baseUrl}/api/v1/wallet/payment-methods/$id'),
      );
      await fetchWalletStatus();
    } catch (e) {
      print('Error deleting payment method: $e');
    }
  }
}
