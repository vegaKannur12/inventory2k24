import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    Key? key,
    required this.child,
    this.delay = const Duration(milliseconds: 500),
  }) : super(key: key);

  final Widget child;
  final Duration delay;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Center(
  child: FutureBuilder(
    future: Future.delayed(widget.delay),
    builder: (context, snapshot) {
      return snapshot.connectionState == ConnectionState.done
          ? const CircularProgressIndicator()
          : const SizedBox();
    },
  ),
);
  }
}
