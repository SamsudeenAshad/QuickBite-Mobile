enum PromotionCategory { burgers, coffee, pizza }

class Promotion {
  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.availability,
    required this.terms,
    required this.category,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String description;
  final String code;
  final String availability;
  final String terms;
  final PromotionCategory category;
  final bool isFeatured;
}
