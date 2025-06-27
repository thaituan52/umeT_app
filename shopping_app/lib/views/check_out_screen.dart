import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/user.dart';

class CheckoutScreen extends StatefulWidget {
  final UserModel user;
  final Order order;

  const CheckoutScreen({super.key, required this.user, required this.order});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Future<void> _handlePayment() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Processing payment...")),
    );
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context, true); // return success flag
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Deliver To:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("${widget.user.displayName}"),
            Divider(height: 32),

            Text("Order Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("\$${widget.order.totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 22, color: Colors.orange, fontWeight: FontWeight.bold)),
            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.apple),
                label: Text("Pay with Apple Pay"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handlePayment,
              ),
            )
          ],
        ),
      ),
    );
  }
}
