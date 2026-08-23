# QuickBite Café

QuickBite Café is a small, beginner-friendly Flutter ordering application for an
undergraduate mobile development project. It uses a warm Material 3 interface,
Provider state management, and a local SQLite database. The Android application
does not require a backend or user account.

## Implemented features

- Two-second branded splash screen and responsive five-tab navigation
- Home page with search, categories, popular products, and a promotion banner
- Full menu with text search, category filters, product details, ratings, and
  quantity selection
- Persistent SQLite cart with add, increase, decrease, remove, subtotal,
  delivery charge, and total calculations
- Checkout form with Cash on Delivery, Credit/Debit Card, and Digital Wallet
  choices
- Customer, phone, address, card number, expiry date, and CVV validation
- Simulated order placement, confirmation details, and persistent order history
- Promotions page with copyable demo codes
- Loyalty points calculated at 1 point for every Rs. 100 spent on non-cancelled
  orders
- Demo profile, About dialog, and clearly explained mock Logout action
- Loading, empty, error, retry, responsive layout, and accessibility states

## Main application flow

1. Browse or search for a menu item.
2. Open its details, choose a quantity, and add it to the cart.
3. Review the cart and proceed to checkout.
4. Enter delivery details and select a simulated payment method.
5. Place the order and view its confirmation.
6. Follow saved orders from the Orders tab and loyalty points from Profile.

## Technology and architecture

The project deliberately uses a simple layered structure so students can trace
data from a screen to SQLite without unnecessary enterprise architecture.

| Layer | Responsibility |
| --- | --- |
| Screens and widgets | Material 3 interface, navigation, forms, and reusable UI |
| Providers | UI state, loading/error states, cart changes, and order actions |
| Repositories | Product, cart, and order database operations |
| `DatabaseService` | Opens SQLite, creates tables, and seeds sample products |
| Models and data | Typed products, cart items, orders, promotions, and mock data |

Provider supplies `ProductProvider`, `CartProvider`, `OrderProvider`, and
`NavigationProvider` through the app root. Repositories keep SQL outside the UI.
SQLite stores the following local data:

- `products`: seeded the first time the database is created
- `cart_items`: persistent product IDs and quantities
- `orders`: customer delivery details, total, payment method, status, and date

Order placement runs in one SQLite transaction. It calculates the authoritative
total from the saved cart, inserts the order, and clears the cart together. If
one step fails, the transaction is rolled back.

## Run on Android

### Prerequisites

- Flutter SDK with Dart 3.13.1 or newer
- Android Studio with the Flutter and Dart plugins
- Android SDK, Platform Tools, and either an Android emulator or a USB-connected
  Android device with developer mode enabled

Run `flutter doctor` first and resolve any Android toolchain warnings that apply
to your machine.

### Android Studio

1. Open the project directory that contains `pubspec.yaml`.
2. Allow Android Studio to fetch Flutter packages, or run `flutter pub get` in
   its Terminal window.
3. Open Device Manager and start an emulator, or connect a physical Android
   device.
4. Select the device in the toolbar.
5. Open `lib/main.dart` and choose **Run**.

Android Studio can also provide hot reload while the app is running.

### Command line

From the project root, run:

```bash
flutter doctor
flutter pub get
flutter devices
flutter run
```

If several devices are available, use the identifier shown by `flutter devices`:

```bash
flutter run -d <device-id>
```

## Simulated payment and privacy

This coursework application does **not** contact a payment gateway or process a
real bank transaction. Cash, card, and wallet selections only demonstrate the
checkout flow.

When card payment is selected, the cardholder name, number, expiry date, and CVV
are validated in the form. These values stay inside the checkout screen and are
not sent to a provider, written to SQLite, or included in the saved order. Do not
enter real payment details when demonstrating the app.

The profile and Logout option are also demonstrations; the application has no
real authentication or remote account.

## Project structure

```text
android/                    Android runner and Gradle configuration
lib/
  main.dart                Application entry point
  app.dart                 Theme, providers, and initial navigation
  data/                    Sample products and promotions
  models/                  Product, cart, order, and promotion models
  providers/               Provider/ChangeNotifier state
  repositories/            SQLite data access
  screens/                 App screens and main navigation shell
  services/                SQLite database setup
  theme/                   Material 3 theme and café color tokens
  utils/                   Constants, validators, and currency formatting
  widgets/                 Reusable cards, images, banners, and navigation
test/                      Unit and widget tests
```

## Validation and tests

The included tests cover models, currency formatting, form validators, tab
navigation, the splash screen, the Material 3 theme, empty-cart protection,
checkout protection, promotions, profile loyalty points, and order history.

Use the following checks before a demonstration or coursework submission:

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Run the application on your configured Android emulator or physical device as
the final platform check. No APK build result is claimed in this document.

## Demo data and network images

- Products, promotions, profile details, and initial prices are sample data.
- Promotion codes are informational and are not automatically applied to an
  order total.
- Product photos load from Unsplash over HTTPS, so they need an internet
  connection. The UI displays a café placeholder if an image cannot load.
- Products, cart entries, and orders remain local in SQLite; there is no cloud
  synchronization.
- To start with a new demo database, clear the app's storage or uninstall and
  reinstall it on the emulator/device.

---

## Original assignment specification

The original project brief is preserved below for coursework reference.

# QuickBite-Cafe

# Build a Simple Flutter Mobile App – QuickBite Café

Act as a **Flutter mobile application developer and UI/UX designer**.

Create a simple but complete Android mobile application called **QuickBite Café**.

## Scenario

QuickBite Café is a small local café that wants a mobile application where customers can:

* View available food and drinks
* Browse products by category
* View product details
* Add products to a cart
* Place an order
* Select a payment method
* Receive an order confirmation
* View current promotions
* Earn simple loyalty points

The project should remain **small and easy to understand** because it is an undergraduate mobile application development project.

---

# Technology

Use:

* Flutter
* Dart
* Material 3
* Provider or Riverpod for simple state management
* SQLite using `sqflite` for local database storage

Do not create an unnecessarily complicated backend.

Use local/mock data where appropriate.

The project must run on Android.

---

# Main Screens

Create approximately **7 main screens**.

### 1. Splash Screen

Display:

* QuickBite Café logo
* App name
* Small loading animation

After around 2 seconds navigate to the Home screen.

---

### 2. Home Screen

Display:

* Welcome message
* Search bar
* Food categories
* Popular products
* Promotion banner
* Bottom navigation bar

Categories:

* Burgers
* Pizza
* Drinks
* Desserts

Use attractive food cards containing:

* Image
* Name
* Price
* Rating
* Add button

---

### 3. Products Screen

Display all available products.

Allow users to filter products by category.

Example products:

* Chicken Burger
* Cheese Burger
* Chicken Pizza
* Vegetable Pizza
* Iced Coffee
* Orange Juice
* Chocolate Cake

Each product must have:

* ID
* Name
* Description
* Category
* Price
* Image
* Rating

---

### 4. Product Details Screen

Display:

* Large product image
* Product name
* Price
* Description
* Rating
* Quantity selector
* Add to Cart button

When the user adds the product, show a Snackbar such as:

"Added to cart successfully."

---

### 5. Cart Screen

Display all selected products.

Allow users to:

* Increase quantity
* Decrease quantity
* Delete products
* View subtotal
* View delivery charge
* View total amount

Add a:

**Proceed to Checkout**

button.

---

### 6. Checkout and Payment Screen

Collect:

* Customer name
* Phone number
* Delivery address

Provide payment methods:

* Cash on Delivery
* Credit/Debit Card
* Digital Wallet

For the student project, payment processing can be a **safe simulated payment flow** instead of processing real bank transactions.

If Card Payment is selected, display:

* Cardholder name
* Card number
* Expiry date
* CVV

Validate all fields.

Do not store sensitive card information.

Add a:

**Place Order**

button.

---

### 7. Order Confirmation Screen

After successfully placing the order display:

* Success icon
* "Order Placed Successfully"
* Order number
* Order total
* Payment method
* Estimated preparation time

Example:

Order ID: QB1025

Estimated preparation time: 20–30 minutes.

Include:

**Back to Home**

button.

---

# Additional Feature – Promotions

Add a Promotions section.

Example:

### Weekend Special

20% OFF selected burgers.

Promo Code:

QUICK20

Display promotions using attractive cards or banners.

---

# Additional Feature – Loyalty Points

Create a simple loyalty system.

Example:

For every Rs. 100 spent:

User receives **1 loyalty point**.

Display loyalty points on the Profile screen.

Example:

"Your Points: 42"

No complicated reward system is needed.

---

# Bottom Navigation

Create bottom navigation with:

* Home
* Menu
* Cart
* Orders
* Profile

Use clear Material icons.

---

# Order History

Create a simple Orders screen.

Display:

* Order ID
* Date
* Total
* Status

Statuses can include:

* Preparing
* Completed
* Cancelled

Save order history in SQLite.

---

# Profile Screen

Display:

* User name
* Phone
* Email
* Loyalty points

Include simple menu options:

* My Orders
* Promotions
* About QuickBite
* Logout

No advanced authentication is required.

---

# Database

Use SQLite for:

## Products

Fields:

* id
* name
* description
* category
* price
* image
* rating

## Cart Items

Fields:

* id
* productId
* quantity

## Orders

Fields:

* id
* customerName
* phone
* address
* total
* paymentMethod
* status
* createdAt

Use repository/service classes so database logic is separated from UI code.

---

# Recommended Project Structure

```text
lib/
  main.dart

  models/
    product.dart
    cart_item.dart
    order.dart

  screens/
    splash_screen.dart
    home_screen.dart
    products_screen.dart
    product_details_screen.dart
    cart_screen.dart
    checkout_screen.dart
    order_confirmation_screen.dart
    orders_screen.dart
    profile_screen.dart

  widgets/
    product_card.dart
    category_card.dart
    promotion_banner.dart
    custom_bottom_navigation.dart

  providers/
    cart_provider.dart
    product_provider.dart
    order_provider.dart

  services/
    database_service.dart

  data/
    sample_products.dart

  theme/
    app_theme.dart
```

---

# UI Design

Create a modern café-style UI.

Use a clean visual style with:

* Rounded cards
* Good spacing
* Large product images
* Modern typography
* Smooth page transitions
* Material icons
* Clear buttons
* Consistent theme
* Responsive layout

Suggested visual direction:

* Warm café aesthetic
* Off-white background
* Dark text
* Orange/brown primary accents
* Rounded 16–20px cards
* Subtle shadows

Avoid making the interface look like a basic tutorial app.

Make it feel like a small real-world food delivery application.

---

# Validation

Implement validation for:

* Empty customer name
* Invalid phone number
* Empty delivery address
* Invalid card number
* Invalid expiry date
* Invalid CVV
* Empty cart

Display user-friendly error messages.

---

# Important Development Requirements

The application must demonstrate these five main coursework areas:

1. **Display of products/services**
2. **Order processing**
3. **Payment options**
4. **Additional features such as promotions and loyalty points**
5. **Professional UI/UX**

Also demonstrate:

* Local database integration
* Form validation
* Navigation
* State management
* Reusable widgets
* Error handling

---

# Coding Requirements

Write clean beginner-friendly Flutter code.

Do not overengineer the application.

Use:

* Null safety
* Reusable widgets
* Proper folder structure
* Clear class names
* Comments only where useful
* Async/await correctly
* Proper loading and error states

Avoid unnecessary enterprise architecture.

---

# Development Process

Build the application in stages.

## Phase 1

Create:

* Flutter project structure
* Theme
* Models
* Sample data

## Phase 2

Create:

* Splash Screen
* Home Screen
* Menu/Product Screen
* Product Details

## Phase 3

Implement:

* Cart
* State management
* Quantity management

## Phase 4

Implement:

* Checkout
* Payment selection
* Validation
* Order confirmation

## Phase 5

Implement:

* SQLite
* Order history
* Loyalty points
* Promotions

## Phase 6

Improve:

* UI/UX
* Navigation
* Error handling
* Responsive design
* Code organization

After each phase, ensure the application builds successfully before continuing.

---

# Final Result

The final result should be a **simple, polished, fully functional Flutter Android café ordering application** suitable for an undergraduate mobile application development assignment.

Prioritize:

**Working functionality > unnecessary complexity.**

Generate the project files and implementation progressively rather than placing the entire application into one huge file.
