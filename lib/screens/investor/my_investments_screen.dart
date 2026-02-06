import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/land_provider.dart';

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
              _buildOverviewCard(),
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
                          'Land Plot #${rental.landId.substring(0, 8)}',
                        ),
                        subtitle: Text('Monthly: ${rental.monthlyRent} TND'),
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

  Widget _buildOverviewCard() {
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
          const Text(
            '14,400 TND',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Active Lands', '3'),
              _buildMetric('Expiring Soon', '1'),
              _buildMetric('ROI Est.', '12%'),
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
