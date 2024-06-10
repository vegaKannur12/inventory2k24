import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inventory24/CONTROLLER/controller.dart';
import 'package:inventory24/WIDGETSCOMMON/C_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  // ExternalDir externalDir = ExternalDir();
  TextEditingController company = TextEditingController(text: "abc");

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  late String uniqId;
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  String? manufacturer;
  String? model;
  String? fp;

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        manufacturer = deviceData["manufacturer"];
        model = deviceData["model"];
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'manufacturer': build.manufacturer,
      'model': build.model,
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deletemenu();
    initPlatformState();
  }

  deletemenu() async {
    print("delete");
    // await OrderAppDB.instance.deleteFromTableCommonQuery('menuTable', "");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double topInsets = MediaQuery.of(context).viewInsets.top;
    return CustomScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(40.0),
                      ),
                      border: Border.all(color: Colors.white)),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: size.width * 0.02,
                              ),
                              Text(
                                "Get Started",
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.04,
                          ),
                          TextFormField(
                            controller: company,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Please Enter Company key';
                              }
                              return null;
                            },
                            scrollPadding: EdgeInsets.only(
                                bottom: topInsets + size.height * 0.18),
                            decoration: InputDecoration(
                                // border: InputBorder.none,hope(juLiuukj).kilookkjjjjjsfssnm{[]}
                                contentPadding: EdgeInsets.only(
                                    left: 10.0, top: 15.0, bottom: 15.0),
                                // fillColor: Color.fromARGB(255, 235, 232, 232),
                                // filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 119, 119, 119),
                                      width: 1),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 119, 119, 119),
                                      width: 1),
                                ),
                                prefixIcon:
                                    const Icon(Icons.business, size: 16),
                                hintText: 'Company Key',
                                hintStyle: const TextStyle(fontSize: 14)),
                          ),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      Provider.of<Controller>(context,
                                              listen: false)
                                          .getregistration(
                                              context, company.text);
                                    }
                                    // String deviceInfo =
                                    //     "$manufacturer" + '' + "$model";
                                    // if (_formKey.currentState!.validate()) {
                                    //   String tempFp1 =
                                    //       await externalDir.fileRead();

                                    //   print("tempFp---${tempFp1}");

                                    //   Provider.of<Controller>(context,
                                    //           listen: false)
                                    //       .postRegistrationTest(
                                    //           company.text,
                                    //           tempFp1,
                                    //           phone.text,
                                    //           deviceInfo,
                                    //           context);
                                    // }
                                  },
                                  child: Consumer<Controller>(builder:
                                      (BuildContext context, Controller value,
                                          Widget? child) {
                                    if (value.regLoad) {
                                      return SpinKitThreeBounce(
                                        color: Colors.white,
                                        size: 15,
                                      );
                                    } 
                                    else 
                                    {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12.0, bottom: 12),
                                        child: Text(
                                          "PROCEED",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor),
                                        ),
                                      );
                                    }
                                  }),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black),
                                )
                              ]),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
    // return Scaffold(
    //   body: Container(
    //     height: 300,
    //     width: 300,
    //     child: ElevatedButton(
    //         onPressed: () {
    //           Provider.of<Controller>(context, listen: false)
    //               .postRegistrationTest('GRQS87TVLTUY', '', '1236547890',
    //                   'RealmeRMX1941', context);
    //         },
    //         child: Text("REG-TEST")),
    //   ),
    // );
  }
}
