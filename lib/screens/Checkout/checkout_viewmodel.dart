// checkout_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:perfumeapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutViewModel extends ChangeNotifier {
  final TextEditingController firstCtrl = TextEditingController();
  final TextEditingController lastCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addr1Ctrl = TextEditingController();
  final TextEditingController addr2Ctrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController postalCtrl = TextEditingController();

  bool _loading = false;
  bool _processingPayment = false;
  bool _didLoadArgs = false;

  Map<String, dynamic>? directProduct;
  Map<String, dynamic>? createdOrder;
  String? razorpayOrderId;
  String? paymentUrl;
  List<Map<String, dynamic>> orderItems = [];
  double orderAmount = 0.0;

  bool get loading => _loading;
  bool get processingPayment => _processingPayment;
  bool get didLoadArgs => _didLoadArgs;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setProcessingPayment(bool value) {
    _processingPayment = value;
    notifyListeners();
  }

  void setDidLoadArgs(bool value) {
    _didLoadArgs = value;
    notifyListeners();
  }

  void setDirectProduct(Map<String, dynamic>? product) {
    directProduct = product;
    notifyListeners();
  }

  void setCreatedOrder(Map<String, dynamic>? order) {
    createdOrder = order;
    notifyListeners();
  }

  void setRazorpayOrderId(String? id) {
    razorpayOrderId = id;
    notifyListeners();
  }

  void setPaymentUrl(String? url) {
    paymentUrl = url;
    notifyListeners();
  }

  void setOrderItems(List<Map<String, dynamic>> items) {
    orderItems = items;
    notifyListeners();
  }

  void setOrderAmount(double amount) {
    orderAmount = amount;
    notifyListeners();
  }

  Future<void> prefillFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    firstCtrl.text = prefs.getString('userFirstName') ?? '';
    lastCtrl.text = prefs.getString('userLastName') ?? '';
    emailCtrl.text = prefs.getString('userEmail') ?? '';
    phoneCtrl.text = prefs.getString('userPhone') ?? '';
    addr1Ctrl.text = prefs.getString('userAddress_line1') ?? '';
    addr2Ctrl.text = prefs.getString('userAddress_line2') ?? '';
    cityCtrl.text = prefs.getString('userAddress_city') ?? '';
    stateCtrl.text = prefs.getString('userAddress_state') ?? '';
    postalCtrl.text = prefs.getString('userAddress_postal_code') ?? '';
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitForm() async {
    final prefs = await SharedPreferences.getInstance();
    final tempCartId = prefs.getString('cartId');
    final token = prefs.getString('authToken');

    final user = {
      'firstName': firstCtrl.text.trim(),
      'lastName': lastCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
    };
    final shippingAddress = {
      'address_line1': addr1Ctrl.text.trim(),
      'address_line2': addr2Ctrl.text.trim(),
      'city': cityCtrl.text.trim(),
      'state': stateCtrl.text.trim(),
      'postal_code': postalCtrl.text.trim(),
    };

    final res = await ApiService.checkout(
      user,
      shippingAddress,
      tempCartId: tempCartId,
      directProduct: directProduct,
      token: token,
    );

    if (res['success'] == true) {
      final returnedUser = res['user'] as Map<String, dynamic>?;
      final returnedCartId = res['cartId'] as String?;

      if (returnedUser != null) {
        await prefs.setString('userFirstName', returnedUser['firstName'] ?? '');
        await prefs.setString('userLastName', returnedUser['lastName'] ?? '');
        if (returnedUser['email'] != null)
          await prefs.setString('userEmail', returnedUser['email']);
        if (returnedUser['phone'] != null)
          await prefs.setString('userPhone', returnedUser['phone']);
        final addr = returnedUser['shippingAddress'] as Map<String, dynamic>?;
        if (addr != null) {
          await prefs.setString(
            'userAddress_line1',
            addr['address_line1'] ?? '',
          );
          await prefs.setString(
            'userAddress_line2',
            addr['address_line2'] ?? '',
          );
          await prefs.setString('userAddress_city', addr['city'] ?? '');
          await prefs.setString('userAddress_state', addr['state'] ?? '');
          await prefs.setString(
            'userAddress_postal_code',
            addr['postal_code'] ?? '',
          );
        }
      }
      if (returnedCartId != null) {
        await prefs.setString('cartId', returnedCartId);
      }

      return {
        'success': true,
        'message': 'Checkout saved. Preparing order preview...',
        'cartId': returnedCartId,
        'user': returnedUser ?? user,
      };
    } else {
      return {
        'success': false,
        'message': res['error']?.toString() ?? 'Checkout failed',
      };
    }
  }

  Future<Map<String, dynamic>> prepareOrderPreviewAndCreate(
    String cartId,
    Map<String, dynamic> user,
    Map<String, dynamic> shipping,
    String? token,
  ) async {
    try {
      final cartRes = await ApiService.getCart(cartId);
      if (cartRes['success'] == true) {
        final cart = cartRes['cart'] as Map<String, dynamic>;
        final items = (cart['items'] as List)
            .map(
              (e) => {
                'product_id': e['product']?['_id'] ?? e['product'],
                'name': e['name'],
                'quantity': e['quantity'],
                'price': e['price'],
              },
            )
            .toList();
        double amount = 0.0;
        for (final it in items) {
          amount += (it['price'] as num? ?? 0) * (it['quantity'] as num? ?? 1);
        }

        setOrderItems(List<Map<String, dynamic>>.from(items));
        setOrderAmount(amount);

        final createRes = await ApiService.createOrder(
          cartId,
          user,
          shipping,
          token: token,
        );
        if (createRes['success'] == true) {
          setCreatedOrder(createRes['order'] as Map<String, dynamic>?);
          setRazorpayOrderId(createRes['razorpay_order_id'] as String?);
          setPaymentUrl(createRes['payment_url'] as String?);

          return {'success': true};
        } else {
          return {
            'success': false,
            'message': 'Failed to create order: ${createRes['error']}',
          };
        }
      } else {
        return {'success': false, 'message': 'Failed to load cart for preview'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error preparing order: $e'};
    }
  }

  Future<Map<String, dynamic>> simulatePaymentResult(bool success) async {
    if (createdOrder == null) {
      return {'success': false, 'message': 'No order created'};
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final orderId = createdOrder!['order_id'] as String;
      final txnId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
      final status = success ? 'paid' : 'failed';

      final res = await ApiService.verifyOrder(
        orderId,
        status,
        'razorpay',
        txnId,
        paidAt: DateTime.now().toIso8601String(),
        token: token,
      );

      if (res['success'] == true) {
        setCreatedOrder(res['order'] as Map<String, dynamic>?);

        return {
          'success': true,
          'status': status,
          'message': status == 'paid'
              ? 'Congratulations — the order is on the way'
              : 'Error: payment failed, try again after 5 minutes',
        };
      } else {
        return {
          'success': false,
          'message': 'Payment verify failed: ${res['error']}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Payment error: $e'};
    }
  }

  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addr1Ctrl.dispose();
    addr2Ctrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    postalCtrl.dispose();
    super.dispose();
  }
}
