


import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

import '../../view_model/account_viewmodel.dart';



class BeforeSearchBox extends StatefulWidget {
  const BeforeSearchBox({
    Key? key,
    required this.accountViewmodel,
    required this.vehicleID,
    required this.onSubmitted,
    required this.duringLoading
  }) : super(key: key);

  final AccountViewmodel accountViewmodel;
  final int vehicleID;
  final Function(PickedData value) onSubmitted;
  final bool duringLoading;

  @override
  State<BeforeSearchBox> createState() => _BeforeSearchBoxState();
}



class _BeforeSearchBoxState extends State<BeforeSearchBox> {

  TextEditingController dropoffController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [

      // --------------------  Thanh sệt -------------------- 

      // Positioned(top: 15, left: 15, right: 15, child: AddressTextField(
      //   controller: dropoffController,
      //   // onChanged: (List<String> newHintAddrs) => setState(() => hintAddrs = newHintAddrs),       // ! Ngăn nhận liên tục nhận API từ Google Maps Platform
      //   onSubmitted: (String addr) async => widget.onSubmitted(addr),
      // )),

      FlutterLocationPicker(

        initZoom: 11,
        minZoomLevel: 5,
        maxZoomLevel: 16,
        trackMyPosition: true,
        onPicked: (pickedData) => widget.onSubmitted(pickedData),

        selectLocationButtonStyle: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
        ),
        selectedLocationButtonTextstyle: const TextStyle(fontSize: 18),
        selectLocationButtonText: 'Đặt vị trí tại đây',
        selectLocationButtonLeadingIcon: const Icon(Icons.check),
        selectLocationButtonHeight: 55,
        
        searchBarBackgroundColor: Colors.white,
        searchBarHintColor: Colors.blueGrey.shade600,
        searchbarBorderRadius: const BorderRadius.all(Radius.circular(9)),

        mapLoadingBackgroundColor: Colors.amber.shade600,
        locationButtonBackgroundColor: Colors.amber.shade600,
        zoomButtonsBackgroundColor: Colors.amber.shade600


      ),


      if (widget.duringLoading) Positioned(top: 0, bottom: 0, left: 0, right: 0, child: Container(
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5))
      ))


      // --------------------  Hộp hiển thị các gợi ý vị trí cần đến (dropoff) -------------------- 

      // Positioned(top: 80, left: 15, right: 15, child: AutoCompleteBox(
      //   locations: hintAddrs,
      //   onTapOneOfThem: (String addr) async => updateDestination(addr),
      // )),
    ]);
  }
}




// class AutoCompleteBox extends StatefulWidget {
//   const AutoCompleteBox({ Key? key, required this.locations, required this.onTapOneOfThem }) : super(key: key);
//   final StringCallback onTapOneOfThem;
//   final List<String> locations;

//   @override
//   State<AutoCompleteBox> createState() => _AutoCompleteBoxState();
// }

// class _AutoCompleteBoxState extends State<AutoCompleteBox> {

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 75.0 * min(widget.locations.length, 5),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.all(Radius.circular(9))
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         for (int i = 0; i < min(widget.locations.length, 5); i++)
//           Container(
//             padding: const EdgeInsets.only(left: 10, right: 10),
//             height: 75,
//             decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200, width: 2)),
//             child: InkWell(
//               onTap: () => widget.onTapOneOfThem(widget.locations[i]),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(widget.locations[i], style: const TextStyle(fontSize: 16), textAlign: TextAlign.left)
//               ),
//             )
//           ),
//       ]),
//     );
//   }
// }
