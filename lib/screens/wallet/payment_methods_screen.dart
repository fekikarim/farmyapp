import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchWalletStatus();
    });
  }

  Future<void> _handleAddCard() async {
    final success = await context.read<WalletProvider>().addCard();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card added successfully')),
      );
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add card')),
      );
    }
  }

  Future<void> _handleAddCredits() async {
    double? selectedAmount;
    final customAmountController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Credits',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Amount',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [10, 20, 50, 100].map((amount) {
                    final isSelected = selectedAmount == amount.toDouble();
                    return FilterChip(
                      label: Text('\$${amount.toString()}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedAmount = selected ? amount.toDouble() : null;
                          customAmountController.clear();
                        });
                      },
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: customAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Custom Amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedAmount = double.tryParse(value);
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: selectedAmount != null && selectedAmount! > 0
                      ? () {
                          Navigator.pop(context);
                          _processCharge(selectedAmount!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    selectedAmount != null
                        ? 'Pay \$${selectedAmount!.toStringAsFixed(2)}'
                        : 'Enter Amount',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }


  Future<void> _processCharge(double amount) async {
    // Navigator.pop(context); // Already closed by caller
    final success = await context.read<WalletProvider>().chargeCredits(amount);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully added \$$amount')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add credits')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet & Payments'),
      ),
      body: wallet.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => wallet.fetchWalletStatus(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Balance Card
                  Card(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            'Current Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${wallet.credits.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _handleAddCredits,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Credits'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Payment Methods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Add Card Button (List Tile style)
                  ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: const Text('Add New Card'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _handleAddCard,
                    tileColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),

                  // List of saved cards would go here if we were listing them from backend custom endpoint
                  // Since we rely on Stripe PaymentSheet to manage/show saved cards typically during payment flow, 
                  // we might just show "Saved Cards" as a list if backend returns them.
                  if (wallet.paymentMethods.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          children: wallet.paymentMethods.map((method) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.credit_card),
                                title: Text('${method.brand.toUpperCase()} **** ${method.last4}'),
                                subtitle: Text('Expires ${method.expiryMonth}/${method.expiryYear}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => wallet.deletePaymentMethod(method.id),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ),
                ],
              ),
            ),
    );
  }
}
