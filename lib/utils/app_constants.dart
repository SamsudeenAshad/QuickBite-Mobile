class AppConstants {
  AppConstants._();

  static const String appName = 'QuickBite Café';
  static const String databaseName = 'quickbite_cafe.db';
  static const int databaseVersion = 4;

  static const double deliveryCharge = 200;
  static const double loyaltyPointSpend = 100;

  static const String allCategory = 'All';
  static const String burgersCategory = 'Burgers';
  static const String pizzaCategory = 'Pizza';
  static const String drinksCategory = 'Drinks';
  static const String dessertsCategory = 'Desserts';

  static const List<String> productCategories = <String>[
    burgersCategory,
    pizzaCategory,
    drinksCategory,
    dessertsCategory,
  ];

  static const List<String> menuCategories = <String>[
    allCategory,
    ...productCategories,
  ];

  static const String cashOnDelivery = 'Cash on Delivery';
  static const String cardPayment = 'Credit/Debit Card';
  static const String digitalWallet = 'Digital Wallet';

  static const List<String> paymentMethods = <String>[
    cashOnDelivery,
    cardPayment,
    digitalWallet,
  ];

  static const String orderStatusPreparing = 'Preparing';
  static const String orderStatusCompleted = 'Completed';
  static const String orderStatusCancelled = 'Cancelled';
  static const String orderStatusConfirmed = 'Confirmed';
  static const String orderStatusRejected = 'Rejected';
  static const String orderStatusDelivered = 'Delivered';

  static const List<String> adminOrderStatuses = <String>[
    orderStatusPreparing,
    orderStatusConfirmed,
    orderStatusRejected,
    orderStatusDelivered,
  ];

  static const String promotionTitle = 'Weekend Special';
  static const String promotionDescription =
      'Get 20% OFF selected burgers this weekend.';
  static const String promotionCode = 'QUICK20';
}
