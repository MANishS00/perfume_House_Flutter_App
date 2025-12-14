import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:perfumeapp/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<List<dynamic>> fetchProducts() async {
    final uri = Uri.parse('$baseUrl/api/products');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch products: \\$res');
  }

  static Future<Map<String, dynamic>> addToCart(
    String? cartId,
    String productId,
    int quantity,
  ) async {
    final uri = Uri.parse('$baseUrl/api/cart');
    final body = json.encode({
      'cartId': cartId,
      'productId': productId,
      'quantity': quantity,
    });
    final res = await http.post(
      uri,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getCart(String cartId) async {
    final uri = Uri.parse('$baseUrl/api/cart/$cartId');
    final res = await http.get(uri);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateItem(
    String cartId,
    String itemId,
    int quantity,
  ) async {
    final uri = Uri.parse('$baseUrl/api/cart/$cartId/items/$itemId');
    final res = await http.put(
      uri,
      body: json.encode({'quantity': quantity}),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> removeItem(
    String cartId,
    String itemId,
  ) async {
    final uri = Uri.parse('$baseUrl/api/cart/$cartId/items/$itemId');
    final res = await http.delete(uri);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Request verification code for signup/login
  // Request verification code for signup/login
  // action: 'signup' or 'login'
  static Future<Map<String, dynamic>> requestVerification(
    String email,
    String action,
  ) async {
    final uri = Uri.parse('$baseUrl/api/auth/request-code');
    final body = json.encode({'email': email, 'action': action});
    final res = await http.post(
      uri,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Verify code
  static Future<Map<String, dynamic>> verifyCode(
    String email,
    String code,
    String action, {
    String? tempCartId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/verify-code');
    final body = json.encode({
      'email': email,
      'code': code,
      'action': action,
      if (tempCartId != null) 'tempCartId': tempCartId,
    });
    final res = await http.post(
      uri,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Checkout: create/update user and attach/merge cart
  // user: { firstName, lastName?, email, phone }
  // shippingAddress: { address_line1, address_line2, city, state, postal_code }
  // optional: tempCartId, directProduct: { productId, qty }
  // optional: token for Authorization header
  static Future<Map<String, dynamic>> checkout(
    Map<String, dynamic> user,
    Map<String, dynamic> shippingAddress, {
    String? tempCartId,
    Map<String, dynamic>? directProduct,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/checkout');
    final body = json.encode({
      'user': user,
      'shippingAddress': shippingAddress,
      if (tempCartId != null) 'tempCartId': tempCartId,
      if (directProduct != null) 'directProduct': directProduct,
    });
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await http.post(uri, body: body, headers: headers);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Create order on server from cartId
  static Future<Map<String, dynamic>> createOrder(
    String cartId,
    Map<String, dynamic> user,
    Map<String, dynamic> shipping, {
    String currency = 'USD',
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/orders/create');
    final body = json.encode({
      'cartId': cartId,
      'user': user,
      'shipping': shipping,
      'currency': currency,
    });
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await http.post(uri, body: body, headers: headers);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Verify order payment result
  static Future<Map<String, dynamic>> verifyOrder(
    String orderId,
    String status, // 'paid' or 'failed'
    String method,
    String transactionId, {
    String? paidAt,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/orders/verify');
    final body = json.encode({
      'orderId': orderId,
      'status': status,
      'method': method,
      'transaction_id': transactionId,
      if (paidAt != null) 'paid_at': paidAt,
    });
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await http.post(uri, body: body, headers: headers);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Get orders of logged-in user
  static Future<Map<String, dynamic>> myOrders({String? token}) async {
    final uri = Uri.parse('$baseUrl/api/orders/my');
    final headers = <String, String>{'Content-Type': 'application/json'};
    String? t = token;
    if (t == null) {
      final prefs = await SharedPreferences.getInstance();
      t = prefs.getString('authToken');
    }
    if (t != null) headers['Authorization'] = 'Bearer $t';
    final res = await http.get(uri, headers: headers);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Fetch site templates: site.about, site.privacy, site.terms, site.contact
  static Future<Map<String, dynamic>> getSiteTemplates() async {
    // final keys = ['site.about', 'site.privacy', 'site.terms', 'site.contact'];
    final Map<String, String> result = {};
    final keys = [
      'site.about',
      'site.privacy',
      'site.terms',
      'site.contact.email',
      'site.contact.phone',
    ];
    for (final k in keys) {
      final uri = Uri.parse('$baseUrl/api/templates/${Uri.encodeComponent(k)}');
      try {
        final res = await http.get(uri);
        if (res.statusCode == 200) {
          final data = json.decode(res.body) as Map<String, dynamic>;
          if (data['success'] == true && data['template'] != null) {
            result[k] = (data['template']['body'] ?? '') as String;
            continue;
          }
        }
      } catch (_) {}
      result[k] = '';
    }
    return {'success': true, 'templates': result};
  }

  // Get current user's profile (requires Authorization Bearer token)
  static Future<Map<String, dynamic>> getProfile({String? token}) async {
    final uri = Uri.parse('$baseUrl/api/user');
    final headers = <String, String>{'Content-Type': 'application/json'};
    String? t = token;
    if (t == null) {
      final prefs = await SharedPreferences.getInstance();
      t = prefs.getString('authToken');
    }
    if (t != null) headers['Authorization'] = 'Bearer $t';
    final res = await http.get(uri, headers: headers);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Update current user's profile (email cannot be changed)
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user');
    final headers = <String, String>{'Content-Type': 'application/json'};
    String? t = token;
    if (t == null) {
      final prefs = await SharedPreferences.getInstance();
      t = prefs.getString('authToken');
    }
    if (t != null) headers['Authorization'] = 'Bearer $t';
    final res = await http.put(uri, headers: headers, body: json.encode(body));
    return json.decode(res.body) as Map<String, dynamic>;
  }
}
