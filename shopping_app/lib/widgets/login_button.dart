import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String method;
  final String? selectedMethod;
  final ValueChanged<String?>? onMethodSelected;
  final IconData icon;
  final Color iconColor;
  final bool isLoading; //used to check if the signin is loading or nor

  const LoginButton({
    super.key,
    required this.method,
    required this.selectedMethod,
    this.onMethodSelected,
    required this.icon,
    required this.iconColor,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onMethodSelected?.call(method), // Call the callback when the button is pressed
      style: ElevatedButton.styleFrom(
        backgroundColor: method == 'Apple' ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      // child: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Icon(icon, color: iconColor, size: 30),
      //     const SizedBox(width: 10),
      //     Text('Continue with $method', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: method == 'Apple' ? Colors.white : Colors.black)),
      //   ],
      // ),


      //vibe coding  make the button have a nice look
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  method == 'Apple' ? Colors.white : Colors.black,
                ),
              ),
            )
          else
            Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 10),
          Text(
            isLoading ? 'Signing in...' : 'Continue with $method',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: method == 'Apple' ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

