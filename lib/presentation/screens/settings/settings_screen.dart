import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'package:kendjino_exchange/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              _label(locale, 'Paramètres', 'Paramèt', 'Settings'),
              style: theme.textTheme.titleLarge,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => _showAppInfo(context, theme, isDark),
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.textMuted,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Header ──────────────────────────────────────
                  _ProfileCard(user: user, locale: locale)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.15, end: 0, duration: 400.ms),

                  const SizedBox(height: 24),

                  // ── Account ─────────────────────────────────────────────
                  _SectionLabel(
                    label: _label(locale, 'Compte', 'Kont', 'Account'),
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_rounded,
                        iconColor: AppTheme.infoBlue,
                        title: _label(
                            locale, 'Mon profil', 'Pwofil mwen', 'My Profile'),
                        subtitle: user?.displayName ?? user?.phoneNumber ?? '—',
                        onTap: () => context.push(RouteNames.profile),
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.verified_user_rounded,
                        iconColor: AppTheme.successGreen,
                        title: _label(locale, 'Vérification KYC',
                            'Verifikasyon KYC', 'KYC Verification'),
                        subtitle: _kycLabel(user?.kycStatus, locale),
                        trailing: _KycBadge(status: user?.kycStatus),
                        onTap: () => context.push(RouteNames.kyc),
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.credit_card_rounded,
                        iconColor: AppTheme.accentGold,
                        title: _label(locale, 'Carte virtuelle', 'Kat vityèl',
                            'Virtual Card'),
                        subtitle: _label(locale, 'Gérer votre carte',
                            'Jere kat ou', 'Manage your card'),
                        onTap: () => context.push(RouteNames.virtualCard),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Security ─────────────────────────────────────────────
                  _SectionLabel(
                    label: _label(locale, 'Sécurité', 'Sekirite', 'Security'),
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.lock_rounded,
                        iconColor: AppTheme.warningOrange,
                        title:
                            _label(locale, 'Code PIN', 'Kòd PIN', 'PIN Code'),
                        subtitle: _label(locale, 'Modifier votre PIN',
                            'Chanje PIN ou', 'Change your PIN'),
                        onTap: () => context.push(RouteNames.security),
                      ),
                      _SettingsDivider(),
                      _BiometricTile(locale: locale),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.history_rounded,
                        iconColor: AppTheme.primaryGreen,
                        title: _label(locale, 'Activité du compte',
                            'Aktivite kont', 'Account Activity'),
                        subtitle: _label(locale, 'Voir les connexions',
                            'Wè koneksyon yo', 'View login history'),
                        onTap: () => context.push(RouteNames.history),
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.devices_rounded,
                        iconColor: AppTheme.infoBlue,
                        title: _label(locale, 'Appareils connectés',
                            'Aparèy konekte', 'Connected Devices'),
                        subtitle: _label(locale, '1 appareil actif',
                            '1 aparèy aktif', '1 active device'),
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Preferences ───────────────────────────────────────────
                  _SectionLabel(
                    label: _label(
                        locale, 'Préférences', 'Preferans', 'Preferences'),
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF9B59B6),
                        title: _label(locale, 'Langue', 'Lang', 'Language'),
                        subtitle: _localeName(locale),
                        onTap: () => context.push(RouteNames.language),
                      ),
                      _SettingsDivider(),
                      _ThemeModeTile(
                        locale: locale,
                        themeMode: themeMode,
                        isDark: isDark,
                      ),
                      _SettingsDivider(),
                      _CurrencyTile(locale: locale),
                      _SettingsDivider(),
                      _NotificationTile(locale: locale),
                    ],
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Payments ──────────────────────────────────────────────
                  _SectionLabel(
                    label: _label(locale, 'Paiements', 'Pèman', 'Payments'),
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: const Color(0xFF1DB954),
                        title: _label(locale, 'Limites de transfert',
                            'Limit transfè', 'Transfer Limits'),
                        subtitle: _label(
                          locale,
                          'HTG ${AppConstants.dailyTransferLimit.toStringAsFixed(0)} / jour',
                          'HTG ${AppConstants.dailyTransferLimit.toStringAsFixed(0)} / jou',
                          'HTG ${AppConstants.dailyTransferLimit.toStringAsFixed(0)} / day',
                        ),
                        onTap: () {},
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppTheme.warningOrange,
                        title: _label(locale, 'Historique complet',
                            'Tout istwa', 'Full History'),
                        subtitle: _label(locale, 'Voir toutes les transactions',
                            'Wè tout tranzaksyon', 'View all transactions'),
                        onTap: () => context.push(RouteNames.history),
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.download_rounded,
                        iconColor: AppTheme.infoBlue,
                        title: _label(locale, 'Exporter relevé',
                            'Ekspòte relve', 'Export Statement'),
                        subtitle: _label(
                            locale, 'PDF ou CSV', 'PDF oswa CSV', 'PDF or CSV'),
                        onTap: () => _showExportSheet(context, locale),
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Support ───────────────────────────────────────────────
                  _SectionLabel(
                    label: _label(locale, 'Support', 'Sipò', 'Support'),
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.help_rounded,
                        iconColor: AppTheme.primaryGreen,
                        title: _label(
                            locale, 'Centre d\'aide', 'Sant èd', 'Help Center'),
                        onTap: () {},
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.chat_bubble_rounded,
                        iconColor: const Color(0xFF25D366),
                        title: _label(locale, 'Chat en direct', 'Chat an dirèk',
                            'Live Chat'),
                        subtitle: _label(locale, 'Disponible 8h–20h',
                            'Disponib 8h–20h', 'Available 8am–8pm'),
                        onTap: () {},
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.star_rounded,
                        iconColor: AppTheme.accentGold,
                        title: _label(locale, 'Noter l\'app', 'Bay app la nòt',
                            'Rate the App'),
                        onTap: () {},
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.share_rounded,
                        iconColor: const Color(0xFF9B59B6),
                        title: _label(locale, 'Partager Kendjino',
                            'Pataje Kendjino', 'Share Kendjino'),
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Legal ─────────────────────────────────────────────────
                  _SectionLabel(
                    label: _label(locale, 'Légal', 'Legal', 'Legal'),
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.description_rounded,
                        iconColor: AppTheme.textMuted,
                        title: _label(locale, 'Conditions d\'utilisation',
                            'Kondisyon itilizasyon', 'Terms of Service'),
                        onTap: () {},
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.privacy_tip_rounded,
                        iconColor: AppTheme.textMuted,
                        title: _label(locale, 'Politique de confidentialité',
                            'Règleman konfidansyalite', 'Privacy Policy'),
                        onTap: () {},
                      ),
                      _SettingsDivider(),
                      _SettingsTile(
                        icon: Icons.gavel_rounded,
                        iconColor: AppTheme.textMuted,
                        title: _label(locale, 'Licences open source',
                            'Lisans open source', 'Open Source Licenses'),
                        onTap: () => showLicensePage(context: context),
                      ),
                    ],
                  ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── App Version ───────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Kendjino EXCHANGE',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'v${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  // ── Logout ────────────────────────────────────────────────
                  _LogoutButton(locale: locale)
                      .animate()
                      .fadeIn(delay: 420.ms, duration: 400.ms),

                  const SizedBox(height: 12),

                  // ── Delete Account ────────────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          _showDeleteAccountDialog(context, locale),
                      child: Text(
                        _label(locale, 'Supprimer mon compte',
                            'Efase kont mwen', 'Delete my account'),
                        style: TextStyle(
                          color: AppTheme.errorRed,
                          fontSize: 13,
                          fontFamily: 'Satoshi',
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 440.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _label(Locale? locale, String fr, String ht, String en) {
    switch (locale?.languageCode) {
      case 'ht':
        return ht;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  String _localeName(Locale? locale) {
    switch (locale?.languageCode) {
      case 'ht':
        return 'Kreyòl Ayisyen';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }

  String _kycLabel(dynamic status, Locale? locale) {
    switch (status?.toString().split('.').last) {
      case 'verified':
        return _label(locale, 'Vérifié ✓', 'Verifye ✓', 'Verified ✓');
      case 'submitted':
        return _label(locale, 'En cours...', 'Ap trete...', 'In progress...');
      case 'rejected':
        return _label(locale, 'Rejeté — Réessayez', 'Rejte — Eseye ankò',
            'Rejected — Retry');
      default:
        return _label(locale, 'Non vérifié', 'Pa verifye', 'Not verified');
    }
  }

  void _showExportSheet(BuildContext context, Locale? locale) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ExportSheet(locale: locale),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, Locale? locale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _label(locale, 'Supprimer le compte', 'Efase kont', 'Delete Account'),
          style: const TextStyle(
              fontFamily: 'Satoshi', fontWeight: FontWeight.w700),
        ),
        content: Text(
          _label(
            locale,
            'Cette action est irréversible. Toutes vos données seront supprimées.',
            'Aksyon sa pa ka defèt. Tout done ou pral efase.',
            'This action is irreversible. All your data will be deleted.',
          ),
          style: const TextStyle(fontFamily: 'Satoshi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_label(locale, 'Annuler', 'Anile', 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // ref.read(authProvider.notifier).deleteAccount();
            },
            child: Text(
              _label(locale, 'Supprimer', 'Efase', 'Delete'),
              style: const TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context, ThemeData theme, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.currency_exchange,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text('Kendjino EXCHANGE', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Version ${AppConstants.appVersion}',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                'Fintech pour Haïti 🇭🇹',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Card ────────────────────────────────────────────────────────────
class _ProfileCard extends ConsumerWidget {
  final dynamic user;
  final Locale? locale;

  const _ProfileCard({this.user, this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(RouteNames.profile),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 1.5),
              ),
              child: Center(
                child: Text(
                  _getInitials(user?.fullName ?? user?.phoneNumber),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Satoshi',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Satoshi',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user?.phoneNumber ?? '+509 __ __ __ __',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Satoshi',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _KycBadgeWhite(status: user?.kycStatus),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// ─── KYC Badge ───────────────────────────────────────────────────────────────
class _KycBadge extends StatelessWidget {
  final dynamic status;
  const _KycBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Satoshi',
        ),
      ),
    );
  }

  (Color, String) _resolve() {
    switch (status?.toString().split('.').last) {
      case 'verified':
        return (AppTheme.successGreen, 'VÉRIFIÉ');
      case 'submitted':
        return (AppTheme.warningOrange, 'EN COURS');
      case 'rejected':
        return (AppTheme.errorRed, 'REJETÉ');
      default:
        return (AppTheme.textMuted, 'NON VÉRIFIÉ');
    }
  }
}

class _KycBadgeWhite extends StatelessWidget {
  final dynamic status;
  const _KycBadgeWhite({this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status?.toString().split('.').last) {
      'verified' => '✓ Compte vérifié',
      'submitted' => '⏳ Vérification en cours',
      'rejected' => '✗ Vérification rejetée',
      _ => '○ Non vérifié',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Satoshi',
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Settings Card ────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE8EDF2),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF2F7),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Biometric Toggle Tile ────────────────────────────────────────────────────
class _BiometricTile extends ConsumerWidget {
  final Locale? locale;
  const _BiometricTile({this.locale});

  String _label(String fr, String ht, String en) {
    switch (locale?.languageCode) {
      case 'ht':
        return ht;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fingerprint_rounded,
                color: AppTheme.primaryGreen, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label('Biométrie', 'Byometri', 'Biometrics'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _label('Empreinte / Face ID', 'Anprint / Face ID',
                      'Fingerprint / Face ID'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: biometricEnabled,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              ref.read(biometricEnabledProvider.notifier).toggle();
            },
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}

// ─── Dark Mode Toggle Tile ────────────────────────────────────────────────────
class _ThemeModeTile extends ConsumerWidget {
  final Locale? locale;
  final ThemeMode themeMode;
  final bool isDark;

  const _ThemeModeTile({
    this.locale,
    required this.themeMode,
    required this.isDark,
  });

  String _label(String fr, String ht, String en) {
    switch (locale?.languageCode) {
      case 'ht':
        return ht;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF5352ED).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: const Color(0xFF5352ED),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label('Mode sombre', 'Mòd nwa', 'Dark Mode'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark
                      ? _label('Activé', 'Aktive', 'Enabled')
                      : _label('Désactivé', 'Dezaktive', 'Disabled'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              ref.read(themeModeProvider.notifier).toggle();
            },
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}

// ─── Currency Selector Tile ───────────────────────────────────────────────────
class _CurrencyTile extends ConsumerWidget {
  final Locale? locale;
  const _CurrencyTile({this.locale});

  String _label(String fr, String ht, String en) {
    switch (locale?.languageCode) {
      case 'ht':
        return ht;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(defaultCurrencyProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCurrencyPicker(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.monetization_on_rounded,
                    color: AppTheme.accentGold, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label('Devise par défaut', 'Monnaie pa defo',
                          'Default Currency'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currency,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final currencies = ['HTG', 'USD', 'USDT', 'BTC'];
        final current = ref.read(defaultCurrencyProvider);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _label(
                    'Choisir la devise', 'Chwazi monnaie', 'Choose Currency'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...currencies.map((c) => ListTile(
                    onTap: () {
                      ref.read(defaultCurrencyProvider.notifier).set(c);
                      Navigator.pop(ctx);
                    },
                    title: Text(c,
                        style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w600)),
                    trailing: current == c
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppTheme.primaryGreen)
                        : null,
                  )),
            ],
          ),
        );
      },
    );
  }
}

// ─── Notification Toggle Tile ────────────────────────────────────────────────
class _NotificationTile extends ConsumerWidget {
  final Locale? locale;
  const _NotificationTile({this.locale});

  String _label(String fr, String ht, String en) {
    switch (locale?.languageCode) {
      case 'ht':
        return ht;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsEnabledProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4757).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_rounded,
                color: Color(0xFFFF4757), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label('Notifications', 'Notifikasyon', 'Notifications'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? _label('Activées', 'Aktive', 'Enabled')
                      : _label('Désactivées', 'Dezaktive', 'Disabled'),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              ref.read(notificationsEnabledProvider.notifier).toggle();
            },
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}

// ─── Export Sheet ─────────────────────────────────────────────────────────────
class _ExportSheet extends StatelessWidget {
  final Locale? locale;
  const _ExportSheet({this.locale});

  String _label(String fr, String ht, String en) {
    switch (locale?.languageCode) {
      case 'ht':
        return ht;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _label('Exporter les transactions', 'Ekspòte tranzaksyon',
                'Export Transactions'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            _label(
              'Choisissez la période et le format',
              'Chwazi peryòd ak fòma',
              'Choose the period and format',
            ),
            style:
                theme.textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
          _ExportOption(
            icon: Icons.picture_as_pdf_rounded,
            color: AppTheme.errorRed,
            label:
                _label('Exporter en PDF', 'Ekspòte nan PDF', 'Export as PDF'),
            subtitle:
                _label('30 derniers jours', '30 dènye jou', 'Last 30 days'),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          _ExportOption(
            icon: Icons.table_chart_rounded,
            color: const Color(0xFF1DB954),
            label:
                _label('Exporter en CSV', 'Ekspòte nan CSV', 'Export as CSV'),
            subtitle: _label('Toute la période', 'Tout peryòd la', 'All time'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.download_rounded, color: AppTheme.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────
class _LogoutButton extends ConsumerWidget {
  final Locale? locale;
  const _LogoutButton({this.locale});

  String _label(String fr, String ht, String en) {
    switch (locale?.languageCode) {
      case 'ht':
        return ht;
      case 'en':
        return en;
      default:
        return fr;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorRed,
          side: const BorderSide(color: AppTheme.errorRed, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(
          _label('Se déconnecter', 'Dekonekte', 'Log Out'),
          style: const TextStyle(
              fontFamily: 'Satoshi', fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _label('Déconnexion', 'Dekoneksyon', 'Log Out'),
          style: const TextStyle(
              fontFamily: 'Satoshi', fontWeight: FontWeight.w700),
        ),
        content: Text(
          _label(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            'Eske ou sèten ou vle dekonekte ?',
            'Are you sure you want to log out?',
          ),
          style: const TextStyle(fontFamily: 'Satoshi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_label('Annuler', 'Anile', 'Cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(RouteNames.onboarding);
            },
            child: Text(
              _label('Déconnecter', 'Dekonekte', 'Log Out'),
              style: const TextStyle(
                  color: AppTheme.errorRed,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Providers (stubs — replace with real Riverpod providers) ─────────────────
// These would normally live in presentation/providers/
final biometricEnabledProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (_) => _BoolNotifier(false),
);
final notificationsEnabledProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (_) => _BoolNotifier(true),
);
final defaultCurrencyProvider = StateNotifierProvider<_StringNotifier, String>(
  (_) => _StringNotifier('HTG'),
);

class _BoolNotifier extends StateNotifier<bool> {
  _BoolNotifier(super.state);
  void toggle() => state = !state;
}

class _StringNotifier extends StateNotifier<String> {
  _StringNotifier(super.state);
  void set(String val) => state = val;
}
