import 'package:flutter/material.dart';

class LawsTab extends StatelessWidget {
  const LawsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel, size: 64, color: Color(0xffBDBDBD)),
                  SizedBox(height: 16),
                  Text(
                    'Normativas próximamente',
                    style: TextStyle(fontSize: 16, color: Color(0xff9E9E9E)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xffE65100),
      ),
      child: const Text(
        'Normativas',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}