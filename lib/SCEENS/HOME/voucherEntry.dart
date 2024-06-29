import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory24/CONTROLLER/controller.dart';
import 'package:inventory24/MODEL/acHeadModel.dart';
import 'package:inventory24/WIDGETSCOMMON/C_datepicker.dart';
import 'package:inventory24/WIDGETSCOMMON/C_snackbar.dart';
import 'package:inventory24/WIDGETSCOMMON/C_textfield.dart';
import 'package:provider/provider.dart';

class VoucherEntry extends StatefulWidget {
  const VoucherEntry({super.key});

  @override
  State<VoucherEntry> createState() => _VoucherEntryState();
}

class _VoucherEntryState extends State<VoucherEntry> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController refdateController = TextEditingController();
  TextEditingController cleareddateController = TextEditingController();
  TextEditingController accheadController = TextEditingController();
  TextEditingController amtController = TextEditingController();
  TextEditingController crDebController = TextEditingController();
  TextEditingController narrationController = TextEditingController();
  TextEditingController refnoController = TextEditingController();

  //////////////////////
  TextEditingController accheadController2 = TextEditingController();
  TextEditingController amtController2 = TextEditingController();
  TextEditingController narrationController2 = TextEditingController();
  final GlobalKey expansionTileKey = GlobalKey();

  @override
  // void initState() {
  //   super.initState();
  //   _dateController = TextEditingController();
  // }
  //  @override
  void dispose() {
    dateController.dispose();
    refdateController.dispose();
    cleareddateController.dispose();
    accheadController.dispose();
    amtController.dispose();
    crDebController.dispose();
    narrationController.dispose();
    refnoController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    bool isExpanded = false;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Consumer<Controller>(
              builder: (BuildContext context, Controller value, Widget? child) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                    height: 40,
                                    child: DatePickerForm(
                                      controller: dateController,
                                    )),
                              ),
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 40,
                                  child: DropdownButtonFormField<
                                      Map<String, dynamic>>(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                    ),
                                    //  value.selected == null
                                    //                                           ? "Select Account Head"
                                    //                                           : selectedItem!.accName.toString(),
                                    value: value.selectedVoucher,
                                    hint: Text('Select Voucher Type'),
                                    items: value.voucherList
                                        .map((Map<String, dynamic> values) {
                                      return DropdownMenuItem<
                                          Map<String, dynamic>>(
                                        value: values,
                                        child: Text(
                                          values["voucher_typ_name"].toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        Provider.of<Controller>(context,
                                                listen: false)
                                            .updateVoucher(newValue!);
                                        print(
                                            "${value.selectedVoucher!["voucher_typ_acc_type"].runtimeType}");
                                        if (value.selectedVoucher![
                                                "voucher_typ_acc_type"] ==
                                            1) {
                                          value.update_CRDB(1);
                                        } else {
                                          value.update_CRDB(2);
                                        }
                                        if (value.selectedVoucher![
                                                "voucher_typ_clear_status"] ==
                                            1) {
                                          value.update_CLPENDING(1);
                                        } else {
                                          value.update_CLPENDING(2);
                                        }
                                        // value.selectedVoucher = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 40,
                                  // height: size.height * 0.06,
                                  child: IgnorePointer(
                                    ignoring: false,
                                    // ignoring: value.isfreez ? true : false,
                                    child: DropdownSearch<AcheadModel>(
                                      dropdownBuilder: (context, selectedItem) {
                                        return Text(
                                          value.selected == null
                                              ? "Select Account Head"
                                              : selectedItem!.accName
                                                  .toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        );
                                      },
                                      // selectedItem: _selected,
                                      validator: (text) {
                                        if (text == null) {
                                          return 'Please Select AC Head';
                                        }
                                        return null;
                                      },
                                      // key: _key1,

                                      itemAsString: (item) =>
                                          item.accName.toString(),
                                      asyncItems: (filter) =>
                                          Provider.of<Controller>(context,
                                                  listen: false)
                                              .filterACHeadList(
                                                  context, filter),
                                      popupProps: PopupProps.menu(
                                        // showSelectedItems: true,
                                        isFilterOnline: true,
                                        showSearchBox: true,
                                        searchFieldProps: TextFieldProps(
                                          controller: accheadController,
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              hintText: "Type Here",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 17),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              )),
                                        ),
                                      ),
                                      // items: ["anu", "shilpa", "danush"],

                                      onChanged: (values) {
                                        value.selectedACHead = values!;
                                        value.selected = values.accName;
                                        print(
                                            "selected acHead  : ${value.selectedACHead}");
                                        // value.setcustomerId(values.accId.toString(), context);
                                      },

                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5,
                                                              horizontal: 10),
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      // hintText: "Select Customer",
                                                      hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 10),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ))),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 40,
                                  child: Widget_TextField(
                                    controller: narrationController,
                                    obscureNotifier: ValueNotifier<bool>(
                                        false), // For password field, you can set any initial value
                                    hintText: 'Narration',
                                    prefixIcon: Icons.lock,
                                    isPassword: false,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Narration';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 40,
                                  child: Widget_TextField(
                                    keyboardType: TextInputType.number,
                                    controller: amtController,
                                    obscureNotifier: ValueNotifier<bool>(
                                        false), // For password field, you can set any initial value
                                    hintText: 'Amount',
                                    prefixIcon: Icons.money,
                                    isPassword: false,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Amount';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 3),
                                  child: SizedBox(
                                    height: 40,
                                    child: DropdownButtonFormField<
                                        Map<int, String>>(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black45),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black45),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.black45),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 6)),
                                      value: value.drop_CRDB_items.first,
                                      items: value.drop_CRDB_items.map((item) {
                                        int mapkey = item.keys.first;
                                        String mapvalue = item[mapkey]!;
                                        return DropdownMenuItem<
                                            Map<int, String>>(
                                          value: item,
                                          child: Text(
                                            mapvalue,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (values) {
                                        setState(() {
                                          value.selectedCRDB =
                                              values!.keys.first;
                                          // int.parse(values!.keys.first.toString());
                                          print(
                                              "selected_CRBD .........:${value.selectedCRDB}");
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )
                              //         // SizedBox(
                              //         //     width: 50,
                              //         //     height: 40,
                              //         //     child: TextFormField(
                              //         //       controller: _crDebController,
                              //         //       decoration: InputDecoration(
                              //         //         contentPadding: EdgeInsets.only(
                              //         //             left: 10.0, top: 15.0, bottom: 15.0),
                              //         //         focusedBorder: OutlineInputBorder(
                              //         //           borderRadius:
                              //         //               BorderRadius.all(Radius.circular(10.0)),
                              //         //           borderSide: const BorderSide(
                              //         //               color: Color.fromARGB(255, 119, 119, 119),
                              //         //               width: 1),
                              //         //         ),
                              //         //         errorBorder: OutlineInputBorder(
                              //         //           borderRadius:
                              //         //               BorderRadius.all(Radius.circular(10.0)),
                              //         //           borderSide: const BorderSide(
                              //         //               color: Colors.red, width: 1),
                              //         //         ),
                              //         //         enabledBorder: OutlineInputBorder(
                              //         //          borderRadius:
                              //         //               BorderRadius.all(Radius.circular(10.0)),
                              //         //           borderSide: const BorderSide(
                              //         //               color: Color.fromARGB(255, 119, 119, 119),
                              //         //               width: 1),
                              //         //         ),
                              //         //         hintStyle: const TextStyle(fontSize: 14),
                              //         //       ),
                              //         //     ))
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 40,
                                  child: Widget_TextField(
                                    keyboardType: TextInputType.number,
                                    controller: refnoController,
                                    obscureNotifier: ValueNotifier<bool>(
                                        false), // For password field, you can set any initial value
                                    hintText: 'Ref.No',
                                    prefixIcon: Icons.lock,
                                    isPassword: false,
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return 'Please Enter Ref.No';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                    height: 40,
                                    child: DatePickerForm(
                                      hintText: "Ref. Date",
                                      controller: refdateController,
                                    )),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 40,
                                  child:
                                      DropdownButtonFormField<Map<int, String>>(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black45),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black45),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black45),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 6)),
                                    value: value.drop_CLPENDING_items.first,
                                    items:
                                        value.drop_CLPENDING_items.map((item) {
                                      int mapkey = item.keys.first;
                                      String mapvalue = item[mapkey]!;
                                      return DropdownMenuItem<Map<int, String>>(
                                        value: item,
                                        child: Text(mapvalue),
                                      );
                                    }).toList(),
                                    onChanged: (values) {
                                      setState(() {
                                        value.selectedCLPENDING =
                                            values!.keys.first;
                                        // int.parse(values!.keys.first.toString());
                                        print(
                                            "selected_CLPENDING .........:${value.selectedCLPENDING}");
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                    height: 45,
                                    child: DatePickerForm(
                                      hintText: "Cleared Date",
                                      controller: cleareddateController,
                                    )),
                              )
                            ],
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            thickness: 3,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          // ExpansionTile(
                          //   key: expansionTileKey,
                          //   initiallyExpanded: isExpanded,
                          //   onExpansionChanged: (bool expanding) =>
                          //       setState(() => isExpanded = expanding),
                          //   title: Text(
                          //     "ADD Voucher Details",
                          //     style: TextStyle(
                          //       color: Colors.blue,
                          //     ),
                          //   ),
                          //   children: [
                          Container(
                            color: Colors.pink[50],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: SizedBox(
                                          height: 40,
                                          // height: size.height * 0.06,
                                          child: DropdownSearch<AcheadModel>(
                                            dropdownBuilder:
                                                (context, selectedItem2) {
                                              return Text(
                                                value.selected2 == null
                                                    ? "Select Account Head"
                                                    : selectedItem2!.accName
                                                        .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              );
                                            },
                                            // selectedItem: _selected,
                                            validator: (text) {
                                              if (text == null) {
                                                return 'Please Select AC Head';
                                              }
                                              return null;
                                            },
                                            // key: _key1,

                                            itemAsString: (item) =>
                                                item.accName.toString(),
                                            asyncItems: (filter) =>
                                                Provider.of<Controller>(context,
                                                        listen: false)
                                                    .filterACHeadList(
                                                        context, filter),
                                            popupProps: PopupProps.menu(
                                              // showSelectedItems: true,
                                              isFilterOnline: true,
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                controller: accheadController2,
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 10),
                                                    hintText: "Type Here",
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 17),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    )),
                                              ),
                                            ),
                                            // items: ["anu", "shilpa", "danush"],

                                            onChanged: (valuess) {
                                              value.selectedACHead2 = valuess!;
                                              value.selected2 = valuess.accName;
                                              print(
                                                  "selected acHead2  : ${value.selectedACHead2}");
                                              // value.setcustomerId(values.accId.toString(), context);
                                            },

                                            dropdownDecoratorProps:
                                                DropDownDecoratorProps(
                                                    dropdownSearchDecoration:
                                                        InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            5,
                                                                        horizontal:
                                                                            10),
                                                            fillColor:
                                                                Colors.white,
                                                            filled: true,
                                                            // hintText: "Select Customer",
                                                            hintStyle: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontSize: 10),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ))),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: SizedBox(
                                          height: 40,
                                          child: Widget_TextField(
                                            controller: narrationController2,
                                            obscureNotifier: ValueNotifier<
                                                    bool>(
                                                false), // For password field, you can set any initial value
                                            hintText: 'Narration',
                                            prefixIcon: Icons.lock,
                                            isPassword: false,
                                            validator: (text) {
                                              if (text == null ||
                                                  text.isEmpty) {
                                                return 'Please Enter Narration';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 150,
                                        child: Widget_TextField(
                                          keyboardType: TextInputType.number,
                                          controller: amtController2,
                                          obscureNotifier: ValueNotifier<bool>(
                                              false), // For password field, you can set any initial value
                                          hintText: '',
                                          prefixIcon: Icons.money,
                                          isPassword: false,
                                          validator: (text) {
                                            if (text == null || text.isEmpty) {
                                              return 'Please Enter Amount';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        Map<String, dynamic> vc = {};
                                        vc['voucher_det_acc_code'] = value
                                            .selectedACHead2.accCode
                                            .toString();
                                        vc['voucher_det_naration'] =
                                            narrationController2.text;
                                        vc['voucher_det_balance'] = "";
                                        vc['voucher_det_byto'] = "";
                                        vc['voucher_det_op_code'] = "";
                                        vc['voucher_det_amt'] =
                                            double.parse(amtController2.text);
                                        value.updateVoucherList(vc);
                                        print(
                                            "voucherDetailsList  : ${value.voucherDetailsList}");
                                      },
                                      child: Icon(
                                        size: 30,
                                        Icons.add,
                                        color: Colors.green,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          //   ],
                          // ),
                          SizedBox(
                            height: 15,
                          ),
                          value.vcDetailsLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.blue,
                                )
                              : value.voucherDetailsList.isNotEmpty
                                  ? SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        border: TableBorder(
                                          horizontalInside: BorderSide(
                                              color: Colors.black45,
                                              width: 0.7),
                                          verticalInside: BorderSide(
                                              color: Colors.black45,
                                              width: 0.7),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          bottom: BorderSide(
                                              color: Colors.black45,
                                              width: 0.7),
                                          top: BorderSide(
                                              color: Colors.black45,
                                              width: 0.7),
                                          left: BorderSide(
                                              color: Colors.black45,
                                              width: 0.7),
                                          right: BorderSide(
                                              color: Colors.black45,
                                              width: 0.7),
                                        ),
                                        columnSpacing: 45,
                                        columns: value.createVCColumns(),
                                        rows: value.createVCRows(),
                                      ),
                                    )
                                  : Container(),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Consumer<Controller>(
        builder: (BuildContext context, Controller value, Widget? child) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            width: size.width,
            height: 65,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // value.selectedVoucher['voucher_type_code'].toString();
                        // value.voucherDetailsList.clear();
                        print(amtController.text.runtimeType);
                        print(value.totalOfVcDEt.runtimeType);
                        if (double.parse(amtController.text) ==
                            value.totalOfVcDEt) {
                          print("Amt EQL");
                          DateTime dateTime =
                              DateTime.parse(dateController.text);
                          String formatdDate =
                              DateFormat('dd/MM/yyyy').format(dateTime);
                          DateTime dateTime1 =
                              DateTime.parse(refdateController.text);
                          String formatdDateREF =
                              DateFormat('dd/MM/yyyy').format(dateTime1);
                          DateTime dateTime2 =
                              DateTime.parse(cleareddateController.text);
                          String formatdDateCLR =
                              DateFormat('dd/MM/yyyy').format(dateTime2);
                          print(formatdDate.toString());
                          print(value.selectedVoucher!['voucher_type_code']
                              .toString());
                          print(value.selectedVoucher!['voucher_typ_acc_group']
                              .toString());
                          print(value.selectedVoucher!['voucher_typ_book_type']
                              .toString());
                          print(refnoController.text);
                          print(formatdDateREF);
                          print(amtController.text);
                          print(value.selectedCLPENDING.toString());
                          print(formatdDateCLR);
                          print(value.selectedVoucher!['voucher_typ_acc_type']
                              .toString());
                          /////////////////////////////////////////////////////////////////////////////////
                          value.getVoucherSave(
                              context,
                              formatdDate,
                              value.selectedVoucher!['voucher_type_code']
                                  .toString(),
                              value.selectedVoucher!['voucher_typ_acc_group']
                                  .toString(),
                              value.selectedVoucher!['voucher_typ_book_type']
                                  .toString(),
                              refnoController.text,
                              formatdDateREF,
                              amtController.text,
                              narrationController.text,
                              value.selectedCLPENDING.toString(),
                              formatdDateCLR,
                              value.selectedVoucher!['voucher_typ_acc_type']
                                  .toString());
                        } else {
                          CustomSnackbar sn = CustomSnackbar();
                          sn.showSnackbar(context, "Check Voucher Amount", "");
                          print("Amt Noteql");
                        }
                      },
                      child: Text("SAVE")),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(onPressed: () {}, child: Text("RESET")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// old dropdown ac head
//  Column(
//                   children: [
//                     SizedBox(
//                       width: 170,
//                       height: 40,
//                       child: TextFormField(
//                         controller: _accheadController,
//                         decoration: InputDecoration(
//                           labelText: 'Search Account Name',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),contentPadding: EdgeInsets.symmetric(
//                             vertical: 5, horizontal: 10)
//                         ),
//                         onChanged: (value) {
//                           Provider.of<Controller>(context, listen: false)
//                               .filterACHeadList(value);
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     // Expanded(
//                     //   child: ListView.builder(
//                     //     itemCount: value.acHeadList.length,
//                     //     itemBuilder: (context, index) {
//                     //       return ListTile(
//                     //         title: Text(value.acHeadList[index]['acc_name']),
//                     //         onTap: () {
//                     //           _accheadController.text = value.acHeadList[index]['acc_name'];
//                     //           // Perform additional actions if needed, like updating state or closing the list
//                     //         },
//                     //       );
//                     //     },
//                     //   ),
//                     // ),
//                     if (value.filteredacHeadList.isNotEmpty)
//                       Container(
//                         height: 400,
//                         width: 170,
//                         child: ListView.builder(
//                           itemCount: value.filteredacHeadList.length,
//                           itemBuilder: (context, index) {
//                             return ListTile(
//                               title: Text(value.filteredacHeadList[index]
//                                   ['acc_name']),
//                               onTap: () {
//                                 _accheadController.text = value
//                                     .filteredacHeadList[index]['acc_name'];
//                                 setState(() {
//                                   value.filteredacHeadList = [];
//                                 });
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
