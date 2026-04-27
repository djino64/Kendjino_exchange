// lib/presentation/screens/exchange/exchange_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatter.dart';

class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  final _amountCtrl = TextEditingController();
  String _fromCurrency = 'HTG';
  String _toCurrency = 'USD';
  double _result = 0;
  bool _isConverting = false;

  final Map<String, double> _rates = {
    'HTG_USD': 0.0075,
    'USD_HTG': 132.5,
    'USD_USDT': 1.0,
    'USDT_USD': 1.0,
    'BTC_USD': 65420.0,
    'USD_BTC': 1 / 65420.0,
    'HTG_USDT': 0.0075,
    'USDT_HTG': 132.5,
  };

  final List<String> _currencies = ['HTG', 'USD', 'USDT', 'BTC'];

  double _convert(double amount, String from, String to) {
    if (from == to) return amount;
    final key = '${from}_$to';
    final rate = _rates[key] ?? 1.0;
    return amount * rate;
  }

  void _updateResult() {
    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    setState(() => _result = _convert(amount, _fromCurrency, _toCurrency));
  }

  void _swap() {
    setState(() {
      final tmp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tmp;
      _updateResult();
    });
  }

  Future<void> _executeConversion() async {
    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) return;

    setState(() => _isConverting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isConverting = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Conversion réussie: ${Formatter.currency(amount, _fromCurrency)} → ${Formatter.currency(_result, _toCurrency)}',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Convertir des devises')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live rates banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.white),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Taux du jour',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      Text(
                        '1 USD = 132.5 HTG',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontFamily: 'SpaceMono',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.refresh, color: Colors.white70),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Converter card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE8EDF2),
                ),
              ),
              child: Column(
                children: [
                  // From
                  _CurrencyInput(
                    label: 'De',
                    controller: _amountCtrl,
                    currency: _fromCurrency,
                    currencies: _currencies,
                    onCurrencyChanged: (c) {
                      setState(() => _fromCurrency = c);
                      _updateResult();
                    },
                    onChanged: (_) => _updateResult(),
                  ),

                  const SizedBox(height: 12),

                  // Swap button
                  Center(
                    child: GestureDetector(
                      onTap: _swap,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.swap_vert,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // To
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vers', style: theme.textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Text(
                                _result == 0
                                    ? '0.00'
                                    : Formatter.currency(_result, _toCurrency)
                                        .replaceAll(_toCurrency, '')
                                        .trim(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'SpaceMono',
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
                          value: _toCurrency,
                          underline: const SizedBox(),
                          items: _currencies
                              .where((c) => c != _fromCurrency)
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                  ))
                              .toList(),
                          onChanged: (c) {
                            setState(() => _toCurrency = c!);
                            _updateResult();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Rate info
            if (_amountCtrl.text.isNotEmpty && _result > 0)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Taux appliqué',
                        style: theme.textTheme.bodySmall),
                    Text(
                      '1 $_fromCurrency = ${Formatter.currency(_convert(1, _fromCurrency, _toCurrency), _toCurrency)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'SpaceMono',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // Convert button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isConverting ||
                        (_amountCtrl.text.isEmpty || _result <= 0)
                    ? null
                    : _executeConversion,
                icon: _isConverting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.swap_horiz_rounded),
                label: Text(
                  _isConverting ? 'Conversion...' : 'Convertir maintenant',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Rate table
            Text('Taux de référence', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...[
              ('HTG', 'USD', 0.0075),
              ('USD', 'HTG', 132.5),
              ('USD', 'USDT', 1.0),
              ('BTC', 'USD', 65420.0),
            ].map((r) => _RateRow(
                  from: r.$1,
                  to: r.$2,
                  rate: r.$3,
                )),
          ],
        ),
      ),
    );
  }
}

class _CurrencyInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String currency;
  final List<String> currencies;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onChanged;

  const _CurrencyInput({
    required this.label,
    required this.controller,
    required this.currency,
    required this.currencies,
    required this.onCurrencyChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  ],
                  onChanged: onChanged,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SpaceMono',
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: currency,
            underline: const SizedBox(),
            items: currencies
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ))
                .toList(),
            onChanged: (c) => onCurrencyChanged(c!),
          ),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final String from;
  final String to;
  final double rate;

  const _RateRow({required this.from, required this.to, required this.rate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE8EDF2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('1 $from → $to', style: theme.textTheme.bodyMedium),
          Text(
            Formatter.currency(rate, to),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'SpaceMono',
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}