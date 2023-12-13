import 'package:flutter/material.dart';

import '/general/function.dart';
import '/view/decoration.dart';
import '../../../view_model/map_api_controller.dart';



class CustomerInfosAccepted extends StatelessWidget {

  const CustomerInfosAccepted({
    Key? key,
    required this.mapAPIController,
    required this.onCancelled
  }) : super(key: key);

  final MapAPIController mapAPIController;
  final VoidCallback onCancelled;


  @override
  Widget build(BuildContext context) {
    return Container(

      width: 60,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        color: Colors.amber.shade300,
        boxShadow: [BoxShadow(
          color: Colors.orange.shade300.withOpacity(0.5),
          spreadRadius: 0,
          blurRadius: 3,
          offset: const Offset(3, 3), // changes position of shadow
        )]
      ),

      child: Column(children: [

        const SizedBox(height: 10),

        Text(mapAPIController.mapAPI.driverPhonenumber, style: const TextStyle(fontSize: 20)),

        const SizedBox(height: 10),

        PositionBox(
          icon: Icon(Icons.add_circle, color: Colors.deepOrange.shade900),
          position: mapAPIController.mapAPI.pickupAddr
        ),

        PositionBox(
          icon: Icon(Icons.place, color: Colors.deepOrange.shade900),
          position: mapAPIController.mapAPI.dropoffAddr
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(child: PriceButton(text:"${mapAPIController.mapAPI.price} VNĐ")),
          Expanded(child: PriceButton(text: distanceToString(mapAPIController.mapAPI.distance))),
          Expanded(child: PriceButton(text: durationToString(mapAPIController.mapAPI.duration)))
        ]),

        BigButton(label: "Xong", onPressed: onCancelled, bold: true)

      ])
        
    );
  }
}