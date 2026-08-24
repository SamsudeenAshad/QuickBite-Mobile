import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

class PromotionBanner extends StatefulWidget {
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
  State<PromotionBanner> createState() => _PromotionBannerState();
}

class _PromotionBannerState extends State<PromotionBanner>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _reduceMotion = false;

  List<_PromotionSlide> get _slides => <_PromotionSlide>[
    _PromotionSlide(
      title: widget.title,
      description: widget.description,
      code: widget.code,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=1400&q=88',
    ),
    const _PromotionSlide(
      title: 'Coffee Break',
      description: 'Save Rs. 150 with an iced coffee and chocolate cake.',
      code: 'BREW150',
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=1400&q=88',
    ),
    const _PromotionSlide(
      title: 'Pizza Night',
      description: 'Get a free orange juice when you order any two pizzas.',
      code: 'PIZZANIGHT',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=1400&q=88',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion != reduceMotion || _autoPlayTimer == null) {
      _reduceMotion = reduceMotion;
      _configureAutoPlay();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _configureAutoPlay();
    } else {
      _autoPlayTimer?.cancel();
    }
  }

  void _configureAutoPlay() {
    _autoPlayTimer?.cancel();
    if (_reduceMotion) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      final int nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<_PromotionSlide> slides = _slides;
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    final double bannerHeight = textScale > 1.3 ? 330 : 286;

    return Semantics(
      container: true,
      liveRegion: true,
      label:
          'Promotion ${_currentPage + 1} of ${slides.length}. '
          '${slides[_currentPage].title}. ${slides[_currentPage].description}. '
          'Promo code ${slides[_currentPage].code}. Swipe for more offers.',
      child: ExcludeSemantics(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: bannerHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
                    _configureAutoPlay();
                  },
                  itemBuilder: (context, index) =>
                      _PromotionSlideCard(slide: slides[index]),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(slides.length, (int index) {
                final bool selected = index == _currentPage;
                return AnimatedContainer(
                  duration: _reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  width: selected ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionSlideCard extends StatelessWidget {
  const _PromotionSlideCard({required this.slide});

  final _PromotionSlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.network(
          slide.imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) => const ColoredBox(
            color: AppColors.secondary,
            child: Icon(
              Icons.restaurant_rounded,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: <double>[0, .58, 1],
              colors: <Color>[
                Color(0xF216100D),
                Color(0xC7130E0B),
                Color(0x52130E0B),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .24),
                      ),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    slide.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: const <Shadow>[
                        Shadow(color: Colors.black54, blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    slide.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      shadows: const <Shadow>[
                        Shadow(color: Colors.black87, blurRadius: 7),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'CODE',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          slide.code,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .7,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromotionSlide {
  const _PromotionSlide({
    required this.title,
    required this.description,
    required this.code,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String code;
  final String imageUrl;
}
