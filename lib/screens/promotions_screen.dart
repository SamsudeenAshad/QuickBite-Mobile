import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/sample_promotions.dart';
import '../models/promotion.dart';
import '../theme/app_theme.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
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
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const _PromotionHeader(),
                      const SizedBox(height: 16),
                      const _InformationBanner(),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder:
                            (
                              BuildContext context,
                              BoxConstraints cardConstraints,
                            ) {
                              final bool useTwoColumns =
                                  cardConstraints.maxWidth >= 680;
                              final double cardWidth = useTwoColumns
                                  ? (cardConstraints.maxWidth - 16) / 2
                                  : cardConstraints.maxWidth;

                              return Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: samplePromotions.map((promotion) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: _PromotionCard(
                                      promotion: promotion,
                                    ),
                                  );
                                }).toList(growable: false),
                              );
                            },
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
}

class _PromotionHeader extends StatelessWidget {
  const _PromotionHeader();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'A little extra to enjoy',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Browse the café offers currently featured in this student demo.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationBanner extends StatelessWidget {
  const _InformationBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Demo information. Promotion codes are informational and are not applied automatically at checkout.',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: .22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Demo offers only. Codes are informational and are not applied automatically at checkout.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promotion});

  final Promotion promotion;

  @override
  Widget build(BuildContext context) {
    final _PromotionVisual visual = _visualFor(promotion.category);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label:
          '${promotion.title}. ${promotion.description} Code ${promotion.code}. Available ${promotion.availability}. ${promotion.terms}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: visual.tint,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(visual.icon, color: visual.color, size: 28),
                    ),
                    const Spacer(),
                    if (promotion.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'FEATURED',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: visual.color,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .7,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ExcludeSemantics(
                    child: Text(
                      promotion.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ExcludeSemantics(
                    child: Text(
                      promotion.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PromotionFact(
                    icon: Icons.schedule_outlined,
                    label: promotion.availability,
                  ),
                  const SizedBox(height: 10),
                  _PromotionFact(
                    icon: Icons.rule_outlined,
                    label: promotion.terms,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: <Widget>[
                        ExcludeSemantics(
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'PROMO CODE',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: .7,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                SelectableText(
                                  promotion.code,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: visual.color,
                                        letterSpacing: 1.1,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Semantics(
                            button: true,
                            label: 'Copy promo code ${promotion.code}',
                            child: ExcludeSemantics(
                              child: IconButton.filledTonal(
                                tooltip: 'Copy code',
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                onPressed: () => _copyCode(context),
                                icon: const Icon(Icons.copy_rounded),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: promotion.code));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${promotion.code} copied to the clipboard.')),
      );
  }
}

class _PromotionFact extends StatelessWidget {
  const _PromotionFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionVisual {
  const _PromotionVisual({
    required this.icon,
    required this.color,
    required this.tint,
  });

  final IconData icon;
  final Color color;
  final Color tint;
}

_PromotionVisual _visualFor(PromotionCategory category) {
  switch (category) {
    case PromotionCategory.burgers:
      return const _PromotionVisual(
        icon: Icons.lunch_dining_rounded,
        color: AppColors.primary,
        tint: AppColors.primaryContainer,
      );
    case PromotionCategory.coffee:
      return const _PromotionVisual(
        icon: Icons.local_cafe_rounded,
        color: AppColors.secondary,
        tint: AppColors.surfaceMuted,
      );
    case PromotionCategory.pizza:
      return _PromotionVisual(
        icon: Icons.local_pizza_rounded,
        color: AppColors.success,
        tint: AppColors.success.withValues(alpha: .10),
      );
  }
}
