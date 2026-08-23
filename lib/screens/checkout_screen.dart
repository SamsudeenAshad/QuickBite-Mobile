import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/validators.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({required this.onBackHome, super.key});

  /// Called after the confirmation screen returns to the app shell so it can
  /// select the Home destination.
  final VoidCallback onBackHome;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cardholderController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _cardholderFocus = FocusNode();
  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();

  String _selectedPaymentMethod = AppConstants.cashOnDelivery;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isSubmitting = false;
  String? _submissionError;

  bool get _usesCard => _selectedPaymentMethod == AppConstants.cardPayment;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _cardholderFocus.dispose();
    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final CartProvider cartProvider = context.read<CartProvider>();
    final OrderProvider orderProvider = context.read<OrderProvider>();

    if (cartProvider.isEmpty) {
      _showEmptyCartMessage();
      return;
    }
    if (cartProvider.isLoading || cartProvider.isUpdating) {
      setState(() {
        _submissionError =
            'Your cart is still updating. Wait a moment and try again.';
      });
      return;
    }

    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _submissionError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) {
      _focusFirstInvalidField();
      return;
    }

    setState(() => _isSubmitting = true);
    bool startedConfirmation = false;
    try {
      // Card fields intentionally remain local to this screen. The simulated
      // checkout only sends non-sensitive order information to the provider.
      final OrderModel order = await orderProvider.placeOrder(
        customerName: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        paymentMethod: _selectedPaymentMethod,
      );
      await cartProvider.loadCart();

      if (!mounted) {
        return;
      }
      startedConfirmation = true;
      Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => OrderConfirmationScreen(
            order: order,
            onBackHome: widget.onBackHome,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submissionError =
            orderProvider.errorMessage ??
            'We could not place your order. Check your details and try again.';
      });
    } finally {
      if (mounted && !startedConfirmation) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _focusFirstInvalidField() {
    FocusNode? target;
    if (AppValidators.customerName(_nameController.text) != null) {
      target = _nameFocus;
    } else if (AppValidators.phoneNumber(_phoneController.text) != null) {
      target = _phoneFocus;
    } else if (AppValidators.deliveryAddress(_addressController.text) != null) {
      target = _addressFocus;
    } else if (_usesCard &&
        AppValidators.cardholderName(_cardholderController.text) != null) {
      target = _cardholderFocus;
    } else if (_usesCard &&
        AppValidators.cardNumber(_cardNumberController.text) != null) {
      target = _cardNumberFocus;
    } else if (_usesCard &&
        AppValidators.expiryDate(_expiryController.text) != null) {
      target = _expiryFocus;
    } else if (_usesCard && AppValidators.cvv(_cvvController.text) != null) {
      target = _cvvFocus;
    }
    target?.requestFocus();
  }

  void _showEmptyCartMessage() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty. Add an item before checkout.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        top: false,
        child: Consumer2<CartProvider, OrderProvider>(
          builder:
              (
                BuildContext context,
                CartProvider cartProvider,
                OrderProvider orderProvider,
                Widget? child,
              ) {
                if (_isSubmitting && cartProvider.isEmpty) {
                  return const _ProcessingOrderState();
                }
                if (cartProvider.isLoading && cartProvider.items.isEmpty) {
                  return Center(
                    child: Semantics(
                      label: 'Loading checkout',
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }
                if (cartProvider.isEmpty) {
                  return _EmptyCheckoutState(
                    message: cartProvider.errorMessage,
                    onBack: () => Navigator.of(context).maybePop(),
                    onRetry: cartProvider.errorMessage == null
                        ? null
                        : cartProvider.loadCart,
                  );
                }

                final bool isBusy =
                    _isSubmitting || orderProvider.isPlacingOrder;
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double horizontalPadding = constraints.maxWidth >= 700
                        ? 32
                        : 20;
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: AutofillGroup(
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _autovalidateMode,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(
                                    'Almost ready',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tell us where to deliver, then choose how you would like to pay.',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 28),
                                  const _SectionHeading(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Delivery details',
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _nameController,
                                    focusNode: _nameFocus,
                                    enabled: !isBusy,
                                    autofillHints: const <String>[
                                      AutofillHints.name,
                                    ],
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Customer name',
                                      hintText: 'e.g. Samsudeen Ashad',
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        semanticLabel: 'Customer name',
                                      ),
                                    ),
                                    validator: AppValidators.customerName,
                                    onFieldSubmitted: (_) =>
                                        _phoneFocus.requestFocus(),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    focusNode: _phoneFocus,
                                    enabled: !isBusy,
                                    autofillHints: const <String>[
                                      AutofillHints.telephoneNumber,
                                    ],
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9+()\s-]'),
                                      ),
                                      LengthLimitingTextInputFormatter(20),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Phone number',
                                      hintText: 'e.g. 077 123 4567',
                                      prefixIcon: Icon(
                                        Icons.phone_outlined,
                                        semanticLabel: 'Phone number',
                                      ),
                                    ),
                                    validator: AppValidators.phoneNumber,
                                    onFieldSubmitted: (_) =>
                                        _addressFocus.requestFocus(),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _addressController,
                                    focusNode: _addressFocus,
                                    enabled: !isBusy,
                                    keyboardType: TextInputType.streetAddress,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    minLines: 2,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      labelText: 'Delivery address',
                                      hintText: 'House number, street and city',
                                      alignLabelWithHint: true,
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.only(bottom: 46),
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          semanticLabel: 'Delivery address',
                                        ),
                                      ),
                                    ),
                                    validator: AppValidators.deliveryAddress,
                                  ),
                                  const SizedBox(height: 30),
                                  const _SectionHeading(
                                    icon: Icons.wallet_outlined,
                                    title: 'Payment method',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'This student app simulates payment and does not charge your account.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  RadioGroup<String>(
                                    groupValue: _selectedPaymentMethod,
                                    onChanged: (String? value) {
                                      if (isBusy || value == null) {
                                        return;
                                      }
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      setState(() {
                                        _selectedPaymentMethod = value;
                                        _submissionError = null;
                                      });
                                    },
                                    child: Column(
                                      children: AppConstants.paymentMethods
                                          .map(
                                            (String method) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: _PaymentMethodCard(
                                                method: method,
                                                selectedMethod:
                                                    _selectedPaymentMethod,
                                                enabled: !isBusy,
                                              ),
                                            ),
                                          )
                                          .toList(growable: false),
                                    ),
                                  ),
                                  if (_usesCard) ...<Widget>[
                                    const SizedBox(height: 10),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Text(
                                              'Card details',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Used only for this simulation. Card details are never saved.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            ),
                                            const SizedBox(height: 18),
                                            TextFormField(
                                              controller: _cardholderController,
                                              focusNode: _cardholderFocus,
                                              enabled: !isBusy,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              textInputAction:
                                                  TextInputAction.next,
                                              decoration: const InputDecoration(
                                                labelText: 'Cardholder name',
                                                prefixIcon: Icon(
                                                  Icons.badge_outlined,
                                                  semanticLabel:
                                                      'Cardholder name',
                                                ),
                                              ),
                                              validator:
                                                  AppValidators.cardholderName,
                                              onFieldSubmitted: (_) =>
                                                  _cardNumberFocus
                                                      .requestFocus(),
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              controller: _cardNumberController,
                                              focusNode: _cardNumberFocus,
                                              enabled: !isBusy,
                                              keyboardType:
                                                  TextInputType.number,
                                              textInputAction:
                                                  TextInputAction.next,
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  19,
                                                ),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: 'Card number',
                                                hintText: '13–19 digits',
                                                prefixIcon: Icon(
                                                  Icons.credit_card_rounded,
                                                  semanticLabel: 'Card number',
                                                ),
                                              ),
                                              validator:
                                                  AppValidators.cardNumber,
                                              onFieldSubmitted: (_) =>
                                                  _expiryFocus.requestFocus(),
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        _expiryController,
                                                    focusNode: _expiryFocus,
                                                    enabled: !isBusy,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    inputFormatters:
                                                        <TextInputFormatter>[
                                                          _ExpiryDateInputFormatter(),
                                                        ],
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Expiry',
                                                          hintText: 'MM/YY',
                                                        ),
                                                    validator: AppValidators
                                                        .expiryDate,
                                                    onFieldSubmitted: (_) =>
                                                        _cvvFocus
                                                            .requestFocus(),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: _cvvController,
                                                    focusNode: _cvvFocus,
                                                    enabled: !isBusy,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    obscureText: true,
                                                    autocorrect: false,
                                                    enableSuggestions: false,
                                                    inputFormatters:
                                                        <TextInputFormatter>[
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                          LengthLimitingTextInputFormatter(
                                                            4,
                                                          ),
                                                        ],
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'CVV',
                                                          hintText:
                                                              '3 or 4 digits',
                                                        ),
                                                    validator:
                                                        AppValidators.cvv,
                                                    onFieldSubmitted: (_) =>
                                                        _submitOrder(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 30),
                                  const _SectionHeading(
                                    icon: Icons.receipt_long_outlined,
                                    title: 'Order summary',
                                  ),
                                  const SizedBox(height: 14),
                                  _OrderSummaryCard(
                                    itemCount: cartProvider.itemCount,
                                    subtotal: cartProvider.subtotal,
                                    deliveryCharge: cartProvider.deliveryCharge,
                                    total: cartProvider.total,
                                  ),
                                  if (_submissionError != null) ...<Widget>[
                                    const SizedBox(height: 18),
                                    Semantics(
                                      liveRegion: true,
                                      container: true,
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .errorContainer,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.error_outline_rounded,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onErrorContainer,
                                              semanticLabel: 'Order error',
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _submissionError!,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onErrorContainer,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 22),
                                  Semantics(
                                    label: isBusy
                                        ? 'Placing your order'
                                        : 'Place order',
                                    button: true,
                                    child: FilledButton.icon(
                                      onPressed:
                                          isBusy || cartProvider.isUpdating
                                          ? null
                                          : _submitOrder,
                                      icon: isBusy
                                          ? SizedBox.square(
                                              dimension: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.lock_outline_rounded,
                                              semanticLabel:
                                                  'Simulated secure checkout',
                                            ),
                                      label: Text(
                                        isBusy
                                            ? 'Placing order…'
                                            : 'Place Order',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No real bank transaction is made in this student project.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, semanticLabel: title),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.selectedMethod,
    required this.enabled,
  });

  final String method;
  final String selectedMethod;
  final bool enabled;

  IconData get _icon => switch (method) {
    AppConstants.cardPayment => Icons.credit_card_rounded,
    AppConstants.digitalWallet => Icons.account_balance_wallet_outlined,
    _ => Icons.payments_outlined,
  };

  String get _description => switch (method) {
    AppConstants.cardPayment => 'Enter card details for a safe simulation',
    AppConstants.digitalWallet => 'Simulate paying with a digital wallet',
    _ => 'Pay when your order arrives',
  };

  @override
  Widget build(BuildContext context) {
    final bool isSelected = method == selectedMethod;
    return Semantics(
      selected: isSelected,
      child: Card(
        color: isSelected ? AppColors.primaryContainer : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: RadioListTile<String>(
          value: method,
          enabled: enabled,
          selected: isSelected,
          secondary: Icon(_icon, semanticLabel: method),
          title: Text(
            method,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(_description),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.itemCount,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
  });

  final int itemCount;
  final double subtotal;
  final double deliveryCharge;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            _SummaryRow(
              label: '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              value: formatCurrency(subtotal),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Delivery charge',
              value: formatCurrency(deliveryCharge),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            _SummaryRow(
              label: 'Total',
              value: formatCurrency(total),
              emphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = emphasized
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyLarge;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 16),
        Text(
          value,
          textAlign: TextAlign.end,
          style: style?.copyWith(
            color: emphasized ? AppColors.primary : AppColors.textPrimary,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyCheckoutState extends StatelessWidget {
  const _EmptyCheckoutState({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 48
                  ? constraints.maxHeight - 48
                  : 0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 42,
                        color: AppColors.primary,
                        semanticLabel: 'Empty cart',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your cart is empty',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message ??
                          'Add something delicious before heading to checkout.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    if (onRetry != null) ...<Widget>[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try Again'),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Back to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProcessingOrderState extends StatelessWidget {
  const _ProcessingOrderState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        label: 'Finalising your order',
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Finalising your order…',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) {
      digits = digits.substring(0, 4);
    }

    final String formatted = digits.length > 2
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
