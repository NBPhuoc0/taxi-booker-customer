import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '/view_model/account_viewmodel.dart';
import '/view_model/map_api_viewmodel.dart';
import '/view/decoration.dart';
import '/general/function.dart';






class DuringTaxiTrip extends StatefulWidget {
  const DuringTaxiTrip({
    Key? key,
    required this.accountViewmodel,
    required this.vehicleID,
    required this.mapAPIViewmodel
  }) : super(key: key);

  final AccountViewmodel accountViewmodel;
  final int vehicleID;
  final MapAPIViewmodel mapAPIViewmodel;


  @override
  State<DuringTaxiTrip> createState() => _DuringTaxiTripState();
}



class _DuringTaxiTripState extends State<DuringTaxiTrip> {

  TextEditingController dropoffController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      
      // -------------------- Thanh vị trí -------------------- 
      Positioned(top: 15, left: 15, right: 15, child: PositionBox(
        icon: Icon(Icons.add_circle, color: Colors.deepOrange.shade900),
        position: widget.mapAPIViewmodel.mapAPI.pickupAddr
      )),
      Positioned(top: 75, left: 15, right: 15, child: PositionBox(
        icon: Icon(Icons.place, color: Colors.deepOrange.shade900),
        position: widget.mapAPIViewmodel.mapAPI.dropoffAddr
      )),
      Positioned(top: 56, left: 44, child: Container(
        width: 2,
        height: 32,
        color: Colors.deepOrange.shade900
      )),


      // --------------------  Thông tin để chờ xe -------------------- 
      Positioned(bottom: -30, left: 0, right: 0, child: Container(
        height: 290,
        decoration: BoxDecoration(
          color: Colors.amber.shade500,
          borderRadius: const BorderRadius.all(Radius.circular(15))
        ),
      )),

      Positioned(bottom: -30, left: 0, right: 0, child: DottedBorder(
        borderType: BorderType.RRect,
        color: Colors.white,
        radius: const Radius.circular(15),
        dashPattern: const [20, 20],
        strokeWidth: 3,
        child: Container(height: 275)
      )),

      Positioned(bottom: 225, left: 0, right: 0, child: CarWidget(type: widget.vehicleID)),

      Positioned(bottom: -30, left: 0, right: 0, child: Container(

        padding: const EdgeInsets.all(15),
        height: 270,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),

        child: Column(children: [

          Row(children: [
            Expanded(child: InfoBox(
              height: 75,
              icon: Icon(Icons.wallet, color: Colors.amber.shade500),
              detail: "${getPrice(widget.mapAPIViewmodel.mapAPI.distance, widget.vehicleID)} Đ"
            )),
        
            const SizedBox(width: 10),
        
            Expanded(child: InfoBox(
              height: 75,
              icon: Icon(Icons.timelapse, color: Colors.amber.shade500),
              detail: durationToString(widget.mapAPIViewmodel.mapAPI.duration)
            )),
        
            const SizedBox(width: 10),
        
            Expanded(child: InfoBox(
              height: 75,
              icon: Icon(Icons.location_on, color: Colors.amber.shade500),
              detail: distanceToString(widget.mapAPIViewmodel.mapAPI.distance)
            ))
          ]),

          const SizedBox(height: 5),

          const HorizontalLine(),

          const Text("Thông tin tài xế:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          Row(children: [
            Expanded(child: InfoBox(
              height: 75,
              icon: Icon(Icons.person, color: Colors.amber.shade500),
              detail: widget.mapAPIViewmodel.mapAPI.driverName
            )),
            
            const SizedBox(width: 10),

            Expanded(child: InfoBox(
              height: 75,
              icon: Icon(Icons.phone, color: Colors.amber.shade500),
              detail: widget.mapAPIViewmodel.mapAPI.driverPhonenumber
            ))
          ])

        ])

      ))
      
    ]);
  }
}




class InfoText extends StatelessWidget {
  const InfoText({ Key? key, this.title = "", required this.detail }) : super(key: key);
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 5),
      Text(detail, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
    ]);
  }
}




class BigLeftRightButton extends StatefulWidget {
  const BigLeftRightButton({
    Key? key,
    required this.toLeft,
    required this.id,
    required this.idChange
  }) : super(key: key);
  final bool toLeft;
  final int id;
  final VoidCallback idChange;

  @override
  State<BigLeftRightButton> createState() => _BigLeftRightButtonState();
}

class _BigLeftRightButtonState extends State<BigLeftRightButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.toLeft) {
      return InkWell(
        onTap: () => widget.id == 1 ? null : setState(widget.idChange),
        child: Container(
          width: 60,
          height: 135,
          decoration: BoxDecoration(
            color: widget.id == 1 ? Colors.white : Colors.yellow.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(9)),
            border: Border.all(
              color: Colors.amber.shade300,
              width: 3
            )
          ),
          child: Center(child: Icon(
            Icons.chevron_left,
            size: 32,
            color: widget.id == 1 ? Colors.transparent : Colors.black
          )),
        ),
      );
    }
    else {
      return InkWell(
        onTap: () => widget.id == 3 ? null : setState(widget.idChange),
        child: Container(
          width: 60,
          height: 135,
          decoration: BoxDecoration(
            color: widget.id == 3 ? Colors.white : Colors.yellow.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(9)),
            border: Border.all(
              color: Colors.amber.shade300,
              width: 3
            )
          ),
          child: Center(child: Icon(
            Icons.chevron_right,
            size: 32,
            color: widget.id == 3 ? Colors.transparent : Colors.black
          )),
        ),
      );
    }
  }
}



class InfoBox extends StatelessWidget {
  const InfoBox({ Key? key, required this.height, required this.icon, required this.detail }) : super(key: key);
  final double height;
  final Icon icon;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(width: 1, color: Colors.amber.shade300),
        color: Colors.yellow.shade50
      ),
      child: Column(children: [
        icon,
        const SizedBox(width: 5),
        Text(detail, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
      ])
    );
  }
}


