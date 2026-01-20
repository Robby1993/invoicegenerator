import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicegenerator/screens/billing_detail_screen.dart';
import 'product_list_screen.dart';
import 'customer_list_screen.dart';
import 'order_history_screen.dart';
import 'product_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;

  bool _onPopInvoked() {
    final now = DateTime.now();
    const duration = Duration(seconds: 2);

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > duration) {
      _lastBackPressTime = now;
      showExitDialog(context);
      return false; // Prevent exit
    }
    return true; // Allow exit
  }

  void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss on outside touch
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.exit_to_app,
                size: 48,
                color: Colors.black,
              ),
              const SizedBox(height: 16),
              const Text(
                "Exit App",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Are you sure you want to exit the app?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      SystemNavigator.pop();
                    },
                    child: const Text(
                      "Exit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Override default back behavior
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // Return if the page was already popped

        // If on the first page, apply double back-press to exit
        if (_onPopInvoked()) {
          SystemNavigator.pop(); // Exit the app
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invoice App'),
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
