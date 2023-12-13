import 'package:flutter/material.dart';

import '../../view_model/account_viewmodel.dart';
import '/view/decoration.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({ Key? key, required this.accountViewmodel, required this.onLogOut }) : super(key: key);
  final AccountViewmodel accountViewmodel;
  final Future<void> Function() onLogOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.amber.shade700,

      // appBar: AppBar(
      //   toolbarHeight: 90,
      //   title: const Text("Tài khoản của bạn", style: TextStyle(fontSize: 28)),
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: Colors.white,
      //   elevation: 0
      // ),

      body: Stack(children: [

        // -------------------- Nền bên ngoài --------------------
        Positioned(left: -30, child: circle(Colors.amber.shade600, 30)),

        // 650

        Positioned(top: -20, left: -30, child: circle(Colors.amber.shade500, 60)),
        Positioned(bottom: -80, right: -80, child: circle(Colors.amber.shade500, 120)),
        Positioned(top: 150, bottom: 90, left: -40, right: -40, child: circle(Colors.yellow.shade500, 600)),
        Positioned(top: 180, bottom: 100, left: -30, right: -30, child: circle(Colors.white, 600)),
        Positioned(top: 90, left: 0, right: 0, child: SizedBox(
          width: 120,
          height: 120,
          child: Center(child: circle(Colors.yellow.shade500, 60)))
        ),
        Positioned(top: 95, left: 0, right: 0, child: SizedBox(
          width: 110,
          height: 110,
          child: Center(child: circle(Colors.white, 55)))
        ),
        Positioned(top: 95, left: 0, right: 0, child: SizedBox(
          width: 110,
          height: 110,
          child: Center(child: Icon(Icons.directions_car, color: Colors.amber.shade700, size: 72)))
        ),


        // -------------------- Appbar (không xài appbar của Scaffold vì nó không tàn hình) --------------------
        const Positioned(top: 25, left: 0, right: 0, child: Center(
          child: Text("Tài khoản của bạn", style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)))
        ),

        
        // -------------------- Các trường nhập --------------------
        Positioned(top: 120, left: 30, right: 30, child: Column(
      
          children: [
            const SizedBox(height: 90),
            RegularTextField(controller: usernameController,    labelText: "Tên người dùng", text: widget.accountViewmodel.account.map["fullname"]),
            RegularTextField(controller: phonenumberController, labelText: "Số điện thoại",  text: widget.accountViewmodel.account.map["phone"]),

            const SizedBox(height: 30),
            Container(height: 2, color: Colors.yellow.shade200),
            const SizedBox(height: 30),
            BigButton(width: 240, label: "Thay đổi thông tin", onPressed: () {}),
          ],
        )),

        Positioned(bottom: 30, left: 0, right: 0, child: Center( child: BigButton(
          bold: true,
          width: 240,
          label: "Đăng xuất",
          onPressed: () async => logOut()
        )))

      ]),
    );
  }


  Future<void> logOut() async {
    widget.accountViewmodel.updateLogOut();
    if (mounted) {
      await widget.onLogOut();
    }
    else {
      throw "[MOUNTED ERROR AT PROFILE SCREEN]";
    }
  }
}



class ProfileTitle extends StatelessWidget {
  const ProfileTitle({ Key? key, required this.text }) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 24));
  }
}



class ProfileLine extends StatelessWidget {
  const ProfileLine({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Colors.white
    );
  }
}


class ProfileBox extends StatelessWidget {
  const ProfileBox({ Key? key, required this.height, required this.width , required this.child }) : super(key: key);
  final double height;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        border: Border.all(
          color: Colors.lightBlue.shade200,
          width: 1
        )
      ),
      child: child,
    );
  }
}


