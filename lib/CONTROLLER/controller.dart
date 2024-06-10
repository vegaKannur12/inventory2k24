import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:inventory24/MODEL/regModel.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/login.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/registration.dart';
import 'package:inventory24/SCEENS/HOME/homePage.dart';
import 'package:inventory24/SCEENS/splashScreen.dart';
import 'package:inventory24/WIDGETSCOMMON/C_errorDialog.dart';
import 'package:inventory24/WIDGETSCOMMON/C_networkcon.dart';
import 'package:inventory24/WIDGETSCOMMON/C_snackbar.dart';
import 'package:inventory24/db_helper.dart';
import 'package:inventory24/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

class Controller extends ChangeNotifier {
  String token = "";
  String c_id = "";
  String dev_id = 'Unknown';
  bool regLoad = false;
  bool loginLoad = false;
  bool regCheckLoader = false;
  // int? flg;
  getregistration(BuildContext context, String? regkey) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        int flg;
        regLoad = true;
        notifyListeners();
        try {
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          String? uu = localStorage.getString('uu_id');
          Uri url = Uri.parse("http://192.168.18.168:8000/api/verify_reg");
          Map body = {'reg_key': regkey, 'uuid': uu};
          print("REGbody-----$body---$url-----$token");
          token = localStorage.getString('token') ?? " ";
          http.Response response =
              await http.post(url, body: jsonEncode(body), headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          }).timeout(Duration(seconds: 5), onTimeout: () {
            throw SocketException("Connection timed out",
                osError: OSError("", 110));
          });
          var map = jsonDecode(response.body);
          print("REGmap --$map");
          flg = map['flag'];
          print("flag: $flg");
          if (flg == 0) {
            await INVENT.instance
                .deleteFromTableCommonQuery("companyRegistrationTable", "");
            RegisterModel regModel = RegisterModel.fromJson(map);
            await INVENT.instance.insertToCompanyRegistration(regModel);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            // c_id = regModel.com_id!;
            print(("CID : ${regModel.com_id!}"));
            prefs.setString("com_id", regModel.com_id!);
            prefs.setString("com_name", regModel.com_name!);
            prefs.setString("reg_key", regModel.reg_key!);
            prefs.setString("api_path", regModel.api_path!);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LoadingOverlay(child: LoginPage()),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            CustomSnackbar csnak = CustomSnackbar();
            csnak.showSnackbar(context, "Registration failed", "");
          }
          regLoad = false;
          notifyListeners();
        } on SocketException catch (e) {
          regLoad = false;
          notifyListeners();
          if (e.osError != null && e.osError!.errorCode == 110) {
            await showCommonErrorDialog(
                'Connection timed out. Please try again..',
                Registration(),
                context);
          } else {
            // print("SocketException");
            // ignore: use_build_context_synchronously
            await showCommonErrorDialog(
                'SocketException: ${e.message}', Registration(), context);
          }
        } catch (e) {
          regLoad = false;
          await showCommonErrorDialog(
              'An unexpected error occurred: ${e.toString()}',
              Registration(),
              context);
        }
      }
    });
  }

  Future<int> checkRegistered(BuildContext context) async {
    int isAuthenticated = 0; // Default to false in case of any issues
    try {
      regCheckLoader = true;
      notifyListeners();
      await uniqueID();
      bool value = await NetConnection.networkConnection(context);
      if (value) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        String? uu_id = localStorage.getString('uu_id');
        String token = localStorage.getString('token') ?? " ";
        Uri url = Uri.parse("http://192.168.18.168:8000/api/check_uuid");
        Map body = {'uuid': uu_id};
        print("CheckREGbody-----$body---$url-----$token");
        print("uuid : $uu_id");
        http.Response response = await http.post(
          url,
          body: jsonEncode(body),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(Duration(seconds: 5), onTimeout: () {
          throw SocketException("Connection timed out",
              osError: OSError("", 110));
        });
        var map = jsonDecode(response.body);
        print("CheckREGmap --$map");
        int count = map['count'];
        int active = map['active'];
        print("count: $count \nactive: $active");

        if (count == 1 && active == 0) {
          print("Already Registered");
          isAuthenticated = 1;
        }
        
      } else {
        throw SocketException("No network connection available",
            osError: OSError("", 101));
      }
      regCheckLoader = false;
      notifyListeners();
    } on SocketException catch (e) {
      isAuthenticated = 2;
      regCheckLoader = false;
      notifyListeners();
      if (e.osError != null && e.osError!.errorCode == 110) {
        await showCommonErrorDialog('Connection timed out. Please try again..',
            SplashScreen(), context);
      } else if (e.osError != null && e.osError?.errorCode == 101) {
        await showCommonErrorDialog(
            'No internet connection. Please check your network settings and try again.',
            SplashScreen(),
            context);
      } else {
        // print("SocketException");
        // ignore: use_build_context_synchronously
        await showCommonErrorDialog(
            'SocketException: ${e.message}', SplashScreen(), context);
      }
    } catch (e) {
      isAuthenticated = 2;
      regCheckLoader = false;
      notifyListeners();
      await showCommonErrorDialog(
          'An unexpected error occurred: ${e.toString()}',
          SplashScreen(),
          context);
    }
    return isAuthenticated;
  }

  Future<void> uniqueID() async {
    String ident;
    try {
      ident = (await UniqueIdentifier.serial)!;
    } on PlatformException {
      ident = 'Failed to get Unique Identifier';
    }

    // if (!mounted) return;
    dev_id = ident;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("uu_id", dev_id);
    notifyListeners();
  }

  getLogin(BuildContext context, String? user_name, String user_pass) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        loginLoad = true;
        notifyListeners();
        String? regkey;
        String? app;
        List com = await INVENT.instance.getCompanyData();
        if (com.isNotEmpty) {
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          // String? app = localStorage.getString('api_path');
          // // "http://192.168.18.168:8000";
          // String? regkey = localStorage.getString('reg_key');
          // String? comp_id = localStorage.getString('com_id');
          String? uu_id = localStorage.getString('uu_id');
          int flg;

          regkey = com[0]['regk'];
          app = com[0]['apipath'];
          print("Reg K........$regkey , API........$app");
          try {
            Uri url = Uri.parse("${app}api/login");
            Map body = {
              'user_name': user_name,
              'user_pass': user_pass,
              'token': regkey,
              'branch_id': "01",
              'uuid': uu_id
            };
            //  Map body = {                            //To test
            //   'user_name': 123,
            //   'user_pass': 123,
            //   'token': "abc",
            //   'branch_id': "01",
            //   'uuid': "uu123"
            // };
            print("LOGbody-----$body---$url-----$token");
            print("uuid : $uu_id");
            token = localStorage.getString('token') ?? " ";
            http.Response response =
                await http.post(url, body: jsonEncode(body), headers: {
              'Content-type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token'
            }).timeout(Duration(seconds: 5), onTimeout: () {
              throw SocketException("Connection timed out",
                  osError: OSError("", 110));
            });
            var map = jsonDecode(response.body);
            print("LOGmap --$map");
            flg = map['flag'];
            print("flag: $flg");
            if (flg == 0) {
              print("Login Success");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else {
              CustomSnackbar csnak = CustomSnackbar();
              csnak.showSnackbar(context, "Login failed", "");
            }
            loginLoad = false;
            notifyListeners();
            // ignore: empty_catches
          } on SocketException catch (e) {
            loginLoad = false;
            notifyListeners();
            if (e.osError != null && e.osError!.errorCode == 110) {
              await showCommonErrorDialog(
                  'Connection timed out. Please try again..',
                  LoginPage(),
                  context);
            } else {
              // print("SocketException");
              // ignore: use_build_context_synchronously
              await showCommonErrorDialog(
                  'SocketException: ${e.message}', LoginPage(), context);
            }
          } catch (e) {
            loginLoad = false;
            notifyListeners();
            await showCommonErrorDialog(
                'An unexpected error occurred: ${e.toString()}',
                LoginPage(),
                context);
          }
        }
      }
    });
  }

  ////////////////////////GetBILLNo////////////////////////
  getBillno(BuildContext context) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          String? regkey = localStorage.getString('reg_key');
          Uri url =
              Uri.parse("http://192.168.18.168:8000/api/Get_Trans_BillNo");
          Map body = {
            "row_id": "0",
            "hidden_status": "0",
            "mast_type": "SU",
            "token": regkey,
            "branch_id": "01",
            "company_id": "AB",
            "user_session": "AB01290220240003",
            "branch_validate_id": "AB01",
            "status": "0",
            "lock_status": "0",
            "log_user_id": "AB011"
          };
          print("Billnobody-----$body---$url-----$token");
          token = localStorage.getString('token') ?? " ";
          http.Response response =
              await http.post(url, body: jsonEncode(body), headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          }).timeout(const Duration(seconds: 10), onTimeout: () {
            throw const SocketException("Connection timed out",
                osError: OSError("", 110));
          });
          var map = jsonDecode(response.body);
          print("Billnomap --$map");
        } on SocketException catch (e) {
          if (e.osError != null && e.osError!.errorCode == 110) {
            await showCommonErrorDialog(
                'Connection timed out. Please try again..',
                HomePage(),
                context);
          } else {
            // print("SocketException");
            // ignore: use_build_context_synchronously
            await showCommonErrorDialog(
                'SocketException: ${e.message}', HomePage(), context);
          }
        } catch (e) {
          await showCommonErrorDialog(
              'An unexpected error occurred: ${e.toString()}',
              HomePage(),
              context);
        }
      }
    });
  }

/////////////////////////////////ACCMSave///////////////////////////////
  getSave(BuildContext context) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          bool containsFlagWithValue;
          bool containsError;
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          String? regkey = localStorage.getString('reg_key');
          Uri url = Uri.parse("http://192.168.18.168:8000/api/AccMSave");
          // Map body = {
          //   "row_id": "0",
          //   "hidden_status": "0",
          //   "acc_name": "",
          //   "acc_short": "",
          //   "acc_group": "",
          //   "acc_master_type": "",
          //   "acc_ext_gstin": "",
          //   "acc_ext_phone1": "",
          //   "acc_ext_phone2": "",
          //   "acc_ext_email": "",
          //   "acc_ext_state": "",
          //   "acc_ext_place": "",
          //   "acc_ext_pin": "",
          //   "acc_ext_add1": "",
          //   "acc_ext_add2": "",
          //   "acc_ext_add3": "",
          //   "acc_type": 1,
          //   "token": regkey,
          //   "branch_id": "01",
          //   "company_id": "AB",
          //   "user_session": "AB01080620240001",
          //   "branch_validate_id": "AB01",
          //   "status": 0,
          //   "lock_status": 0,
          //   "log_user_id": "AB011"
          // };
          Map body = {
            "row_id": "0",
            "hidden_status": "0",
            "acc_name": "test2",
            "acc_short": "acshot",
            "acc_group": "bgrop",
            "acc_master_type": "AMTYPE",
            "acc_ext_gstin": "",
            "acc_ext_phone1": "",
            "acc_ext_phone2": "",
            "acc_ext_email": "",
            "acc_ext_state": "",
            "acc_ext_place": "",
            "acc_ext_pin": "",
            "acc_ext_add1": "",
            "acc_ext_add2": "",
            "acc_ext_add3": "",
            "acc_type": 1,
            "token": regkey,
            "branch_id": "01",
            "company_id": "AB",
            "user_session": "AB01080620240001",
            "branch_validate_id": "AB01",
            "status": 0,
            "lock_status": 0,
            "log_user_id": "AB011"
          };
          print("AcSavebody-----$body---$url-----$token");
          token = localStorage.getString('token') ?? " ";
          http.Response response =
              await http.post(url, body: jsonEncode(body), headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          });
          var map = jsonDecode(response.body);
          print("AcSavemap --$map");
          if (map != null) {
            if (map is List) {
              containsFlagWithValue =
                  map.any((element) => element['flag'] == 0);

              if (containsFlagWithValue) {
                print("saved..$containsFlagWithValue");
              }
            } else if (map is Map) {
              containsError = map.containsKey('errors');
              if (containsError) {
                print("Failed with Errors");
              }
            }
          } else {
            print('Failed');
          }
        } catch (e) {}
      }
    });
  }
}
