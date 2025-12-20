// checkout_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:perfumeapp/screens/Checkout/checkout_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late CheckoutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckoutViewModel();
    _viewModel.prefillFromPrefs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_viewModel.didLoadArgs) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['directProduct'] != null) {
        _viewModel.setDirectProduct(
          args['directProduct'] as Map<String, dynamic>?,
        );
      }
      _viewModel.setDidLoadArgs(true);
    }
  }

  void _show(String s) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
    }
  }

  Future<void> _submitForm() async {
    if (!_viewModel.validateForm(_formKey)) return;

    _viewModel.setLoading(true);
    try {
      final submitResult = await _viewModel.submitForm();

      if (submitResult['success'] == true) {
        _show(submitResult['message'] as String);

        final cartId = submitResult['cartId'] as String;
        final user = submitResult['user'] as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('authToken');

        final shippingAddress = {
          'address_line1': _viewModel.addr1Ctrl.text.trim(),
          'address_line2': _viewModel.addr2Ctrl.text.trim(),
          'city': _viewModel.cityCtrl.text.trim(),
          'state': _viewModel.stateCtrl.text.trim(),
          'postal_code': _viewModel.postalCtrl.text.trim(),
        };

        final orderResult = await _viewModel.prepareOrderPreviewAndCreate(
          cartId,
          user,
          shippingAddress,
          token,
        );

        if (orderResult['success'] != true) {
          _show(orderResult['message'] as String);
        }
      } else {
        _show(submitResult['message'] as String);
      }
    } catch (e) {
      _show('Network error: $e');
    } finally {
      _viewModel.setLoading(false);
    }
  }

  Future<void> _simulatePayment(bool success) async {
    _viewModel.setProcessingPayment(true);
    try {
      final result = await _viewModel.simulatePaymentResult(success);
      _show(result['message'] as String);
    } finally {
      _viewModel.setProcessingPayment(false);
    }
  }

  Future<void> _openPaymentWebView(String url) async {
    if (url.isEmpty) {
      _show('No payment URL available');
      return;
    }

    if (kIsWeb) {
      // For web, use url_launcher
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.inAppWebView,
          webOnlyWindowName: '_self',
        );
      } else {
        _show('Could not launch $url');
      }
      return;
    }

    _viewModel.setProcessingPayment(true);
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          final controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (request) {
                  final u = request.url;
                  if (u.contains('/payment-success')) {
                    Navigator.of(context).pop('success');
                    return NavigationDecision.prevent;
                  }
                  if (u.contains('/payment-fail')) {
                    Navigator.of(context).pop('fail');
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ),
            )
            ..loadRequest(Uri.parse(url));

          return Scaffold(
            appBar: AppBar(title: const Text('Complete payment')),
            body: WebViewWidget(controller: controller),
          );
        },
      ),
    );

    _viewModel.setProcessingPayment(false);
    if (result == 'success') {
      _show('Payment success — order completed');
    } else if (result == 'fail') {
      _show('Payment failed or cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CheckoutViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (viewModel.createdOrder != null) ...[
                      _buildOrderPreview(viewModel),
                      const SizedBox(height: 12),
                    ],
                    _buildFormFields(viewModel),
                    const SizedBox(height: 18),
                    _buildSubmitButton(viewModel),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderPreview(CheckoutViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...viewModel.orderItems.map(
              (it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${it['name']} x${it['quantity']}')),
                    Text('Rs ${(it['price'] as num? ?? 0).toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs ${viewModel.orderAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!viewModel.processingPayment)
              _buildPaymentButtons(viewModel)
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButtons(CheckoutViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: viewModel.paymentUrl != null
              ? ElevatedButton(
                  onPressed: () => _openPaymentWebView(viewModel.paymentUrl!),
                  child: const Text('Pay Now'),
                )
              : ElevatedButton(
                  onPressed: () => _simulatePayment(true),
                  child: const Text('Simulate Success (Razorpay)'),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _simulatePayment(false),
            child: const Text('Simulate Failure'),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(CheckoutViewModel viewModel) {
    return Column(
      children: [
        TextFormField(
          controller: viewModel.firstCtrl,
          decoration: const InputDecoration(labelText: 'First name'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        TextFormField(
          controller: viewModel.lastCtrl,
          decoration: const InputDecoration(labelText: 'Last name (optional)'),
        ),
        TextFormField(
          controller: viewModel.emailCtrl,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          keyboardType: TextInputType.emailAddress,
        ),
        TextFormField(
          controller: viewModel.phoneCtrl,
          decoration: const InputDecoration(labelText: 'Phone'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: viewModel.addr1Ctrl,
          decoration: const InputDecoration(labelText: 'Address line 1'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        TextFormField(
          controller: viewModel.addr2Ctrl,
          decoration: const InputDecoration(labelText: 'Address line 2'),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: viewModel.cityCtrl,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: viewModel.stateCtrl,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
          ],
        ),
        TextFormField(
          controller: viewModel.postalCtrl,
          decoration: const InputDecoration(labelText: 'Postal code'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(CheckoutViewModel viewModel) {
    return ElevatedButton(
      onPressed: viewModel.loading ? null : _submitForm,
      child: viewModel.loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Proceed to payment'),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
