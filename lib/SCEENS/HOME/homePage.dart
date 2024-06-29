import 'package:flutter/material.dart';
import 'package:inventory24/CONTROLLER/controller.dart';
import 'package:inventory24/MODEL/drawerModel.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/login.dart';
import 'package:inventory24/SCEENS/AUTHENTICATION/registration.dart';
import 'package:inventory24/SCEENS/HOME/salesEntry.dart';
import 'package:inventory24/SCEENS/HOME/voucherEntry.dart';
import 'package:inventory24/WIDGETSCOMMON/tableList.dart';
import 'package:inventory24/db_helper.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
  final drawerItem = [
    DrawerItem("VE", Icons.home, IconThemeData(color: Colors.black)),
    DrawerItem(
        "SE", Icons.card_giftcard, IconThemeData(color: Colors.redAccent)),
    // DrawerItem("3", Icons.directions_bike,
    //     IconThemeData(color: Colors.black)),
    // DrawerItem("3", Icons.account_balance_wallet,
    //     IconThemeData(color: Colors.black)),
    // DrawerItem("4", Icons.settings, IconThemeData(color: Colors.black)),
    // DrawerItem("5", Icons.live_help, IconThemeData(color: Colors.black)),
  ];
}

class _HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;
  _getDrawerItemWidget(String pos) {
    switch (pos) {
      case 'VE':
        {
           Provider.of<Controller>(context, listen: false)
              .loadVoucherType(context);
              Provider.of<Controller>(context, listen: false)
              .loadAccountHead(context);
          return VoucherEntry();
        }

      case 'SE':
        return SalesEntry();
      // case 2:
      //   return LoginPage();
      // case 3:
      //   return  LoginPage();
      // case 4:
      //   return Registration();
      // case 5:
      //   return LoginPage();

      default:
        return Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItem.length; i++) {
      var d = widget.drawerItem[i];
      drawerOptions.add(ListTile(
        leading: Icon(d.icons),
        title: Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(widget.drawerItem[_selectedDrawerIndex].title,
              style: TextStyle(color: Colors.blue)),
              actions: [ IconButton(
              onPressed: () async {
                List<Map<String, dynamic>> list =
                    await INVENT.instance.getListOfTables();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TableList(list: list)),
                );
              },
              icon: Icon(Icons.list))],
        ),
        drawer: Drawer(
          child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  Divider(
                    color: Colors.black,
                  ),
                  ...drawerOptions
                ],
              )
              //  Column(children:drawerOptions),
              ),
        ),
        body: _getDrawerItemWidget(widget.drawerItem[_selectedDrawerIndex].title),
       
    
    );
  }
}
