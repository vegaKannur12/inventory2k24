import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:inventory24/MODEL/acHeadModel.dart';
import 'package:inventory24/MODEL/logModel.dart';
import 'package:inventory24/MODEL/regModel.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/login.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/registration.dart';
import 'package:inventory24/SCEENS/HOME/homePage.dart';
import 'package:inventory24/SCEENS/HOME/voucherEntry.dart';
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
  List<Map<String, dynamic>> voucherList = [];
  Map<String, dynamic>? selectedVoucher;
  List<Map<String, dynamic>> acHeadList = [];
  List<Map<String, dynamic>> filteredacHeadList = [];
  // Map<String, dynamic>? selectedACHead;
  late AcheadModel selectedACHead;
  late AcheadModel selectedACHead2;
  String? selected;
  String? selected2;
  List<Map<int, String>> drop_CRDB_items = [
    {1: "CR"},
    {2: "DB"},
  ];

  List<Map<int, String>> drop_CLPENDING_items = [
    {1: 'Cleared'},
    {2: 'Pending'}
  ];
  int? selectedCRDB;
  // late Map<int, String> selectedCRDBMap=drop_CRDB_items[0];
  int? selectedCLPENDING;
  List<Map<String, dynamic>> voucherDetailsList = [];
  double totalOfVcDEt = 0.0;
  bool regLoad = false;
  bool loginLoad = false;
  bool regCheckLoader = false;
  bool vcDetailsLoading = false;
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
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        // String? app = localStorage.getString('api_path');
        // // "http://192.168.18.168:8000";
        // String? regkey = localStorage.getString('reg_key');
        // String? comp_id = localStorage.getString('com_id');
        String? uu_id = localStorage.getString('uu_id');
        List com = await INVENT.instance.getCompanyData();
        if (com.isNotEmpty) {
          regkey = com[0]['regk'];
          app = com[0]['apipath'];
          print("Reg K........$regkey , API........$app");
          if (uu_id!.isEmpty) {
            CustomSnackbar csnak = CustomSnackbar();
            csnak.showSnackbar(context, "UUID missing", "");
          } else {
            int flg;

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
              // print("flag: $flg");
              print("msg: ${map['msg'].runtimeType}");
              print("flag: ${map['flag'].runtimeType}");
              print(
                  "branch_validate_id: ${map['branch_validate_id'].runtimeType}");
              print("session_id: ${map['session_id'].runtimeType}");
              print("user_id: ${map['user_id'].runtimeType}");
              print("user_print_name: ${map['user_print_name'].runtimeType}");
              print("user_type: ${map['user_type'].runtimeType}");
              print("company_id: ${map['company_id'].runtimeType}");
              print("branch_id: ${map['branch_id'].runtimeType}");
              print("company_name: ${map['company_name'].runtimeType}");
              print("company_state: ${map['company_state'].runtimeType}");
              print("company_GSTIN: ${map['company_GSTIN'].runtimeType}");
              if (flg == 0) {
                await INVENT.instance
                    .deleteFromTableCommonQuery("loginDetailsTable", "");
                LoginModel logmod = LoginModel.fromJson(map);
                await INVENT.instance.insertTologinDetailsTable(logmod);
                print("Login Success");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else {
                CustomSnackbar csnak = CustomSnackbar();
                csnak.showSnackbar(
                    context, "Login failed. Check username and password", "");
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
        } else {
          loginLoad = false;
          notifyListeners();
          CustomSnackbar csnak = CustomSnackbar();
          csnak.showSnackbar(context,
              "Error on accessing company data from local storage", "");
        }
      }
    });
  }

///////////////////////////////////////////////////////////////
  loadVoucherType(BuildContext context) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          voucherList.clear();
          notifyListeners();
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();

          String? regkey = localStorage.getString('reg_key');
          Uri url =
              Uri.parse("http://192.168.18.168:8000/api/load_voucher_type");
          Map body = {
            "token": regkey,
            "branch_id": "01",
            "company_id": "AB",
            "menu_prefix": "VE",
          };
          print("loadVoucherbody-----$body---$url-----$token");
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
          print("loadVouchermap --$map");
          if (map.isNotEmpty) {
            for (var item in map) {
              voucherList.add(item);
            }
            selectedVoucher = voucherList[0];
            notifyListeners();
            print("Voucher [] : $voucherList");
            print("selectedVoucher : $selectedVoucher");
          } else {
            print("voucher List is empty");
          }
        } on SocketException catch (e) {
          if (e.osError != null && e.osError!.errorCode == 110) {
            await showCommonErrorDialog(
                'Connection timed out. Please try again..',
                VoucherEntry(),
                context);
          } else {
            // print("SocketException");
            // ignore: use_build_context_synchronously
            await showCommonErrorDialog(
                'SocketException: ${e.message}', VoucherEntry(), context);
          }
        } catch (e) {
          await showCommonErrorDialog(
              'An unexpected error occurred: ${e.toString()}',
              VoucherEntry(),
              context);
        }
      }
    });
  }

  updateVoucher(Map<String, dynamic> newV) {
    selectedVoucher = newV;
    notifyListeners();
    print("updated Voucher: $selectedVoucher");
  }

  Future<List<AcheadModel>> filterACHeadList(
      BuildContext context, String query) {
    List<AcheadModel> list = [];
    filteredacHeadList = acHeadList.where((item) {
      return item['acc_name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();
    notifyListeners();
    print("filtered AC :$filteredacHeadList");
    for (var item in filteredacHeadList) {
      // customerList.add(item);
      list.add(AcheadModel.fromJson(item));
    }
    return Future.value(list);
  }

//////////////////////////////////////////////////////////////////////////
  loadAccountHead(BuildContext context) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          acHeadList.clear();
          notifyListeners();
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          String? regkey = localStorage.getString('reg_key');
          Uri url =
              Uri.parse("http://192.168.18.168:8000/api/load_account_head");
          Map body = {
            "token": regkey,
            "branch_id": "01",
            "company_id": "AB",
            'voucher_typ_acc_group': 0,
            "searchTerm": "ac",
          };
          print("AccountHeadbody-----$body---$url-----$token");
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
          print("AccountHeadmap --$map");
          if (map.isNotEmpty) {
            for (var item in map) {
              acHeadList.add(item);
            }
            // selectedACHead = acHeadList[0];
            notifyListeners();
            // print("AccountHead [] : $acHeadList");
            // print("selectedAccountHead : $selectedACHead");
          } else {
            print("voucher List is empty");
          }
        } on SocketException catch (e) {
          if (e.osError != null && e.osError!.errorCode == 110) {
            await showCommonErrorDialog(
                'Connection timed out. Please try again..',
                VoucherEntry(),
                context);
          } else {
            // print("SocketException");
            // ignore: use_build_context_synchronously
            await showCommonErrorDialog(
                'SocketException: ${e.message}', VoucherEntry(), context);
          }
        } catch (e) {
          await showCommonErrorDialog(
              'An unexpected error occurred: ${e.toString()}',
              VoucherEntry(),
              context);
        }
      }
    });
  }
/////////////////////////////Voucher SAVE///////////////////

  getVoucherSave(
    BuildContext context,
    String vc_date,
    String vc_ty_cod,
    String vc_acc,
    String vc_bk_typ,
    String vc_refno,
    String vc_ref_date,
    String vc_amt,
    String vc_narr,
    String vc_cleard,
    String vc_clr_date,
    String vc_typ_accTYP,
  ) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          String? regkey = localStorage.getString('reg_key');
          List log = await INVENT.instance.getTableData('loginDetailsTable');

          Uri url = Uri.parse("http://192.168.18.168:8000/api/VoucherSave");
          Map body = {
            "row_id": "0",
            "hidden_status": "0",
            "voucher_series": "",
            "voucher_date": vc_date,
            "voucher_type": vc_ty_cod, //voucher_type_code
            "voucher_acc": vc_acc,
            "voucher_doc_no": " ",
            "voucher_book_type": vc_bk_typ, //"CR",
            "voucher_ref_no": vc_refno,
            "voucher_ref_date": vc_ref_date,
            "voucher_amt": vc_amt,
            "voucher_naration": vc_narr,
            "voucher_cleared": vc_cleard, //"1"
            "voucher_clear_date": vc_clr_date,
            "voucher_typ_acc_type": vc_typ_accTYP,
            "det_arr": voucherDetailsList,
            "token": regkey, //reg_key
            "branch_id": log[0]['branch_id'].toString(),
            "company_id": log[0]['company_id'].toString(),
            "user_session": log[0]['session_id'].toString(), //uuid
            "branch_validate_id": log[0]['branch_validate_id'].toString(),
            "status": 0,
            "lock_status": 0,
            "log_user_id": log[0]['user_id'].toString(),
          };
          print("VoucherSave-----$body---$url-----$token");
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
          print("VoucherSaveMap --$map");
        } on SocketException catch (e) {
          if (e.osError != null && e.osError!.errorCode == 110) {
            await showCommonErrorDialog(
                'Connection timed out. Please try again..',
                VoucherEntry(),
                context);
          } else {
            // print("SocketException");
            // ignore: use_build_context_synchronously
            await showCommonErrorDialog(
                'SocketException: ${e.message}', VoucherEntry(), context);
          }
        } catch (e) {
          await showCommonErrorDialog(
              'An unexpected error occurred: ${e.toString()}',
              VoucherEntry(),
              context);
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

  updateVoucherList(Map<String, dynamic> vc) {
    vcDetailsLoading = true;
    notifyListeners();
    voucherDetailsList.add(vc);
    totalOfVcDEt = voucherDetailsList.fold(
        0, (sum, item) => sum + (item['voucher_det_amt'] ?? 0.0));
    vcDetailsLoading = false;
    notifyListeners();
  }

  List<DataColumn> createVCColumns() {
    return [
      DataColumn(label: Text('No.')),
      DataColumn(label: Text('Acc Code')),
      DataColumn(numeric: true, label: Text('Amount')),
      DataColumn(label: Text('')),
    ];
  }

  List<DataRow> createVCRows() {
    int i = 0;
    List<DataRow> rows = voucherDetailsList.map((item) {
      i++;
      return DataRow(cells: [
        DataCell(ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 100),
            child: Text("$i", overflow: TextOverflow.ellipsis))),
        DataCell(ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['voucher_det_acc_code'] ?? '',
                    overflow: TextOverflow.ellipsis),
                Text(item['voucher_det_naration'] ?? '',
                    overflow: TextOverflow.ellipsis)
              ],
            ))),
        DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(item['voucher_det_amt'].toStringAsFixed(2),
              overflow: TextOverflow.ellipsis),
        )),
        DataCell(
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              _deleteRow(item);
            },
          ),
        ),
      ]);
    }).toList();
    rows.add(
      DataRow(cells: [
        DataCell(Text('')),
        DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(totalOfVcDEt.toStringAsFixed(2),
            style: TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text('')),
      ]),
    );
    return rows;
  }

  _deleteRow(Map<String, dynamic> dlt) {
    voucherDetailsList.remove(dlt);
    notifyListeners();
  }

  update_CRDB(int data) {
    if (data == 1) {
      drop_CRDB_items.clear();
      drop_CRDB_items = [
        {1: "CR"},
        {2: "DB"},
      ];
    } else if (data == 2) {
      drop_CRDB_items.clear();
      drop_CRDB_items = [
        {2: "DB"},
        {1: "CR"},
      ];
    }
    notifyListeners();
    // selectedCRDB = data;
    // notifyListeners();
  }

  update_CLPENDING(int data) {
    if (data == 1) {
      drop_CLPENDING_items.clear();
      drop_CLPENDING_items = [
        {1: 'Cleared'},
        {2: 'Pending'}
      ];
      selectedCLPENDING = data;
    } else if (data == 2) {
      drop_CLPENDING_items.clear();
      drop_CLPENDING_items = [
        {2: 'Pending'},
        {1: 'Cleared'},
      ];
      selectedCLPENDING = data;
    }
    notifyListeners();
    // selectedCRDB = data;
    // notifyListeners();
  }

  update_CLPENDINGval(int data) {
    selectedCLPENDING = data;
    notifyListeners();
  }
}
