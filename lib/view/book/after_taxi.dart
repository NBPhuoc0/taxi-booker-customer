import 'package:flutter/material.dart';

import '/view/decoration.dart';
import '../../view_model/account_viewmodel.dart';

typedef StringCallback = Function(String value);

class AfterTaxiTrip extends StatefulWidget {
  const AfterTaxiTrip(
      {Key? key,
      required this.accountViewmodel,
      required this.onRated,
      required this.onIgnored})
      : super(key: key);
  final AccountViewmodel accountViewmodel;
  final Function(int) onRated;
  final VoidCallback onIgnored;

  @override
  State<AfterTaxiTrip> createState() => _AfterTaxiTripState();
}

class _AfterTaxiTripState extends State<AfterTaxiTrip> {
  int star = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5)))),
      Positioned(
          top: 210,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 0; i < 5; i++)
                StarRate(
                    shining: star > i,
                    onTap: () => setState(() => star = i + 1))
            ]),
          )),
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 240,
            color: Colors.amber.shade300,
            child: Center(
                child: Container(
              padding: const EdgeInsets.only(left: 60, right: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "Cảm ơn bạn đã sử dụng ứng dụng và đến nơi. Chúc bạn đến nơi vui vẻ.",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        BigButton(
                            bold: true,
                            width: 90,
                            label: "Đánh giá",
                            onPressed: () => star > 0
                                ? widget.onRated(star)
                                : null), // Ra khỏi giao diện chính
                        BigButton(
                            bold: true,
                            width: 90,
                            label: "Bỏ qua",
                            onPressed: () => widget.onIgnored())
                      ])
                ],
              ),
            )),
          ))
    ]);
  }
}

class StarRate extends StatelessWidget {
  const StarRate({super.key, required this.shining, required this.onTap});
  final bool shining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Icon(shining ? Icons.star : Icons.star_border,
            color: Colors.deepOrange.shade900, size: 48));
  }
}
