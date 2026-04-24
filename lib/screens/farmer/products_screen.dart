import 'package:flutter/material.dart';

class FarmerProductsScreen extends StatelessWidget {
  const FarmerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.products,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    );
  }
}
