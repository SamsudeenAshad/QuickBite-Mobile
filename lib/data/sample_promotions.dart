import '../models/promotion.dart';

const List<Promotion> samplePromotions = <Promotion>[
  Promotion(
    id: 'weekend-special',
    title: 'Weekend Special',
    description: 'Enjoy 20% off selected burgers all weekend.',
    code: 'QUICK20',
    availability: 'Friday to Sunday',
    terms: 'Valid on selected burgers while stocks last.',
    category: PromotionCategory.burgers,
    isFeatured: true,
  ),
  Promotion(
    id: 'coffee-break',
    title: 'Coffee Break',
    description:
        'Save Rs. 150 when you pair an iced coffee with chocolate cake.',
    code: 'BREW150',
    availability: 'Weekdays, 2:00 PM–5:00 PM',
    terms: 'One offer per order. Available on the featured pair only.',
    category: PromotionCategory.coffee,
  ),
  Promotion(
    id: 'pizza-night',
    title: 'Pizza Night',
    description: 'Receive one orange juice when you order any two pizzas.',
    code: 'PIZZANIGHT',
    availability: 'Wednesdays after 5:00 PM',
    terms: 'Applies to two full-price pizzas and one regular orange juice.',
    category: PromotionCategory.pizza,
  ),
];
