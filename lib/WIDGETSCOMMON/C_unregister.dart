import 'package:flutter/material.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/registration.dart';

class Unreg {
  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Registration()));
      },
    );
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
         Navigator.of(context).pop(false);
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (context) => HomeFloorBill()));
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Do you want to unregister!!",style: TextStyle(fontSize: 20),),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
