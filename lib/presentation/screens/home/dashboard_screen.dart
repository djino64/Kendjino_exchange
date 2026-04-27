// lib/presentation/screens/home/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/crypto_provider.dart';
import '../../../domain/entities/entities.dart';
import '../../../routes/route_names.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final walletState = ref.watch(walletProvider);
    final txState = ref.watch(transactionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.read(walletProvider.notifier).refresh();
          ref.read(transactionProvider.notifier).loadTransactions();
        },
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: false,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Kendjino',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // ── Greeting ───────────────────────────────────────────────
                  Text(
                    'Bonjour, ${user?.displayName?.split(' ').first ?? 'Utilisateur'} 👋',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),

                  // ── Balance Card ───────────────────────────────────────────
                  _BalanceCard(walletState: walletState),

                  const SizedBox(height: 24),

                  // ── Quick Actions ──────────────────────────────────────────
                  _QuickActions(),

                  const SizedBox(height: 28),

                  // ── Crypto Mini ────────────────────────────────────────────
                  _CryptoMiniWidget(),

                  const SizedBox(height: 28),

                  // ── Recent Transactions ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transactions récentes',
                          style: theme.textTheme.titleLarge),
                      TextButton(
                        onPressed: () => context.go(RouteNames.history),
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (txState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (txState.transactions.isEmpty)
                    _EmptyTransactions()
                  else
                    ...txState.transactions
                        .take(5)
                        .map((tx) => _TransactionTile(tx: tx)),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.sendMoney),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.send_rounded),
        label: const Text('Envoyer', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Balance Card ─────────────────────────────────────────────────────────────
class _BalanceCard extends StatefulWidget {
  final WalletState walletState;
  const _BalanceCard({required this.walletState});

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _hidden = false;
  String _currency = 'HTG';

  @override
  Widget build(BuildContext context) {
    final wallet = widget.walletState.wallet;
    final balance = _currency == 'HTG'
        ? (wallet?.htgBalance ?? 0)
        : (wallet?.usdBalance ?? 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF009E7F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Currency toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _CurrencyTab(
                      label: 'HTG',
                      active: _currency == 'HTG',
                      onTap: () => setState(() => _currency = 'HTG'),
                    ),
                    _CurrencyTab(
                      label: 'USD',
                      active: _currency == 'USD',
                      onTap: () => setState(() => _currency = 'USD'),
                    ),
                  ],
                ),
              ),
              // Hide toggle
              GestureDetector(
                onTap: () => setState(() => _hidden = !_hidden),
                child: Icon(
                  _hidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.8),
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Solde disponible',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          widget.walletState.isLoading
              ? const SizedBox(
                  height: 48,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                )
              : Text(
                  _hidden
                      ? '•••••'
                      : Formatter.currency(balance, _currency),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SpaceMono',
                    letterSpacing: -1,
                  ),
                ),

          const SizedBox(height: 20),

          // Wallet number
          Row(
            children: [
              Icon(Icons.credit_card, color: Colors.white.withOpacity(0.7), size: 16),
              const SizedBox(width: 6),
              Text(
                wallet?.walletNumber ?? '----',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontFamily: 'SpaceMono',
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencyTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CurrencyTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.send_rounded, 'Envoyer', RouteNames.sendMoney),
      (Icons.download_rounded, 'Recevoir', RouteNames.wallet),
      (Icons.swap_horiz_rounded, 'Convertir', RouteNames.exchange),
      (Icons.credit_card_rounded, 'Ma carte', RouteNames.wallet),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return _ActionButton(icon: a.$1, label: a.$2, route: a.$3);
      }).toList(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE8EDF2),
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Crypto Mini Widget ────────────────────────────────────────────────────────
class _CryptoMiniWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cryptoState = ref.watch(cryptoProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (cryptoState.assets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Crypto', style: theme.textTheme.titleLarge),
            TextButton(
              onPressed: () => context.go(RouteNames.crypto),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cryptoState.assets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final asset = cryptoState.assets[i];
              final isUp = asset.change24h >= 0;
              return Container(
                width: 150,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE8EDF2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          asset.symbol == 'BTC' ? '₿' : '₮',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(asset.symbol,
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatter.compactCurrency(asset.priceUsd, 'USD'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatter.percent(asset.change24h),
                      style: TextStyle(
                        color: isUp ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Transaction Tile ──────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionEntity tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCredit = tx.type == TransactionType.deposit ||
        tx.type == TransactionType.received;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.receiverName ?? tx.receiverPhone,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  Formatter.date(tx.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${Formatter.currency(tx.amount, tx.currency)}',
                style: TextStyle(
                  color: isCredit ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceMono',
                  fontSize: 14,
                ),
              ),
              _StatusChip(status: tx.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TransactionStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case TransactionStatus.completed:
        color = AppColors.success; label = 'Complété'; break;
      case TransactionStatus.pending:
        color = AppColors.warning; label = 'En attente'; break;
      case TransactionStatus.failed:
        color = AppColors.error; label = 'Échoué'; break;
      default:
        color = AppColors.textMuted; label = status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: backgroundColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined,
              size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'Aucune transaction',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vos transferts apparaîtront ici',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}