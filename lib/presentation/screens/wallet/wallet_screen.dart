import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kendjino_exchange/routes/route_names.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';
import '../../../domain/entities/entities.dart';

// ─── Mock Providers (à remplacer par vos vrais providers Riverpod) ─────────────
final _walletProvider = Provider<WalletEntity?>((ref) => WalletEntity(
      id: 'wallet_001',
      userId: 'uid_001',
      balances: const {
        'HTG': 48750.50,
        'USD': 368.20,
        'USDT': 120.0,
        'BTC': 0.00182,
      },
      lastUpdated: DateTime.now(),
      walletNumber: 'KX-2026-001234',
    ));

final _userProvider = Provider<UserEntity?>((ref) => UserEntity(
      uid: 'uid_001',
      phoneNumber: '+509 41300944',
      displayName: 'Rood-Kendjino DESMARAIS',
      kycStatus: KycStatus.verified,
      createdAt: DateTime(2025, 1),
    ));

final _transactionsProvider = Provider<List<TransactionEntity>>((ref) {
  final now = DateTime.now();
  return [
    TransactionEntity(
      id: 'tx_001',
      userId: 'uid_001',
      type: TransactionType.receive,
      status: TransactionStatus.completed,
      amount: 5000.0,
      currency: 'HTG',
      senderPhone: '+509 4862-2664',
      senderName: 'JEAN-BAPTISTE Roosvelt',
      paymentMethod: PaymentMethod.internal,
      createdAt: now.subtract(const Duration(hours: 2)),
      completedAt: now.subtract(const Duration(hours: 2)),
    ),
    TransactionEntity(
      id: 'tx_002',
      userId: 'uid_001',
      type: TransactionType.send,
      status: TransactionStatus.completed,
      amount: 2500.0,
      currency: 'HTG',
      receiverPhone: '+509 44 55 66 77',
      receiverName: 'JOSEPH Frandy',
      paymentMethod: PaymentMethod.moncash,
      createdAt: now.subtract(const Duration(hours: 8)),
      completedAt: now.subtract(const Duration(hours: 8)),
      fee: 25.0,
    ),
    TransactionEntity(
      id: 'tx_003',
      userId: 'uid_001',
      type: TransactionType.cryptoBuy,
      status: TransactionStatus.completed,
      amount: 50.0,
      currency: 'USDT',
      paymentMethod: PaymentMethod.crypto,
      createdAt: now.subtract(const Duration(days: 1)),
      completedAt: now.subtract(const Duration(days: 1)),
    ),
    TransactionEntity(
      id: 'tx_004',
      userId: 'uid_001',
      type: TransactionType.exchange,
      status: TransactionStatus.completed,
      amount: 132.50,
      currency: 'HTG',
      exchangeRate: 0.00755,
      paymentMethod: PaymentMethod.internal,
      createdAt: now.subtract(const Duration(days: 2)),
      completedAt: now.subtract(const Duration(days: 2)),
    ),
    TransactionEntity(
      id: 'tx_005',
      userId: 'uid_001',
      type: TransactionType.topUp,
      status: TransactionStatus.completed,
      amount: 10000.0,
      currency: 'HTG',
      paymentMethod: PaymentMethod.natcash,
      createdAt: now.subtract(const Duration(days: 3)),
      completedAt: now.subtract(const Duration(days: 3)),
    ),
    TransactionEntity(
      id: 'tx_006',
      userId: 'uid_001',
      type: TransactionType.withdrawal,
      status: TransactionStatus.pending,
      amount: 200.0,
      currency: 'USD',
      paymentMethod: PaymentMethod.bankTransfer,
      createdAt: now.subtract(const Duration(days: 4)),
    ),
  ];
});

final _selectedCurrencyProvider =
    StateProvider<String>((ref) => AppConstants.htgCurrency);

final _balanceVisibleProvider = StateProvider<bool>((ref) => true);

// ─── Wallet Screen ────────────────────────────────────────────────────────────
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 10;
      if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final wallet = ref.watch(_walletProvider);
    final user = ref.watch(_userProvider);
    final transactions = ref.watch(_transactionsProvider);
    final selectedCurrency = ref.watch(_selectedCurrencyProvider);
    final balanceVisible = ref.watch(_balanceVisibleProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Header SliverAppBar ────────────────────────────────────────
            _WalletAppBar(
              user: user,
              isScrolled: _isScrolled,
              isDark: isDark,
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Balance Card ─────────────────────────────────────────
                  _BalanceCard(
                    wallet: wallet,
                    selectedCurrency: selectedCurrency,
                    balanceVisible: balanceVisible,
                    isDark: isDark,
                  ).animate().fadeIn(duration: 500.ms).slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 20),

                  // ── Currency Selector Tabs ───────────────────────────────
                  _CurrencyTabs(
                    wallet: wallet,
                    selectedCurrency: selectedCurrency,
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // ── Quick Actions ────────────────────────────────────────
                  _QuickActions()
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  // ── MonCash / NatCash Banner ─────────────────────────────
                  _PaymentProviderBanner()
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  // ── Recent Transactions ──────────────────────────────────
                  _RecentTransactionsSection(
                    transactions: transactions,
                    isDark: isDark,
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(seconds: 1));
  }
}

// ─── Wallet AppBar ────────────────────────────────────────────────────────────
class _WalletAppBar extends ConsumerWidget {
  final UserEntity? user;
  final bool isScrolled;
  final bool isDark;

  const _WalletAppBar({
    this.user,
    required this.isScrolled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 0,
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      surfaceTintColor: Colors.transparent,
      elevation: isScrolled ? 1 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // App logo + name
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kendjino',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                _greeting(),
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Offline indicator
        const _OfflineIndicator(),

        // Notifications bell
        IconButton(
          onPressed: () => context.push(RouteNames.notifications),
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                size: 24,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.errorRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Avatar / Profile
        GestureDetector(
          onTap: () => context.push(RouteNames.profile),
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _initials(user?.displayName ?? user?.phoneNumber),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour ';
    if (hour < 18) return 'Bon après-midi ';
    return 'Bonsoir';
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────
class _BalanceCard extends ConsumerWidget {
  final WalletEntity? wallet;
  final String selectedCurrency;
  final bool balanceVisible;
  final bool isDark;

  const _BalanceCard({
    this.wallet,
    required this.selectedCurrency,
    required this.balanceVisible,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = wallet?.getBalance(selectedCurrency) ?? 0.0;
    final formatted = _formatBalance(balance, selectedCurrency);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00D4AA),
              Color(0xFF00A886),
              Color(0xFF007A62),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(painter: _CardPatternPainter()),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: label + eye toggle ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solde disponible',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontFamily: 'Satoshi',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            wallet?.walletNumber ?? '—',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontFamily: 'SpaceMono',
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(_balanceVisibleProvider.notifier).state =
                              !balanceVisible;
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            balanceVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Balance amount ────────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: balanceVisible
                        ? RichText(
                            key: ValueKey(formatted),
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _currencySymbol(selectedCurrency),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontFamily: 'Satoshi',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' $formatted',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'SpaceMono',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Text(
                            '•••••••',
                            key: ValueKey('hidden'),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'SpaceMono',
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                            ),
                          ),
                  ),

                  const SizedBox(height: 6),

                  // ── Equivalent in HTG/USD ────────────────────────────────
                  if (balanceVisible && selectedCurrency != 'HTG')
                    Text(
                      '≈ HTG ${_toHtg(balance, selectedCurrency)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Bottom row: wallet actions + KYC badge ────────────────
                  Row(
                    children: [
                      _CardActionButton(
                        icon: Icons.add_rounded,
                        label: 'Recharger',
                        onTap: () => _showTopUpSheet(context),
                      ),
                      const SizedBox(width: 12),
                      _CardActionButton(
                        icon: Icons.arrow_upward_rounded,
                        label: 'Envoyer',
                        onTap: () => context.push(RouteNames.sendMoney),
                      ),
                      const SizedBox(width: 12),
                      _CardActionButton(
                        icon: Icons.arrow_downward_rounded,
                        label: 'Recevoir',
                        onTap: () => context.push(RouteNames.wallet),
                      ),
                      const Spacer(),
                      // KYC verified badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'KYC',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Satoshi',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBalance(double amount, String currency) {
    if (currency == 'BTC') {
      return amount.toStringAsFixed(5);
    }
    final fmt = NumberFormat('#,##0.00', 'fr_FR');
    return fmt.format(amount);
  }

  String _currencySymbol(String currency) {
    return switch (currency) {
      'HTG' => 'HTG',
      'USD' => 'USD',
      'USDT' => 'USDT',
      'BTC' => '₿',
      _ => currency,
    };
  }

  String _toHtg(double amount, String currency) {
    final rate = switch (currency) {
      'USD' => AppConstants.defaultUsdToHtg,
      'USDT' => AppConstants.defaultUsdToHtg,
      'BTC' => AppConstants.defaultBtcToUsd * AppConstants.defaultUsdToHtg,
      _ => 1.0,
    };
    final htg = amount * rate;
    return NumberFormat('#,##0', 'fr_FR').format(htg);
  }

  void _showTopUpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TopUpSheet(),
    );
  }
}

// ─── Card Action Button ───────────────────────────────────────────────────────
class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontFamily: 'Satoshi',
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Currency Tabs ────────────────────────────────────────────────────────────
class _CurrencyTabs extends ConsumerWidget {
  final WalletEntity? wallet;
  final String selectedCurrency;

  const _CurrencyTabs({this.wallet, required this.selectedCurrency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencies = ['HTG', 'USD', 'USDT', 'BTC'];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: currencies.length,
        itemBuilder: (_, i) {
          final currency = currencies[i];
          final isSelected = currency == selectedCurrency;
          final balance = wallet?.getBalance(currency) ?? 0.0;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(_selectedCurrencyProvider.notifier).state = currency;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : isDark
                        ? AppTheme.darkCard
                        : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : isDark
                          ? AppTheme.darkBorder
                          : const Color(0xFFE8EDF2),
                  width: isSelected ? 0 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CurrencyIcon(currency: currency, selected: isSelected),
                      const SizedBox(width: 6),
                      Text(
                        currency,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : isDark
                                  ? AppTheme.textLight
                                  : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatShort(balance, currency),
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatShort(double amount, String currency) {
    if (currency == 'BTC') return amount.toStringAsFixed(5);
    if (amount >= 1000) {
      return '${NumberFormat('#,##0.0', 'fr_FR').format(amount / 1000)}k';
    }
    return NumberFormat('#,##0.00', 'fr_FR').format(amount);
  }
}

// ─── Currency Icon ────────────────────────────────────────────────────────────
class _CurrencyIcon extends StatelessWidget {
  final String currency;
  final bool selected;

  const _CurrencyIcon({required this.currency, required this.selected});

  @override
  Widget build(BuildContext context) {
    final (emoji, color) = switch (currency) {
      'HTG' => ('🇭🇹', const Color(0xFF003087)),
      'USD' => ('🇺🇸', const Color(0xFF3C3B6E)),
      'USDT' => ('₮', const Color(0xFF26A17B)),
      'BTC' => ('₿', const Color(0xFFF7931A)),
      _ => ('?', AppTheme.textMuted),
    };

    if (currency == 'USDT' || currency == 'BTC') {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: selected ? Colors.white : color,
            ),
          ),
        ),
      );
    }

    return Text(emoji, style: const TextStyle(fontSize: 16));
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actions = [
      _ActionItem(
        icon: Icons.send_rounded,
        label: 'Envoyer',
        color: AppTheme.primaryGreen,
        onTap: () => context.push(RouteNames.sendMoney),
      ),
      _ActionItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scanner',
        color: AppTheme.infoBlue,
        onTap: () => _showScanner(context),
      ),
      _ActionItem(
        icon: Icons.currency_exchange_rounded,
        label: 'Changer',
        color: AppTheme.accentGold,
        onTap: () => context.push(RouteNames.exchange),
      ),
      _ActionItem(
        icon: Icons.currency_bitcoin_rounded,
        label: 'Crypto',
        color: const Color(0xFFF7931A),
        onTap: () => context.push(RouteNames.crypto),
      ),
      _ActionItem(
        icon: Icons.credit_card_rounded,
        label: 'Ma carte',
        color: const Color(0xFF9B59B6),
        onTap: () => context.push(RouteNames.virtualCard),
      ),
      _ActionItem(
        icon: Icons.history_rounded,
        label: 'Historique',
        color: AppTheme.textMuted,
        onTap: () => context.push(RouteNames.history),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'ACTIONS RAPIDES',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFE8EDF2),
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 1.1,
              ),
              itemCount: actions.length,
              itemBuilder: (_, i) => actions[i]
                  .animate()
                  .fadeIn(delay: (i * 50).ms, duration: 300.ms)
                  .scale(
                      begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            ),
          ),
        ),
      ],
    );
  }

  void _showScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _QrScannerSheet(),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.textLight
                  : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MonCash / NatCash Banner ─────────────────────────────────────────────────
class _PaymentProviderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'RECHARGER VIA',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ProviderCard(
                  name: 'MonCash',
                  subtitle: 'Digicel Haiti',
                  color: const Color(0xFFE30613),
                  icon: Icons.phone_android_rounded,
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProviderCard(
                  name: 'NatCash',
                  subtitle: 'Natcom',
                  color: const Color(0xFF005BAA),
                  icon: Icons.phone_android_rounded,
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.name,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : const Color(0xFFE8EDF2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Transactions Section ──────────────────────────────────────────────
class _RecentTransactionsSection extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final bool isDark;

  const _RecentTransactionsSection({
    required this.transactions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRANSACTIONS RÉCENTES',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              TextButton(
                onPressed: () => context.push(RouteNames.history),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'Tout voir',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Transactions List ────────────────────────────────────────────────
        if (recent.isEmpty)
          _EmptyTransactions(isDark: isDark)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFE8EDF2),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (_, i) => Divider(
                  height: 1,
                  indent: 72,
                  color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF2F7),
                ),
                itemBuilder: (_, i) => _TransactionTile(
                  tx: recent[i],
                  isDark: isDark,
                )
                    .animate()
                    .fadeIn(delay: (i * 60).ms, duration: 300.ms)
                    .slideX(begin: 0.1, end: 0),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionEntity tx;
  final bool isDark;

  const _TransactionTile({required this.tx, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.isCredit;
    final amountColor = isCredit ? AppTheme.successGreen : AppTheme.errorRed;
    final amountPrefix = isCredit ? '+' : '-';
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.push(RouteNames.transactionDetail, extra: tx.id),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Icon ──────────────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_icon(), color: _iconColor(), size: 20),
            ),

            const SizedBox(width: 12),

            // ── Labels ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _StatusDot(status: tx.status),
                      const SizedBox(width: 4),
                      Text(
                        _subtitle(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Amount ────────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix ${_formatAmount()}',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeAgo(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon() {
    return switch (tx.type) {
      TransactionType.send => Icons.arrow_upward_rounded,
      TransactionType.receive => Icons.arrow_downward_rounded,
      TransactionType.exchange => Icons.currency_exchange_rounded,
      TransactionType.cryptoBuy => Icons.currency_bitcoin_rounded,
      TransactionType.cryptoSell => Icons.currency_bitcoin_rounded,
      TransactionType.topUp => Icons.add_circle_rounded,
      TransactionType.withdrawal => Icons.remove_circle_rounded,
      TransactionType.cardPayment => Icons.credit_card_rounded,
      _ => Icons.swap_horiz_rounded,
    };
  }

  Color _iconColor() {
    return switch (tx.type) {
      TransactionType.send => AppTheme.errorRed,
      TransactionType.receive => AppTheme.successGreen,
      TransactionType.exchange => AppTheme.accentGold,
      TransactionType.cryptoBuy => const Color(0xFFF7931A),
      TransactionType.cryptoSell => const Color(0xFFF7931A),
      TransactionType.topUp => AppTheme.primaryGreen,
      TransactionType.withdrawal => AppTheme.warningOrange,
      TransactionType.cardPayment => AppTheme.infoBlue,
      _ => AppTheme.textMuted,
    };
  }

  String _title() {
    return switch (tx.type) {
      TransactionType.send => tx.receiverName ?? tx.receiverPhone ?? 'Envoi',
      TransactionType.receive => tx.senderName ?? tx.senderPhone ?? 'Réception',
      TransactionType.exchange => 'Conversion de devises',
      TransactionType.cryptoBuy => 'Achat ${tx.currency}',
      TransactionType.cryptoSell => 'Vente ${tx.currency}',
      TransactionType.topUp => 'Recharge',
      TransactionType.withdrawal => 'Retrait',
      TransactionType.cardPayment => 'Paiement carte',
      _ => 'Transaction',
    };
  }

  String _subtitle() {
    final method = switch (tx.paymentMethod) {
      PaymentMethod.internal => 'Kendjino',
      PaymentMethod.moncash => 'MonCash',
      PaymentMethod.natcash => 'NatCash',
      PaymentMethod.bankTransfer => 'Virement',
      PaymentMethod.virtualCard => 'Carte virtuelle',
      PaymentMethod.crypto => 'Crypto',
    };
    return method;
  }

  String _formatAmount() {
    final symbol = switch (tx.currency) {
      'BTC' => '₿',
      'USDT' => 'USDT',
      'USD' => 'USD',
      _ => 'HTG',
    };
    if (tx.currency == 'BTC') {
      return '${tx.amount.toStringAsFixed(5)} $symbol';
    }
    return '${NumberFormat('#,##0.00', 'fr_FR').format(tx.amount)} $symbol';
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(tx.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}

// ─── Status Dot ───────────────────────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  final TransactionStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TransactionStatus.completed => AppTheme.successGreen,
      TransactionStatus.pending => AppTheme.warningOrange,
      TransactionStatus.processing => AppTheme.infoBlue,
      TransactionStatus.failed => AppTheme.errorRed,
      TransactionStatus.cancelled => AppTheme.textMuted,
    };
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Empty Transactions ───────────────────────────────────────────────────────
class _EmptyTransactions extends StatelessWidget {
  final bool isDark;
  const _EmptyTransactions({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : const Color(0xFFE8EDF2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Aucune transaction',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Vos transactions apparaîtront ici',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Offline Indicator ────────────────────────────────────────────────────────
class _OfflineIndicator extends StatelessWidget {
  // Passez isOffline depuis votre connectivityProvider réel.
  // Pour l'instant on retourne toujours SizedBox — remplacez la valeur
  // par ref.watch(connectivityProvider) quand le provider est prêt.
  const _OfflineIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
    // Décommentez et branchez votre provider pour activer la bannière :
    // return Consumer(builder: (_, ref, __) {
    //   final isOffline = ref.watch(connectivityProvider);
    //   if (!isOffline) return const SizedBox.shrink();
    //   return _OfflineBanner();
    // });
  }
}

// ─── Top Up Bottom Sheet ──────────────────────────────────────────────────────
class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet();

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  final _amountController = TextEditingController();
  String _selectedProvider = 'MonCash';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('Recharger le portefeuille', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Choisissez un moyen de paiement',
            style:
                theme.textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),

          // Provider selector
          Row(
            children: ['MonCash', 'NatCash'].map((p) {
              final selected = _selectedProvider == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedProvider = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: p == 'MonCash' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryGreen
                          : isDark
                              ? AppTheme.darkCard
                              : AppTheme.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primaryGreen
                            : isDark
                                ? AppTheme.darkBorder
                                : const Color(0xFFE0E7F0),
                      ),
                    ),
                    child: Text(
                      p,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Amount input
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Montant en HTG',
              prefixIcon: const Icon(Icons.monetization_on_outlined,
                  color: AppTheme.primaryGreen),
              suffixText: 'HTG',
              hintText: 'Ex: 5000',
            ),
          ),

          // Quick amounts
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [500, 1000, 2500, 5000, 10000].map((a) {
              return GestureDetector(
                onTap: () => _amountController.text = a.toString(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${NumberFormat('#,##0', 'fr_FR').format(a)} HTG',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _onTopUp,
            child: Text('Recharger via $_selectedProvider'),
          ),
        ],
      ),
    );
  }

  void _onTopUp() {
    if (_amountController.text.isEmpty) return;
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Recharge de ${_amountController.text} HTG via $_selectedProvider initiée'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── QR Scanner Sheet ─────────────────────────────────────────────────────────
class _QrScannerSheet extends StatelessWidget {
  const _QrScannerSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Scanner un QR Code',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Pointez la caméra vers un QR Kendjino',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),

          // Simulated QR viewfinder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // QR frame corners
                    CustomPaint(
                      painter: _QrFramePainter(),
                      size: const Size(200, 200),
                    ),
                    // Scan line animation
                    _ScanLine(),
                    Icon(Icons.qr_code_scanner_rounded,
                        color: Colors.white.withValues(alpha: 0.15), size: 100),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _anim = Tween<double>(begin: -0.4, end: 0.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value * 150),
        child: Container(
          width: 200,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              AppTheme.primaryGreen,
              Colors.transparent,
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────────────────────
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Large circle top-right
    canvas.drawCircle(
      Offset(size.width * 1.1, size.height * -0.2),
      size.width * 0.6,
      paint,
    );
    // Small circle bottom-left
    canvas.drawCircle(
      Offset(size.width * -0.1, size.height * 1.2),
      size.width * 0.35,
      paint,
    );
    // Dots
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(size.width * 0.15 + i * 30, size.height * 0.7 + j * 20),
          2,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QrFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const corner = 24.0;
    const len = 40.0;

    final paths = [
      // Top-left
      Path()
        ..moveTo(corner, 0)
        ..lineTo(0, 0)
        ..lineTo(0, len),
      // Top-right
      Path()
        ..moveTo(size.width - corner, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      // Bottom-left
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height)
        ..lineTo(corner, size.height),
      // Bottom-right
      Path()
        ..moveTo(size.width, size.height - len)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - corner, size.height),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
