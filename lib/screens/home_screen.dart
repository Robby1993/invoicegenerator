import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicegenerator/screens/billing_detail_screen.dart';
import 'package:invoicegenerator/utils/responsive.dart';
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
    Responsive.init(context);
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss on outside touch
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.exit_to_app,
                size: 48.i,
                color: Colors.black,
              ),
              SizedBox(height: 16.h),
              Text(
                "Exit App",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              const Text(
                "Are you sure you want to exit the app?",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(fontSize: 14.sp)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      SystemNavigator.pop();
                    },
                    child: Text(
                      "Exit",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
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
    Responsive.init(context);
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
          title: Text('Invoice App', style: TextStyle(fontSize: 20.sp)),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final crossAxisCount = isWide ? 4 : 2;
            final childAspectRatio = isWide ? 1.2 : 1.0;

            return Padding(
              padding: EdgeInsets.all(16.r),
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
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
    Responsive.init(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.i),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
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
