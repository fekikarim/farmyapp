import 'land_model.dart';

enum PaymentStatus { pending, paid, overdue, cancelled }

class LandRental {
  final String id;
  final String landId;
  final String investorId;
  final DateTime rentalStartDate;
  final DateTime? rentalEndDate;
  final double monthlyRent;
  final PaymentStatus paymentStatus;
  final DateTime paymentDueDate;
  final DateTime? paymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Land? land;

  LandRental({
    required this.id,
    required this.landId,
    required this.investorId,
    required this.rentalStartDate,
    this.rentalEndDate,
    required this.monthlyRent,
    this.paymentStatus = PaymentStatus.pending,
    required this.paymentDueDate,
    this.paymentDate,
    this.createdAt,
    this.updatedAt,
    this.land,
  });

  factory LandRental.fromJson(Map<String, dynamic> json) {
    return LandRental(
      id: json['id'],
      landId: json['land_id'],
      investorId: json['investor_id'],
      rentalStartDate: DateTime.parse(json['rental_start_date']),
      rentalEndDate: json['rental_end_date'] != null
          ? DateTime.parse(json['rental_end_date'])
          : null,
      monthlyRent: double.parse(json['monthly_rent'].toString()),
      paymentStatus: _parsePaymentStatus(json['payment_status']),
      paymentDueDate: DateTime.parse(json['payment_due_date']),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      land: json['land'] != null ? Land.fromJson(json['land']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'land_id': landId,
      'investor_id': investorId,
      'rental_start_date': rentalStartDate.toIso8601String(),
      'rental_end_date': rentalEndDate?.toIso8601String(),
      'monthly_rent': monthlyRent,
      'payment_status': paymentStatus.name,
      'payment_due_date': paymentDueDate.toIso8601String(),
      'payment_date': paymentDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'land': land?.toJson(),
    };
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'overdue':
        return PaymentStatus.overdue;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}
