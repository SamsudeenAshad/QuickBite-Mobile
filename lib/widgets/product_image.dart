import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imageUrl;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        final int? expectedBytes = loadingProgress.expectedTotalBytes;
        final double? progress = expectedBytes == null || expectedBytes <= 0
            ? null
            : (loadingProgress.cumulativeBytesLoaded / expectedBytes)
                  .clamp(0.0, 1.0)
                  .toDouble();

        return _ImagePlaceholder(
          width: width,
          height: height,
          child: SizedBox.square(
            dimension: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5, value: progress),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _ImagePlaceholder(
          width: width,
          height: height,
          child: Icon(
            Icons.restaurant_menu_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return Semantics(image: true, label: semanticLabel, child: image);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.width,
    required this.height,
    required this.child,
  });

  final double? width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.primaryContainer
            .withValues(alpha: 0.55),
        child: Center(child: child),
      ),
    );
  }
}
