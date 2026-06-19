import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netravest/providers/emergency_provider.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EmergencyProvider>();
      return GestureDetector(
        onTap: () => provider.sendSOS(context),
        child: Container(
         height: 180,
         decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 0, 0),
          borderRadius: BorderRadius.circular(50),
         ), 
         child: Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 10)
            ),
            child: const Text(
             'SOS',
             style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 60,
              fontWeight: FontWeight.bold
             ),
            ),
          ),
         ),
        ),
      );
  }
}