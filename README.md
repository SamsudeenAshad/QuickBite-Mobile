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
