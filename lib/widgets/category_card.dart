import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = selected
        ? AppColors.primaryContainer
        : Theme.of(context).colorScheme.surface;
    final Color foregroundColor = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title category',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
              blurRadius: selected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 104),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: selected ? Colors.white : AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: foregroundColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
