import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

class PromotionBanner extends StatelessWidget {
  const PromotionBanner({
    super.key,
    this.title = AppConstants.promotionTitle,
    this.description = AppConstants.promotionDescription,
    this.code = AppConstants.promotionCode,
  });

  final String title;
  final String description;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Promotion. $title. $description. Promo code $code.',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.secondary, AppColors.primary],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Widget details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Colors.white, height: 1.4),
                ),
              ],
            );

            final Widget codeLabel = Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'PROMO CODE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    code,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );

            return ExcludeSemantics(
              child: constraints.maxWidth < 430
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(
                          Icons.local_offer_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 14),
                        details,
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: codeLabel,
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: details),
                        const SizedBox(width: 20),
                        codeLabel,
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
