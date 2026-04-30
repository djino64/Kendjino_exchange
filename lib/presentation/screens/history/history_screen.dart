// lib/presentation/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatter.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/transaction_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'all';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final theme = Theme.of(context);

    final filtered = txState.transactions.where((tx) {
      if (_filter == 'sent' && tx.type != TransactionType.transfer)
        return false;
      if (_filter == 'received' &&
          tx.type != TransactionType.received &&
          tx.type != TransactionType.deposit) {
        return false;
      }
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return (tx.receiverPhone?.contains(q) ?? false) ||
            (tx.receiverName?.toLowerCase().contains(q) ?? false) ||
            tx.amount.toString().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              // Export CSV mock
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export en préparation...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                // Search
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _search = ''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        selected: _filter == 'all',
                        onTap: () => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Envoyés',
                        selected: _filter == 'sent',
                        onTap: () => setState(() => _filter = 'sent'),
                        icon: Icons.arrow_upward,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Reçus',
                        selected: _filter == 'received',
                        onTap: () => setState(() => _filter = 'received'),
                        icon: Icons.arrow_downward,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Summary strip
          if (txState.transactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: _SummaryStrip(transactions: txState.transactions),
            ),

          // Transaction list
          Expanded(
            child: txState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? _EmptyState(
                        hasFilter: _filter != 'all' || _search.isNotEmpty)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => ref
                            .read(transactionProvider.notifier)
                            .loadTransactions(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) => _TxCard(tx: filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final List<TransactionEntity> transactions;
  const _SummaryStrip({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double totalSent = 0, totalReceived = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.transfer) totalSent += tx.amount;
      if (tx.type == TransactionType.received ||
          tx.type == TransactionType.deposit) {
        totalReceived += tx.amount;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE8EDF2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Envoyés',
            value: Formatter.compactCurrency(totalSent, 'HTG'),
            color: AppColors.error,
            icon: Icons.arrow_upward,
          ),
          Container(width: 1, height: 32, color: AppColors.darkBorder),
          _StatItem(
            label: 'Reçus',
            value: Formatter.compactCurrency(totalReceived, 'HTG'),
            color: AppColors.success,
            icon: Icons.arrow_downward,
          ),
          Container(width: 1, height: 32, color: AppColors.darkBorder),
          _StatItem(
            label: 'Total',
            value: '${transactions.length}',
            color: AppColors.primary,
            icon: Icons.receipt_long_outlined,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'SpaceMono',
                fontSize: 12)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

class _TxCard extends StatelessWidget {
  final TransactionEntity tx;
  const _TxCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCredit = tx.type == TransactionType.received ||
        tx.type == TransactionType.deposit;
    final color = isCredit ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE8EDF2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.receiverName ?? tx.receiverPhone ?? 'Unknown',
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatter.dateTime(tx.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
                if (tx.note != null && tx.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${Formatter.currency(tx.amount, tx.currency)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceMono',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              _StatusBadge(status: tx.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final active = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? active : active.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : active),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : active,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color c;
    String l;
    switch (status) {
      case TransactionStatus.completed:
        c = AppColors.success;
        l = 'Complété';
        break;
      case TransactionStatus.pending:
        c = AppColors.warning;
        l = 'En attente';
        break;
      case TransactionStatus.failed:
        c = AppColors.error;
        l = 'Échoué';
        break;
      default:
        c = AppColors.textMuted;
        l = status.name;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(l,
          style:
              TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'Aucun résultat' : 'Aucune transaction',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Essayez d\'autres filtres'
                : 'Vos transactions apparaîtront ici',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
