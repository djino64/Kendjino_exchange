import 'package:flutter/material.dart';

class BalanceCard extends Card {
  const BalanceCard({super.key});

  @override
  Widget Build(BuildContext context, Widget ref) {
    return const Scaffold(
      body: Center(
      
        child: Text('Balance Principal'),
      ),
    );
  }
}
