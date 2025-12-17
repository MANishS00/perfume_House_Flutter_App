import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool loading = true;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    try {
      final res = await ApiService.myOrders(token: token);
      if (res['success'] == true) {
        setState(() {
          orders = res['orders'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? 'Failed to load orders')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final o = orders[i] as Map<String, dynamic>;
                final items = (o['items'] as List<dynamic>? ?? [])
                    .cast<dynamic>();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order: ${o['order_id'] ?? o['_id']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...items.map(
                          (it) => Text(
                            '${it['name']} x${it['quantity']} - Rs ${(it['price'] ?? 0).toString()}',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Status: ${o['order_status'] ?? ''}'),
                        Text(
                          'Amount: Rs ${o['payment']?['amount'] ?? ''} ${o['payment']?['currency'] ?? ''}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
