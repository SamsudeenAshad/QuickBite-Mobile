# Villi’s Cafe — 15-minute presentation guide

The PowerPoint contains full speaker notes. This page is a quick rehearsal checklist.

## Timing

| Time | Section | Slides |
| --- | --- | --- |
| 0:00–5:15 | Problem, solution, architecture, and OOP | 1–5 |
| 5:15–10:30 | Recorded live system demonstration | 6–9 |
| 10:30–15:00 | Contribution, technology choices, risks, and conclusion | 10–13 |
| Backup | Recovery screenshots and technical evidence | 14–15 |

## Recorded demo path

1. Start the recording before switching to the emulator.
2. Sign in with a prepared local customer account.
3. Home: identify search, promotions, and categories.
4. Menu: filter/search, open product details, change quantity, and add to cart.
5. Cart: explain subtotal, delivery charge, and total.
6. Checkout: demonstrate validation, choose Cash on Delivery, and place the simulated order.
7. Confirmation: show order number, total, payment method, and status.
8. Orders/Profile: show saved history and loyalty points.
9. Chat: send or identify a customer message.
10. Log out and sign in as the local administrator.
11. Admin: show product management, order status controls, and chat replies.
12. Return to slide 10 for the individual-contribution section.

## Before recording

- Run `flutter analyze` and `flutter test`.
- Launch the app and confirm product images or placeholders are visible.
- Prepare one customer account and the local administrator login.
- Keep the repository open at `OrderRepository.placeOrder`, `CartProvider`, and the test results.
- Silence desktop notifications and verify microphone capture.
- Keep slides 14–15 ready if the emulator fails.

Personal-name fields are intentionally blank. Add a name only if required for submission.
