// import 'dart:ui' as html;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../services/api_service.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/foundation.dart';

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstCtrl = TextEditingController();
//   final _lastCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _addr1Ctrl = TextEditingController();
//   final _addr2Ctrl = TextEditingController();
//   final _cityCtrl = TextEditingController();
//   final _stateCtrl = TextEditingController();
//   final _postalCtrl = TextEditingController();

//   bool _loading = false;

//   Map<String, dynamic>? directProduct;
//   Map<String, dynamic>? _createdOrder;
//   String? _razorpayOrderId;
//   String? _paymentUrl;
//   List<Map<String, dynamic>> _orderItems = [];
//   double _orderAmount = 0.0;
//   bool _processingPayment = false;

//   @override
//   void initState() {
//     super.initState();
//     // Do not access ModalRoute.of(context) in initState — use didChangeDependencies
//     _prefillFromPrefs();
//   }

//   bool _didLoadArgs = false;
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_didLoadArgs) {
//       final args = ModalRoute.of(context)?.settings.arguments as Map?;
//       if (args != null && args['directProduct'] != null) {
//         directProduct = args['directProduct'] as Map<String, dynamic>?;
//       }
//       _didLoadArgs = true;
//     }
//   }

//   Future<void> _prefillFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _firstCtrl.text = prefs.getString('userFirstName') ?? '';
//       _lastCtrl.text = prefs.getString('userLastName') ?? '';
//       _emailCtrl.text = prefs.getString('userEmail') ?? '';
//       _phoneCtrl.text = prefs.getString('userPhone') ?? '';
//       _addr1Ctrl.text = prefs.getString('userAddress_line1') ?? '';
//       _addr2Ctrl.text = prefs.getString('userAddress_line2') ?? '';
//       _cityCtrl.text = prefs.getString('userAddress_city') ?? '';
//       _stateCtrl.text = prefs.getString('userAddress_state') ?? '';
//       _postalCtrl.text = prefs.getString('userAddress_postal_code') ?? '';
//     });
//   }

//   void _show(String s) =>
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _loading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final tempCartId = prefs.getString('cartId');
//       final token = prefs.getString('authToken');

//       final user = {
//         'firstName': _firstCtrl.text.trim(),
//         'lastName': _lastCtrl.text.trim(),
//         'email': _emailCtrl.text.trim(),
//         'phone': _phoneCtrl.text.trim(),
//       };
//       final shippingAddress = {
//         'address_line1': _addr1Ctrl.text.trim(),
//         'address_line2': _addr2Ctrl.text.trim(),
//         'city': _cityCtrl.text.trim(),
//         'state': _stateCtrl.text.trim(),
//         'postal_code': _postalCtrl.text.trim(),
//       };

//       final res = await ApiService.checkout(
//         user,
//         shippingAddress,
//         tempCartId: tempCartId,
//         directProduct: directProduct,
//         token: token,
//       );

//       if (res['success'] == true) {
//         _show('Checkout saved. Preparing order preview...');
//         final returnedUser = res['user'] as Map<String, dynamic>?;
//         final returnedCartId = res['cartId'] as String?;
//         if (returnedUser != null) {
//           await prefs.setString(
//             'userFirstName',
//             returnedUser['firstName'] ?? '',
//           );
//           await prefs.setString('userLastName', returnedUser['lastName'] ?? '');
//           if (returnedUser['email'] != null)
//             await prefs.setString('userEmail', returnedUser['email']);
//           if (returnedUser['phone'] != null)
//             await prefs.setString('userPhone', returnedUser['phone']);
//           final addr = returnedUser['shippingAddress'] as Map<String, dynamic>?;
//           if (addr != null) {
//             await prefs.setString(
//               'userAddress_line1',
//               addr['address_line1'] ?? '',
//             );
//             await prefs.setString(
//               'userAddress_line2',
//               addr['address_line2'] ?? '',
//             );
//             await prefs.setString('userAddress_city', addr['city'] ?? '');
//             await prefs.setString('userAddress_state', addr['state'] ?? '');
//             await prefs.setString(
//               'userAddress_postal_code',
//               addr['postal_code'] ?? '',
//             );
//           }
//         }
//         if (returnedCartId != null) {
//           await prefs.setString('cartId', returnedCartId);
//         }
//         // Prepare order preview and create order on server
//         await _prepareOrderPreviewAndCreate(
//           returnedCartId!,
//           returnedUser ?? user,
//           shippingAddress,
//           token,
//         );
//       } else {
//         _show(res['error']?.toString() ?? 'Checkout failed');
//       }
//     } catch (e) {
//       _show('Network error: $e');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _prepareOrderPreviewAndCreate(
//     String cartId,
//     Map<String, dynamic> user,
//     Map<String, dynamic> shipping,
//     String? token,
//   ) async {
//     try {
//       final cartRes = await ApiService.getCart(cartId);
//       if (cartRes['success'] == true) {
//         final cart = cartRes['cart'] as Map<String, dynamic>;
//         final items = (cart['items'] as List)
//             .map(
//               (e) => {
//                 'product_id': e['product']?['_id'] ?? e['product'],
//                 'name': e['name'],
//                 'quantity': e['quantity'],
//                 'price': e['price'],
//               },
//             )
//             .toList();
//         double amount = 0.0;
//         for (final it in items) {
//           amount += (it['price'] as num? ?? 0) * (it['quantity'] as num? ?? 1);
//         }
//         setState(() {
//           _orderItems = List<Map<String, dynamic>>.from(items);
//           _orderAmount = amount;
//         });

//         final createRes = await ApiService.createOrder(
//           cartId,
//           user,
//           shipping,
//           token: token,
//         );
//         if (createRes['success'] == true) {
//           setState(() {
//             _createdOrder = createRes['order'] as Map<String, dynamic>?;
//             _razorpayOrderId = createRes['razorpay_order_id'] as String?;
//             _paymentUrl = createRes['payment_url'] as String?;
//           });
//         } else {
//           _show('Failed to create order: ${createRes['error']}');
//         }
//       } else {
//         _show('Failed to load cart for preview');
//       }
//     } catch (e) {
//       _show('Error preparing order: $e');
//     }
//   }

//   Future<void> _simulatePaymentResult(bool success) async {
//     if (_createdOrder == null) return _show('No order created');
//     setState(() => _processingPayment = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('authToken');
//       final orderId = _createdOrder!['order_id'] as String;
//       final txnId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
//       final status = success ? 'paid' : 'failed';
//       final res = await ApiService.verifyOrder(
//         orderId,
//         status,
//         'razorpay',
//         txnId,
//         paidAt: DateTime.now().toIso8601String(),
//         token: token,
//       );
//       if (res['success'] == true) {
//         if (status == 'paid') {
//           _show('Congratulations — the order is on the way');
//         } else {
//           _show('Error: payment failed, try again after 5 minutes');
//         }
//         // update local created order
//         setState(() {
//           _createdOrder = res['order'] as Map<String, dynamic>?;
//         });
//       } else {
//         _show('Payment verify failed: ${res['error']}');
//       }
//     } catch (e) {
//       _show('Payment error: $e');
//     } finally {
//       setState(() => _processingPayment = false);
//     }
//   }

//   Future<void> _openPaymentWebView(String url) async {
//     if (url.isEmpty) return _show('No payment URL available');

//     if (kIsWeb) {
//       // For web, use url_launcher
//       if (await canLaunchUrl(Uri.parse(url))) {
//         await launchUrl(
//           Uri.parse(url),
//           mode: LaunchMode.inAppWebView, // Opens in a webview
//           webOnlyWindowName: '_self', // Opens in current tab
//         );
//       } else {
//         _show('Could not launch $url');
//       }
//       return;
//     }

//     // Mobile platforms continue with WebView
//     setState(() => _processingPayment = true);
//     final result = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) {
//           final controller = WebViewController()
//             ..setJavaScriptMode(JavaScriptMode.unrestricted)
//             ..setNavigationDelegate(
//               NavigationDelegate(
//                 onNavigationRequest: (request) {
//                   final u = request.url;
//                   if (u.contains('/payment-success')) {
//                     Navigator.of(context).pop('success');
//                     return NavigationDecision.prevent;
//                   }
//                   if (u.contains('/payment-fail')) {
//                     Navigator.of(context).pop('fail');
//                     return NavigationDecision.prevent;
//                   }
//                   return NavigationDecision.navigate;
//                 },
//               ),
//             )
//             ..loadRequest(Uri.parse(url));

//           return Scaffold(
//             appBar: AppBar(title: const Text('Complete payment')),
//             body: WebViewWidget(controller: controller),
//           );
//         },
//       ),
//     );

//     setState(() => _processingPayment = false);
//     if (result == 'success') {
//       _show('Payment success — order completed');
//       // Optionally refresh order state
//     } else if (result == 'fail') {
//       _show('Payment failed or cancelled');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Checkout')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               if (_createdOrder != null) ...[
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Order Preview',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         ..._orderItems.map(
//                           (it) => Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     '${it['name']} x${it['quantity']}',
//                                   ),
//                                 ),
//                                 Text(
//                                   'Rs ${(it['price'] as num? ?? 0).toStringAsFixed(2)}',
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const Divider(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               'Total',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               'Rs ${_orderAmount.toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         if (!_processingPayment)
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _paymentUrl != null
//                                     ? ElevatedButton(
//                                         onPressed: () =>
//                                             _openPaymentWebView(_paymentUrl!),
//                                         child: const Text('Pay Now'),
//                                       )
//                                     : ElevatedButton(
//                                         onPressed: () =>
//                                             _simulatePaymentResult(true),
//                                         child: const Text(
//                                           'Simulate Success (Razorpay)',
//                                         ),
//                                       ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: OutlinedButton(
//                                   onPressed: () =>
//                                       _simulatePaymentResult(false),
//                                   child: const Text('Simulate Failure'),
//                                 ),
//                               ),
//                             ],
//                           )
//                         else
//                           const Center(child: CircularProgressIndicator()),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//               ],
//               TextFormField(
//                 controller: _firstCtrl,
//                 decoration: const InputDecoration(labelText: 'First name'),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Required' : null,
//               ),
//               TextFormField(
//                 controller: _lastCtrl,
//                 decoration: const InputDecoration(
//                   labelText: 'Last name (optional)',
//                 ),
//               ),
//               TextFormField(
//                 controller: _emailCtrl,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               TextFormField(
//                 controller: _phoneCtrl,
//                 decoration: const InputDecoration(labelText: 'Phone'),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _addr1Ctrl,
//                 decoration: const InputDecoration(labelText: 'Address line 1'),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Required' : null,
//               ),
//               TextFormField(
//                 controller: _addr2Ctrl,
//                 decoration: const InputDecoration(labelText: 'Address line 2'),
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _cityCtrl,
//                       decoration: const InputDecoration(labelText: 'City'),
//                       validator: (v) =>
//                           (v == null || v.trim().isEmpty) ? 'Required' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _stateCtrl,
//                       decoration: const InputDecoration(labelText: 'State'),
//                       validator: (v) =>
//                           (v == null || v.trim().isEmpty) ? 'Required' : null,
//                     ),
//                   ),
//                 ],
//               ),
//               TextFormField(
//                 controller: _postalCtrl,
//                 decoration: const InputDecoration(labelText: 'Postal code'),
//                 validator: (v) =>
//                     (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 18),
//               ElevatedButton(
//                 onPressed: _loading ? null : _submit,
//                 child: _loading
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text('Proceed to payment'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
