import 'package:flutter/material.dart';
import 'package:inventory24/CONTROLLER/controller.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/login.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/registration.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  int isRegistered = 0;

  navigateTo() async {
    await Future.delayed(Duration(seconds: 1), () async {
      isRegistered = await Provider.of<Controller>(context, listen: false)
          .checkRegistered(context);
      print("Is Reg? $isRegistered");
      if (isRegistered != 2) { 
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false, // set to false
          pageBuilder: (_, __, ___) {
            if (isRegistered == 1) {
              return const LoginPage();
            } else if (isRegistered == 0) {
              return const Registration();
            } else {
              return SplashScreen();
            }
          },
        ),
      );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navigateTo();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<Controller>(
      builder: (BuildContext context, Controller value, Widget? child) { 
         return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.deepPurple,
        body: InkWell(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Center(
              child: Column(
            children: [
              Expanded(
                child: Container(
                  height: 150,
                  width: 150,
                  child: Image.asset(
                    "assets/vega.png",
                  ),
                ),
              ),
            ],
          )),
        ),
        bottomNavigationBar: value.regCheckLoader? LinearProgressIndicator( backgroundColor: Colors.red,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),):Container()
      );
       },
     
    );
  }
}
