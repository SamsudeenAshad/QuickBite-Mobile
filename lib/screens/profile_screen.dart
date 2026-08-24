import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../models/app_user.dart';
import '../theme/app_theme.dart';
import 'promotions_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onOpenOrders,
    this.user,
    this.onLogout,
  });

  final VoidCallback onOpenOrders;
  final AppUser? user;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding = constraints.maxWidth >= 720
                ? 32
                : 16;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ProfileIdentityCard(user: user),
                      const SizedBox(height: 16),
                      Consumer<OrderProvider>(
                        builder:
                            (
                              BuildContext context,
                              OrderProvider orderProvider,
                              Widget? child,
                            ) {
                              return _LoyaltyCard(
                                points: orderProvider.loyaltyPoints,
                                isLoading: orderProvider.isLoading,
                                errorMessage: orderProvider.loyaltyErrorMessage,
                                onRetry: orderProvider.loadOrders,
                              );
                            },
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Quick links',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _ProfileOptions(
                        onOpenOrders: onOpenOrders,
                        onOpenPromotions: () => _openPromotions(context),
                        onShowAbout: () => _showAbout(context),
                        onLogout: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openPromotions(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PromotionsScreen(),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'QuickBite Café',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.local_cafe_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: const <Widget>[
        Text(
          'A simple local café ordering experience created as an undergraduate Flutter project.',
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.logout_rounded),
          title: const Text('Log out of QuickBite?'),
          content: const Text('You will return to the sign-in screen.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await onLogout?.call();
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final String name = user?.name ?? 'Samsudeen Ashad';
    final String phone = user?.phone ?? '077 123 4567';
    final String email = user?.email ?? 'samsudeenashad@example.com';
    final String initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Semantics(
      container: true,
      label: 'Profile for $name. Phone $phone. Email $email.',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      _ContactLine(icon: Icons.phone_outlined, value: phone),
                      const SizedBox(height: 7),
                      _ContactLine(
                        icon: Icons.mail_outline_rounded,
                        value: email,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  const _LoyaltyCard({
    required this.points,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final int points;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final String loadingLabel = isLoading ? ' Updating points.' : '';

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label:
          'QuickBite loyalty. Your points: $points. Earn 1 point for every 100 rupees spent on non-cancelled orders.$loadingLabel',
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: .20),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'QuickBite loyalty',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'YOUR POINTS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: .78),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$points',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Earn 1 point for every Rs. 100 spent on non-cancelled orders.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.white.withValues(alpha: .88)),
                  ),
                ],
              ),
            ),
            if (errorMessage != null) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Points may be out of date.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Retry loading loyalty points',
                      child: ExcludeSemantics(
                        child: TextButton(
                          onPressed: onRetry,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            minimumSize: const Size(48, 48),
                          ),
                          child: const Text('Retry'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileOptions extends StatelessWidget {
  const _ProfileOptions({
    required this.onOpenOrders,
    required this.onOpenPromotions,
    required this.onShowAbout,
    required this.onLogout,
  });

  final VoidCallback onOpenOrders;
  final VoidCallback onOpenPromotions;
  final VoidCallback onShowAbout;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          _ProfileOption(
            icon: Icons.receipt_long_outlined,
            title: 'My orders',
            subtitle: 'View your order history',
            semanticsLabel: 'Open My Orders',
            onTap: onOpenOrders,
          ),
          const Divider(),
          _ProfileOption(
            icon: Icons.local_offer_outlined,
            title: 'Promotions',
            subtitle: 'See current demo offers',
            semanticsLabel: 'Open Promotions',
            onTap: onOpenPromotions,
          ),
          const Divider(),
          _ProfileOption(
            icon: Icons.storefront_outlined,
            title: 'About QuickBite',
            subtitle: 'Learn more about this café app',
            semanticsLabel: 'Open About QuickBite',
            onTap: onShowAbout,
          ),
          const Divider(),
          _ProfileOption(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Return to sign in',
            semanticsLabel: 'Log out of QuickBite',
            foregroundColor: AppColors.danger,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.semanticsLabel,
    required this.onTap,
    this.foregroundColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final Color color = foregroundColor ?? AppColors.textPrimary;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: ListTile(
          minVerticalPadding: 12,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: foregroundColor == null
                  ? AppColors.surfaceMuted
                  : AppColors.danger.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: foregroundColor ?? AppColors.textSecondary,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
