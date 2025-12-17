// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import '../services/api_service.dart';
// import 'cart_screen.dart';
// import 'order_history.dart';
// import 'site_info.dart';
// import 'edit_profile.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProductListScreen extends StatefulWidget {
//   const ProductListScreen({super.key});

//   @override
//   State<ProductListScreen> createState() => _ProductListScreenState();
// }

// class _ProductListScreenState extends State<ProductListScreen> {
//   List<Product> products = [];
//   bool loading = true;
//   String searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadProducts();
//   }

//   Future<Map<String, dynamic>> _authInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
//     final email = prefs.getString('userEmail');
//     final firstName = prefs.getString('userFirstName');
//     final lastName = prefs.getString('userLastName');
//     final phone = prefs.getString('userPhone');
//     final address1 = prefs.getString('userAddress_line1');
//     return {
//       'loggedIn': token != null,
//       'email': email,
//       'firstName': firstName,
//       'lastName': lastName,
//       'phone': phone,
//       'address1': address1,
//     };
//   }

//   Future<void> loadProducts() async {
//     try {
//       final raw = await ApiService.fetchProducts();
//       setState(() {
//         products = raw
//             .map((e) => Product.fromJson(e as Map<String, dynamic>))
//             .toList();
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load products: $e')));
//     }
//   }

//   List<Product> get filteredProducts {
//     if (searchQuery.trim().isEmpty) return products;
//     final q = searchQuery.toLowerCase();
//     return products.where((p) {
//       return p.name.toLowerCase().contains(q) ||
//           p.brand.toLowerCase().contains(q) ||
//           p.category.toLowerCase().contains(q);
//     }).toList();
//   }

//   Future<String?> _getCartId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('cartId');
//   }

//   Future<void> _saveCartId(String cartId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('cartId', cartId);
//   }

//   Future<void> addToCart(String productId) async {
//     final currentCartId = await _getCartId();
//     final res = await ApiService.addToCart(currentCartId, productId, 1);
//     if (res['success'] == true) {
//       final cartId = res['cartId'] as String? ?? res['cart']?['cartId'];
//       if (cartId != null) await _saveCartId(cartId);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Added to cart')));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add to cart: ${res['error']}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Perfume Store'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shopping_cart),
//             onPressed: () async {
//               final prefs = await SharedPreferences.getInstance();
//               final cartId = prefs.getString('cartId');
//               if (cartId == null) {
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
//                 return;
//               }
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => CartScreen(cartId: cartId)),
//               );
//             },
//           ),
//         ],
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//       ),
//       drawer: Drawer(
//         child: FutureBuilder<Map<String, dynamic>>(
//           future: _authInfo(),
//           builder: (context, snap) {
//             final loggedIn = snap.hasData && (snap.data!['loggedIn'] == true);
//             final email = snap.hasData
//                 ? (snap.data!['email'] ?? '') as String
//                 : '';
//             final firstName = snap.hasData
//                 ? (snap.data!['firstName'] ?? '') as String
//                 : '';
//             final lastName = snap.hasData
//                 ? (snap.data!['lastName'] ?? '') as String
//                 : '';
//             final phone = snap.hasData
//                 ? (snap.data!['phone'] ?? '') as String
//                 : '';
//             return ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 DrawerHeader(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       const Text(
//                         'Menu',
//                         style: TextStyle(color: Colors.white, fontSize: 20),
//                       ),
//                       if (loggedIn &&
//                           (firstName.isNotEmpty || email.isNotEmpty)) ...[
//                         const SizedBox(height: 8),
//                         Text(
//                           '${firstName}${lastName != null && lastName.isNotEmpty ? ' ' + lastName : ''}',
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                       if (loggedIn && phone.isNotEmpty) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           phone,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                       if (loggedIn && email.isNotEmpty) ...[
//                         const SizedBox(height: 6),
//                         Text(
//                           email,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.shopping_cart),
//                   title: const Text('View Cart'),
//                   onTap: () async {
//                     final prefs = await SharedPreferences.getInstance();
//                     final cartId = prefs.getString('cartId');
//                     if (cartId == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Cart is empty')),
//                       );
//                       return;
//                     }
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => CartScreen(cartId: cartId),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.info_outline),
//                   title: const Text('Site Info'),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SiteInfoScreen()),
//                     );
//                   },
//                 ),
//                 if (loggedIn)
//                   ListTile(
//                     leading: const Icon(Icons.history),
//                     title: const Text('My Orders'),
//                     onTap: () async {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const OrderHistoryScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 if (loggedIn)
//                   ListTile(
//                     leading: const Icon(Icons.person),
//                     title: const Text('Edit Profile'),
//                     onTap: () async {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const EditProfileScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 if (loggedIn)
//                   ListTile(
//                     leading: const Icon(Icons.logout),
//                     title: const Text('Logout'),
//                     onTap: () async {
//                       final prefs = await SharedPreferences.getInstance();
//                       await prefs.remove('authToken');
//                       await prefs.remove('userEmail');
//                       // keep cartId as-is; user can continue with current cart
//                       Navigator.pop(context);
//                       setState(() {});
//                     },
//                   )
//                 else
//                   ListTile(
//                     leading: const Icon(Icons.login),
//                     title: const Text('Login / Signup'),
//                     onTap: () async {
//                       Navigator.pop(context);
//                       // await the auth flow and then rebuild drawer when returning
//                       await Navigator.pushNamed(context, '/auth');
//                       setState(() {});
//                     },
//                   ),
//               ],
//             );
//           },
//         ),
//       ),

//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: loadProducts,
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(8),
//                 itemCount: filteredProducts.length + 1,
//                 itemBuilder: (context, i) {
//                   if (i == 0) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: const InputDecoration(
//                           prefixIcon: Icon(Icons.search),
//                           hintText:
//                               'Search products by name, brand or category',
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (v) {
//                           setState(() => searchQuery = v);
//                         },
//                       ),
//                     );
//                   }
//                   final p = filteredProducts[i - 1];
//                   return Card(
//                     child: ListTile(
//                       leading: p.imageUrl.isNotEmpty
//                           ? Image.network(
//                               p.imageUrl,
//                               width: 56,
//                               height: 56,
//                               fit: BoxFit.cover,
//                             )
//                           : const SizedBox(
//                               width: 56,
//                               height: 56,
//                               child: Icon(Icons.image_not_supported),
//                             ),
//                       title: Text(p.name),
//                       subtitle: Text(
//                         '\$${p.price.toStringAsFixed(2)} • ${p.brand}',
//                       ),
//                       trailing: Wrap(
//                         spacing: 8,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () => addToCart(p.id),
//                             child: const Text('Add'),
//                           ),
//                           OutlinedButton(
//                             onPressed: () async {
//                               // Buy now: navigate to checkout with directProduct
//                               await Navigator.pushNamed(
//                                 context,
//                                 '/checkout',
//                                 arguments: {
//                                   'directProduct': {
//                                     'productId': p.id,
//                                     'qty': 1,
//                                   },
//                                 },
//                               );
//                               // refresh drawer/state on return
//                               setState(() {});
//                             },
//                             child: const Text('Buy'),
//                           ),
//                         ],
//                       ),
//                       onTap: () {},
//                     ),
//                   );
//                 },
//               ),
//             ),
//     );
//   }
// }
