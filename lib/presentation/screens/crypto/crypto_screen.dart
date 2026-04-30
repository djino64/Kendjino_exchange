// lib/presentation/screens/crypto/crypto_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatter.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/crypto_provider.dart';

class CryptoScreen extends ConsumerStatefulWidget {
  const CryptoScreen({super.key});

  @override
  ConsumerState<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends ConsumerState<CryptoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cryptoState = ref.watch(cryptoProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.read(cryptoProvider.notifier).loadPrices(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Marché'),
            Tab(text: 'Mon Portfolio'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _MarketTab(cryptoState: cryptoState),
          _PortfolioTab(cryptoState: cryptoState),
        ],
      ),
    );
  }
}

// ── Market Tab ────────────────────────────────────────────────────────────────
class _MarketTab extends ConsumerWidget {
  final CryptoPortfolioState cryptoState;
  const _MarketTab({required this.cryptoState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (cryptoState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (cryptoState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(cryptoState.error!,
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(cryptoProvider.notifier).loadPrices(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Global info banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.success],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CryptoStat('BTC Dominance', '52.4%', AppColors.gold),
              _CryptoStat('Fear & Greed', '72 — Greed', AppColors.danger),
              _CryptoStat('24h Volume', '\$89.2B', AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('Actifs disponibles', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),

        ...cryptoState.assets.map((asset) => _AssetCard(asset: asset)),
      ],
    );
  }
}

class _CryptoStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _CryptoStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: 'SpaceMono',
            )),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

// ── Asset Card ─────────────────────────────────────────────────────────────────
class _AssetCard extends ConsumerWidget {
  final CryptoAssetEntity asset;
  const _AssetCard({required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUp = asset.change24h >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE8EDF2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTradeSheet(context, ref, asset),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      asset.symbol == 'BTC' ? '₿' : '₮',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: asset.symbol == 'BTC'
                            ? AppColors.gold
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & symbol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: theme.textTheme.titleSmall),
                      Text(asset.symbol,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          )),
                    ],
                  ),
                ),

                // Mini chart (simulated bars)
                SizedBox(
                  width: 50,
                  height: 28,
                  child: _MiniChart(isUp: isUp),
                ),

                const SizedBox(width: 12),

                // Price & change
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      asset.symbol == 'BTC'
                          ? '\$${(asset.priceUsd / 1000).toStringAsFixed(1)}k'
                          : '\$${asset.priceUsd.toStringAsFixed(4)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUp
                            ? AppColors.success.withOpacity(0.12)
                            : AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Formatter.percent(asset.change24h),
                        style: TextStyle(
                          color: isUp ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTradeSheet(
      BuildContext context, WidgetRef ref, CryptoAssetEntity asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TradeBottomSheet(asset: asset),
    );
  }
}

// ── Mini Chart ─────────────────────────────────────────────────────────────────
class _MiniChart extends StatelessWidget {
  final bool isUp;
  const _MiniChart({required this.isUp});

  @override
  Widget build(BuildContext context) {
    final color = isUp ? AppColors.success : AppColors.error;
    final heights = isUp
        ? [0.4, 0.5, 0.35, 0.6, 0.55, 0.7, 0.65, 0.8]
        : [0.8, 0.7, 0.75, 0.6, 0.65, 0.5, 0.45, 0.3];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: heights.map((h) {
        return Container(
          width: 4,
          height: 28 * h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}

// ── Trade Bottom Sheet ─────────────────────────────────────────────────────────
class _TradeBottomSheet extends ConsumerStatefulWidget {
  final CryptoAssetEntity asset;
  const _TradeBottomSheet({required this.asset});

  @override
  ConsumerState<_TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends ConsumerState<_TradeBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _amountCtrl = TextEditingController();
  bool _inUsd = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _amountValue =>
      double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;

  double get _cryptoEquiv =>
      _inUsd ? _amountValue / widget.asset.priceUsd : _amountValue;

  double get _usdEquiv =>
      _inUsd ? _amountValue : _amountValue * widget.asset.priceUsd;

  Future<void> _buy() async {
    if (_usdEquiv <= 0) return;
    final success = await ref.read(cryptoProvider.notifier).buyCrypto(
          symbol: widget.asset.symbol,
          amountUsd: _usdEquiv,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✅ Achat réussi: ${_cryptoEquiv.toStringAsFixed(8)} ${widget.asset.symbol}'
            : '❌ Achat échoué'),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _sell() async {
    if (_cryptoEquiv <= 0) return;
    final success = await ref.read(cryptoProvider.notifier).sellCrypto(
          symbol: widget.asset.symbol,
          cryptoAmount: _cryptoEquiv,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✅ Vente réussie: \$${_usdEquiv.toStringAsFixed(2)}'
            : '❌ Vente échouée'),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cryptoState = ref.watch(cryptoProvider);
    final isProcessing = cryptoState.isBuying || cryptoState.isSelling;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Text(
                  widget.asset.symbol == 'BTC' ? '₿' : '₮',
                  style: TextStyle(
                    fontSize: 32,
                    color: widget.asset.symbol == 'BTC'
                        ? AppColors.gold
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.asset.name, style: theme.textTheme.titleLarge),
                    Text(
                      '\$${widget.asset.priceUsd.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'SpaceMono',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Buy / Sell tabs
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color:
                      _tabCtrl.index == 0 ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                tabs: const [Tab(text: 'Acheter'), Tab(text: 'Vendre')],
                onTap: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 20),

            // Amount input
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: _inUsd ? 'USD' : widget.asset.symbol,
                suffixStyle: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  onPressed: () => setState(() => _inUsd = !_inUsd),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Equivalent
            if (_amountValue > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      _inUsd
                          ? '≈ ${_cryptoEquiv.toStringAsFixed(8)} ${widget.asset.symbol}'
                          : '≈ \$${_usdEquiv.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Quick amounts
            Wrap(
              spacing: 8,
              children: [10, 25, 50, 100].map((amt) {
                return ActionChip(
                  label: Text('\$$amt'),
                  onPressed: () {
                    setState(() {
                      _inUsd = true;
                      _amountCtrl.text = amt.toString();
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _tabCtrl.index == 0 ? AppColors.success : AppColors.error,
                ),
                onPressed: isProcessing
                    ? null
                    : () => _tabCtrl.index == 0 ? _buy() : _sell(),
                child: isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _tabCtrl.index == 0
                            ? 'Acheter ${widget.asset.symbol}'
                            : 'Vendre ${widget.asset.symbol}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Portfolio Tab ──────────────────────────────────────────────────────────────
class _PortfolioTab extends StatelessWidget {
  final CryptoPortfolioState cryptoState;
  const _PortfolioTab({required this.cryptoState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalUsd = cryptoState.totalUsdValue;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Total value
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4AA), Color(0xFF0066CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text(
                'Valeur totale du portfolio',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${totalUsd.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'SpaceMono',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '≈ ${Formatter.currency(totalUsd * 132.5, 'HTG')}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text('Mes actifs', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),

        ...cryptoState.assets.map((asset) {
          final balance = asset.balance ?? 0;
          final valueUsd = balance * asset.priceUsd;
          final pct = totalUsd > 0 ? (valueUsd / totalUsd * 100) : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE8EDF2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      asset.symbol == 'BTC' ? '₿' : '₮',
                      style: TextStyle(
                        fontSize: 28,
                        color: asset.symbol == 'BTC'
                            ? AppColors.gold
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(asset.symbol, style: theme.textTheme.titleSmall),
                          Text(
                            '${balance.toStringAsFixed(8)} ${asset.symbol}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              fontFamily: 'SpaceMono',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${valueUsd.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontFamily: 'SpaceMono',
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Allocation bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          );
        }),

        if (cryptoState.assets.isEmpty ||
            cryptoState.assets.every((a) => (a.balance ?? 0) == 0))
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.currency_bitcoin,
                    size: 56, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Portfolio vide',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Achetez votre premier Bitcoin ou USDT',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
