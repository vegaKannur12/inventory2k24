import 'package:flutter/material.dart';
import 'package:inventory24/CONTROLLER/controller.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  await Provider.of<Controller>(context, listen: false)
                      .getBillno(
                    context,
                  );
                },
                child: Text("GET BILL NO")),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  await Provider.of<Controller>(context, listen: false)
                      .getSave(
                    context,
                  );
                },
                child: Text("ACC SAVE"))
          ],
        ),
      ),
    );
  }
}
