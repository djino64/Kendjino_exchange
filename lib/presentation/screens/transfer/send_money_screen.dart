// lib/presentation/screens/transfer/send_money_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/validators.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _currency = 'HTG';
  String _provider = 'internal'; // internal, moncash, natcash
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      setState(() {
        switch (_tabCtrl.index) {
          case 0:
            _provider = 'internal';
            break;
          case 1:
            _provider = 'moncash';
            break;
          case 2:
            _provider = 'natcash';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;

    // Confirm dialog
    final confirmed = await _showConfirmation(amount);
    if (!confirmed) return;

    final success = await ref.read(transactionProvider.notifier).sendMoney(
          receiverPhone: _phoneCtrl.text.trim(),
          amount: amount,
          currency: _currency,
          note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text : null,
        );

    if (!mounted) return;
    if (success) {
      _showSuccess(amount);
    } else {
      final error = ref.read(transactionProvider).error;
      _showError(error ?? 'Erreur lors du transfert');
    }
  }

  Future<bool> _showConfirmation(double amount) async {
    final wallet = ref.read(walletProvider).wallet;
    final balance = _currency == 'HTG'
        ? (wallet?.getBalance('HTG') ?? 0)
        : (wallet?.getBalance('USD') ?? 0);
    final fee = _currency == 'HTG' ? amount * 0.01 : amount * 0.015;

    return await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.send_rounded,
                    color: AppColors.primary, size: 40),
                const SizedBox(height: 12),
                Text('Confirmer le transfert',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                _ConfirmRow('Destinataire', _phoneCtrl.text),
                _ConfirmRow('Montant', Formatter.currency(amount, _currency)),
                _ConfirmRow('Frais', Formatter.currency(fee, _currency)),
                const Divider(height: 24),
                _ConfirmRow(
                  'Total',
                  Formatter.currency(amount + fee, _currency),
                  bold: true,
                ),
                _ConfirmRow(
                  'Solde après',
                  Formatter.currency(balance - amount - fee, _currency),
                  color: balance < amount + fee ? AppColors.error : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirmer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _showSuccess(double amount) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Transfert réussi!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              Formatter.currency(amount, _currency),
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'SpaceMono'),
            ),
            const SizedBox(height: 8),
            Text('Envoyé à ${_phoneCtrl.text}',
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final walletState = ref.watch(walletProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Envoyer de l\'argent'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Balance indicator
              if (walletState.wallet != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Solde: ${Formatter.currency(_currency == 'HTG' ? walletState.wallet!.getBalance('HTG') : walletState.wallet!.getBalance('USD'), _currency)}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Provider tabs
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Kendjino'),
                    Tab(text: 'MonCash'),
                    Tab(text: 'NatCash'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Phone field
              Text('Numéro du destinataire', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '34 56 7890',
                  prefixText: '+509 ',
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.contact_phone_outlined),
                    onPressed: () {},
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Numéro requis';
                  if (v.length < 8) return 'Numéro invalide';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Amount + Currency
              Text('Montant', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Currency selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFE0E7F0),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currency,
                        items: ['HTG', 'USD']
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _currency = v!),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                      ],
                      decoration: const InputDecoration(
                        hintText: '0.00',
                      ),
                      style: const TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      validator: (v) => Validators.amount(
                        v,
                        min: 10,
                        max: _currency == 'HTG' ? 50000 : 500,
                      ),
                    ),
                  ),
                ],
              ),

              // Quick amounts
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: (_currency == 'HTG'
                        ? [500, 1000, 2500, 5000]
                        : [10, 25, 50, 100])
                    .map((amt) => ActionChip(
                          label: Text('$amt'),
                          onPressed: () => _amountCtrl.text = amt.toString(),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Note (optional)
              Text('Note (optionnel)', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteCtrl,
                maxLength: 100,
                decoration: const InputDecoration(
                  hintText: 'Raison du transfert...',
                  prefixIcon: Icon(Icons.edit_note_outlined),
                ),
              ),

              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: txState.isSending ? null : _submit,
                  icon: txState.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    txState.isSending
                        ? 'Envoi en cours...'
                        : 'Envoyer maintenant',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _ConfirmRow(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color,
              fontFamily: bold ? 'SpaceMono' : null,
            ),
          ),
        ],
      ),
    );
  }
}
