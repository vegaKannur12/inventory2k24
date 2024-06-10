import 'package:flutter/material.dart';
import 'package:inventory24/SCEENS/splashScreen.dart';

Future<void> showCommonErrorDialog(String message,Widget gotoPage, BuildContext context) async {
  showDialog(barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message,style: TextStyle(fontSize: 16),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              // Within the `FirstRoute` widget
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => gotoPage),
              );
            },
            child: Text('Try Again'),
          ),
        ],
      );
    },
  );
}
