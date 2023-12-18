import 'package:flutter/material.dart';

import '/view_model/map_api_controller.dart';
import '/view/decoration.dart';
import '/general/function.dart';



class CustomerInfos extends StatefulWidget {

  const CustomerInfos({
    Key? key,
    required this.mapAPIController,
    required this.currCustomer,
    required this.onAccepted,
    required this.onTapLeft,
    required this.onTapRight
  }) : super(key: key);

  final MapAPIController mapAPIController;
  final int currCustomer;
  final VoidCallback onAccepted;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;

  @override
  State<CustomerInfos> createState() => _CustomerInfosState();
}



class _CustomerInfosState extends State<CustomerInfos> {

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 60,
      height: 250,
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

        Container(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("${widget.currCustomer}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(formatPhonenumber(writeMapValue("phone", true), false), style: const TextStyle(fontSize: 20))
          ]),
        ),


        const SizedBox(height: 10),

        PositionBox(
          icon: Icon(Icons.add_circle, color: Colors.deepOrange.shade900),
          position: writeMapValue("source_address", true)
        ),

        PositionBox(
          icon: Icon(Icons.place, color: Colors.deepOrange.shade900),
          position: writeMapValue("destination_address", true)
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(child: PriceButton(text:"${writeMapValue("orderTotal", false)} VNĐ")),
          Expanded(child: PriceButton(text: distanceToString(writeMapValue("distance", false) ?? 0))),
          Expanded(child: PriceButton(text: durationToString(writeMapValue("duration", false) ?? 0)))
        ]),

        const SizedBox(height: 10),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          BigButton(width: 50, color: Colors.orange.shade500, bold: true, label: "<", onPressed: widget.onTapLeft),
          BigButton(width: 150, color: Colors.deepOrange.shade800, bold: true, label: "Chấp nhận", onPressed: widget.onAccepted),
          BigButton(width: 50, color: Colors.orange.shade500, bold: true, label: ">", onPressed: widget.onTapRight),
        ])
      ])
        
    );
  }



  writeMapValue(String key, bool returnString) {
    if (widget.mapAPIController.customerList.isEmpty) {
      return returnString ? "" : 0;
    }
    else {
      return widget.mapAPIController.customerList[widget.currCustomer][key];
    }
  }
}


