import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inventory24/CONTROLLER/controller.dart';
import 'package:inventory24/WIDGETSCOMMON/C_scaffold.dart';
import 'package:inventory24/WIDGETSCOMMON/C_textfield.dart';
import 'package:inventory24/db_helper.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ValueNotifier<bool> _isObscure = ValueNotifier(true);
  final _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController(text: "123");
  TextEditingController password = TextEditingController(text: "123");
  bool pageload = false;
  @override
  void initState() {
    // TODO: implement initState
    pageload = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pageload = false;
    Size size = MediaQuery.of(context).size;
    double topInsets = MediaQuery.of(context).viewInsets.top;
    return SafeArea(
      child: CustomScaffold(
        resizeInset: true,
        child: pageload
            ? SpinKitCircle(
                color: Colors.black,
              )
            : SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)),
                              border: Border.all(color: Colors.white)),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: size.width * 0.02,
                                          ),
                                          Text(
                                            "Login To Your Account",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.height * 0.03,
                                      ),
                                      Widget_TextField(
                                        controller: username,
                                        obscureNotifier: ValueNotifier<bool>(
                                            false), // For non-password field, you can set any initial value
                                        hintText: 'Username',
                                        prefixIcon: Icons.person,
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Please Enter Username';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Widget_TextField(
                                        controller: password,
                                        obscureNotifier: ValueNotifier<bool>(
                                            true), // For password field, you can set any initial value
                                        hintText: 'Password',
                                        prefixIcon: Icons.lock,
                                        isPassword: true,
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Please Enter Password';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: size.height * 0.03,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                await Provider.of<Controller>(
                                                        context,
                                                        listen: false)
                                                    .getLogin(
                                                        context,
                                                        username.text,
                                                        password.text);
                                              }
                                              // commnted
                                              //   //  Provider.of<Controller>(context, listen: false)
                                              //   //     .getLogin(
                                              //   //         'floor4','997', context);
                                              //   if (Provider.of<Controller>(context,
                                              //           listen: false)
                                              //       .incorect)
                                              //   {
                                              //     CustomSnackbar snackbar =
                                              //         CustomSnackbar();
                                              //     snackbar.showSnackbar(
                                              //         context,
                                              //         "Incorrect Username or Password",
                                              //         "");
                                              //   }
                                              //   else
                                              //   {
                                              //     Navigator.push(
                                              //       context,
                                              //       MaterialPageRoute(
                                              //           builder: (context) => MainHome()),
                                              //     );
                                              //   }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: Consumer<Controller>(builder:
                                                (BuildContext context,
                                                    Controller value,
                                                    Widget? child) {
                                              if (value.loginLoad) {
                                                return  Padding(
                                                   padding:
                                                      const EdgeInsets.all(
                                                         12),
                                                  child: SpinKitThreeBounce(
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                );
                                              } else {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12.0,
                                                          bottom: 12),
                                                  child: Text(
                                                    "LOGIN",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17,
                                                        color: Theme.of(context)
                                                            .cardColor),
                                                  ),
                                                );
                                              }
                                            }),
                                            // Padding(
                                            //   padding: const EdgeInsets.only(
                                            //       top: 12.0, bottom: 12),
                                            //   child: Text(
                                            //     "LOGIN",
                                            //     style: TextStyle(
                                            //         fontWeight:
                                            //             FontWeight.bold,
                                            //         fontSize: 17,
                                            //         color: Theme.of(context)
                                            //             .cardColor),
                                            //   ),
                                            // ),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
