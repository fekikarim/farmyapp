import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/land_provider.dart';
import '../../models/land_rental_model.dart';
import '../../widgets/subscription_limit_bar.dart';
import 'package:intl/intl.dart';

class InvestorMyInvestmentsScreen extends StatefulWidget {
  const InvestorMyInvestmentsScreen({super.key});

  @override
  State<InvestorMyInvestmentsScreen> createState() =>
      _InvestorMyInvestmentsScreenState();
}

class _InvestorMyInvestmentsScreenState
    extends State<InvestorMyInvestmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandProvider>().fetchMyRentals(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Investments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<LandProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myRentals.isEmpty) {
            return const Center(child: Text('No investments yet.'));
          }

          return Column(
            children: [
              // Subscription Limit Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SubscriptionLimitBar(
                  limitKey: 'rental_limit',
                  currentCount: provider.myRentals
                      .where(
                        (r) =>
                            r.paymentStatus != PaymentStatus.cancelled &&
                            (r.rentalEndDate == null ||
                                r.rentalEndDate!.isAfter(DateTime.now())),
                      )
                      .length,
                  label: 'Rental Slots Used',
                  icon: Icons.real_estate_agent_rounded,
                  accentColor: Colors.blue,
                  upgradePlanName: 'Investor Plus',
                ),
              ),
              _buildOverviewCard(provider.myRentals),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.myRentals.length,
                  itemBuilder: (context, index) {
                    final rental = provider.myRentals[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.landscape, color: Colors.white),
                        ),
                        title: Text(
                          rental.land?.name ??
                              'Land Plot #${rental.landId.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Rent: ${NumberFormat('#,###').format(rental.monthlyRent)} TND/mo',
                            ),
                            if (rental.rentalEndDate != null)
                              Text(
                                'Ends: ${DateFormat('MMM dd, yyyy').format(rental.rentalEndDate!)}',
                                style: TextStyle(
                                  color:
                                      (rental.rentalEndDate!
                                              .difference(DateTime.now())
                                              .inDays <=
                                          30)
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rental.paymentStatus.name == 'paid'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            rental.paymentStatus.name.toUpperCase(),
                            style: TextStyle(
                              color: rental.paymentStatus.name == 'paid'
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(List<LandRental> rentals) {
    // Calculate metrics
    double totalCapital = 0;
    int activeLands = 0;
    int expiringSoon = 0;
    final now = DateTime.now();

    for (var rental in rentals) {
      // Calculate total contract value
      if (rental.rentalEndDate != null) {
        final durationInMonths =
            (rental.rentalEndDate!.year - rental.rentalStartDate.year) * 12 +
            (rental.rentalEndDate!.month - rental.rentalStartDate.month);
        // Adjust for partial months if needed, but simple diff is fine for now
        // Actually, let's just use monthlyRent * duration roughly
        // Or if paymentStatus is paid, we assume it's fully paid?
        // Let's assume Total Capital = sum of all rental contracts (monthly * months)
        if (durationInMonths > 0) {
          totalCapital += rental.monthlyRent * durationInMonths;
        } else {
          totalCapital += rental.monthlyRent; // At least 1 month
        }
      }

      if (rental.paymentStatus == PaymentStatus.paid) {
        // Assuming enum match
        activeLands++;

        // Check expiry
        if (rental.rentalEndDate != null) {
          final daysUntilExpiry = rental.rentalEndDate!.difference(now).inDays;
          if (daysUntilExpiry > 0 && daysUntilExpiry <= 30) {
            expiringSoon++;
          }
        }
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Capital Invested',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${totalCapital.toStringAsFixed(0)} TND', // Formatted
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Active Lands', activeLands.toString()),
              _buildMetric('Expiring Soon', expiringSoon.toString()),
              _buildMetric('ROI Est.', '12%'), // Still static for now
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
