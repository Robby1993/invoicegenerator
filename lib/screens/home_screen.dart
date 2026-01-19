import 'package:flutter/material.dart';
import 'package:invoicegenerator/screens/billing_detail_screen.dart';
import 'product_list_screen.dart';
import 'customer_list_screen.dart';
import 'order_history_screen.dart';
import 'product_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InvoiceApp'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final crossAxisCount = isWide ? 4 : 2;
          final childAspectRatio = isWide ? 1.2 : 1.0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: [
                _MenuCard(
                  title: 'Product',
                  icon: Icons.shopping_bag_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                  ),
                ),
                _MenuCard(
                  title: 'Order History',
                  icon: Icons.history,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  ),
                ),
                _MenuCard(
                  title: 'Customer',
                  icon: Icons.people_outline,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                  ),
                ),
                _MenuCard(
                  title: 'Invoice',
                  icon: Icons.receipt_long,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BillingDetailScreen()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
