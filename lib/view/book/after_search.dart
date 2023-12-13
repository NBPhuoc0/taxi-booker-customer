import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '/view_model/account_viewmodel.dart';
import '/view_model/map_api_viewmodel.dart';
import '/view/decoration.dart';
import '/general/function.dart';





class AfterSearchBox extends StatefulWidget {
  const AfterSearchBox({

    Key? key,
    required this.accountViewmodel,
    required this.vehicleID,
    required this.mapAPIViewmodel,

    required this.onPressCancel,
    required this.onPressOK,

    required this.onChangeVehicleLeft,
    required this.onChangeVehicleRight,
    required this.onChangeTimeForVip

  }) : super(key: key);

  final AccountViewmodel accountViewmodel;
  final int vehicleID;
  final MapAPIViewmodel mapAPIViewmodel;

  final VoidCallback onPressCancel;
  final Function(bool) onPressOK;

  final VoidCallback onChangeVehicleLeft;
  final VoidCallback onChangeVehicleRight;
  final Function(int, int) onChangeTimeForVip;


  @override
  State<AfterSearchBox> createState() => _AfterSearchBoxState();
}



class _AfterSearchBoxState extends State<AfterSearchBox> {

  String currTimeStr = "Chọn giờ";
  DateTime? datetime;
  bool selectingDate = false;



  @override
  Widget build(BuildContext context) {

    return Stack(children: [

      // --------------------  Thanh vị trí -------------------- 
      Positioned(top: 15, left: 15, right: 15, child: PositionBox(
        icon: Icon(Icons.add_circle, color: Colors.deepOrange.shade900),
        position: widget.mapAPIViewmodel.mapAPI.pickupAddr
      )),
      Positioned(top: 75, left: 15, right: 15, child: PositionBox(
        icon: Icon(Icons.place, color: Colors.deepOrange.shade900),
        position: widget.mapAPIViewmodel.mapAPI.dropoffAddr
      )),
      Positioned(top: 80, right: 30, child: IconButton(
        icon: const Icon(Icons.close, size: 28),
        onPressed: () => widget.onPressCancel()
      )),
      Positioned(top: 56, left: 44, child: Container(
        width: 2,
        height: 32,
        color: Colors.deepOrange.shade900
      )),


      // --------------------  Thông tin để đặt xe -------------------- 
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
        decoration: const BoxDecoration( color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(15)) ),
        child: Column(children: [

          Row(children: [

            BigLeftRightButton(toLeft: true, id: widget.vehicleID, idChange: () => widget.onChangeVehicleLeft()),

            const SizedBox(width: 15),

            Expanded(child: Column(children: [
              InfoText( title: "Loại xe: ", detail: getVehicleName(widget.vehicleID) ),
              const HorizontalLine(),
              InfoText( title: "Giá thành: ", detail: "${widget.mapAPIViewmodel.mapAPI.price} VNĐ" ),
              const HorizontalLine(),
              InfoText( title: "Thời gian: ", detail: durationToString(widget.mapAPIViewmodel.mapAPI.duration) ),
              const HorizontalLine(),
              InfoText( title: "Quãng đường: ", detail: distanceToString(widget.mapAPIViewmodel.mapAPI.distance) ),
            ])),

            const SizedBox(width: 15),

            BigLeftRightButton(toLeft: false, id: widget.vehicleID, idChange: () => widget.onChangeVehicleRight()),

          ]),

          const SizedBox(height: 15),

          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              BigButton(
                label: "Đặt ngay!",
                width: 170,
                bold: true,
                color: Colors.amber.shade700,
                onPressed: () async => widget.onPressOK(selectingDate)
              ),

              BigButton(
                label: currTimeStr,
                width: 170,
                bold: true,
                color:  Colors.amber.shade700,
                onPressed: () async {
                  await pickTime();
                  // if (widget.accountViewmodel.account.map["is_Vip"]) {
                  //   await pickTime();
                  // }
                  // else {
                  //   warningModal(context, "Bạn hãy đặt thêm nhiều cuốc nữa để mở khoá tính năng này.");
                  // }
                }
              )

            ])

          )

        ])
      ))

    ]);
  }


  Future<void> pickTime() async {

    TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(data: ThemeData(), child: child!);
      }
    );
    if ((timeOfDay?.hour == null) || (timeOfDay?.minute == null)) {
      widget.onChangeTimeForVip(0, 0);
      setState(() {
        selectingDate = false;
        currTimeStr = "Chọn giờ";
      });
    }
    else {
      widget.onChangeTimeForVip(timeOfDay?.hour ?? 0, timeOfDay?.minute ?? 0);
      setState(() {
        selectingDate = true;
        currTimeStr = readHour(timeOfDay);
    });
    }
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
        onTap: () => widget.id == 2 ? null : setState(widget.idChange),
        child: Container(
          width: 60,
          height: 135,
          decoration: BoxDecoration(
            color: widget.id == 2 ? Colors.white : Colors.yellow.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(9)),
            border: Border.all(
              color: Colors.amber.shade300,
              width: 3
            )
          ),
          child: Center(child: Icon(
            Icons.chevron_right,
            size: 32,
            color: widget.id == 2 ? Colors.transparent : Colors.black
          )),
        ),
      );
    }
  }
}


