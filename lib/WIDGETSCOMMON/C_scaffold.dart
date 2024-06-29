import 'package:flutter/material.dart';
import 'package:inventory24/WIDGETSCOMMON/tableList.dart';
import 'package:inventory24/db_helper.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child, this.resizeInset});
  final Widget? child;
  final bool? resizeInset;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeInset,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                List<Map<String, dynamic>> list =
                    await INVENT.instance.getListOfTables();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TableList(list: list)),
                );
              },
              icon: Icon(Icons.table_bar))
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Container(color: Colors.white),
          Image.asset(
            'assets/grnbk1.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: child!,
          ),
        ],
      ),
    );
  }
}
