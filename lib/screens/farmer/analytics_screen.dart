import 'package:flutter/material.dart';

class FarmerAnalyticsScreen extends StatelessWidget {
  const FarmerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Text(
          'Analytics Screen',
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    );
  }
}
