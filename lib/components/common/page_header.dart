import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: MediaQuery.of(context).size.width * 1.25,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}