import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/general/function.dart';
import '/view_model/history_viewmodel.dart';
import '/view_model/account_viewmodel.dart';
import '/view/decoration.dart';



class HistoryScreen extends StatefulWidget {
  const HistoryScreen({ Key? key, required this.accountViewmodel }) : super(key: key);
  final AccountViewmodel accountViewmodel;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen> {

  bool loadOnce = false;


  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<HistoryViewmodel>(

      create: (_) => HistoryViewmodel(),
      builder: (BuildContext context, Widget? child) => StreamBuilder<int> (
          
        stream: preloadHistory(context.read<HistoryViewmodel>()),
      
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) => SingleChildScrollView(
          child: Container(
        
            padding: const EdgeInsets.all(15),
        
            child: Column(
              children: [

                Center(child: BigButton(label: "Chạy lại", onPressed: () async => context.read<HistoryViewmodel>().load(), bold: true)),

                const SizedBox(height: 15),

                ...(() {
                  int listLength = context.read<HistoryViewmodel>().historyList.length;
                  List<Widget> result = [];
                
                  for (int i = listLength - 1; i >= 0; i--) {
                    result.add(TripBox(
                      data: context.watch<HistoryViewmodel>().historyList[i],
                      accountViewmodel: widget.accountViewmodel
                    ));
                    result.add(const SizedBox(height: 15));
                  }
                
                  return result;
                } ()),
            ]),
          ),
        ),
      )
    );
  }

  Stream<int> preloadHistory(historyViewmodel) async* {
    if (!loadOnce) {
      loadOnce = true;
      await historyViewmodel.load();
    }
  }
}



class TripBox extends StatelessWidget {
  const TripBox({
    Key? key,
    required this.data,
    required this.accountViewmodel
  }) : super(key: key);

  final Map<String, dynamic> data;
  final AccountViewmodel accountViewmodel;

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: Container(

        height: 200,
        color: Colors.amber.shade200,
        child: Stack(clipBehavior: Clip.antiAliasWithSaveLayer, children: [

          Positioned(bottom: -20, left: -30, child: circle(Colors.amber.shade100, 45)),
          Positioned(top: -20, bottom: -20, right: -35, child: circle(Colors.yellow.shade100, 70)),
          Positioned(top: -15, bottom: -15, right: -30, child: circle(Colors.white, 60)),
          Positioned(top: 5, bottom: 5, left: 15, right: 105, child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trimText(data["source_address"] ?? "[Không có dữ liệu]"),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
              const HorizontalLine(),
              Text(
                trimText(data["destination_address"] ?? "[Không có dữ liệu]"),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
              const HorizontalLine(),
              Text(
                readDateTime(data["destination_address"]),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              )
            ]),
          ),
          Positioned(top: 0, bottom: 0, right: 25, child: Icon(
            Icons.directions_car, size: 42, color: Colors.amber.shade900
          ))
  
        ]),
    
      ),
    );
  }
}



String trimText(String value) {
  return (value.length > 70) ? "${value.substring(0, 50)}..." : value;
}

