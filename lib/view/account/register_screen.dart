import 'package:flutter/material.dart';

import '../../view_model/account_viewmodel.dart';
import '/view/decoration.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({ Key? key, required this.onLogIn, required this.switchToLogin, required this.accountViewmodel }) : super(key: key);
  final VoidCallback onLogIn;
  final VoidCallback switchToLogin;
  final AccountViewmodel accountViewmodel;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}



class _RegisterScreenState extends State<RegisterScreen> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.amber.shade700,

      body: SafeArea( child: Stack( children: [

        // --------------------- Trang trí ---------------------
        Positioned(top: -60, right: -60, child: circle(Colors.amber.shade600, 90)),
        Positioned(top: 30, left: 90, right: 45, child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text( "Chào bạn!", textAlign: TextAlign.end,
              style: TextStyle(fontSize: 28, color: Colors.brown.shade900, fontWeight: FontWeight.bold)),

            Text( "Hãy đăng ký để bắt đầu.", textAlign: TextAlign.end,
              style: TextStyle(fontSize: 24, color: Colors.brown.shade900, fontWeight: FontWeight.bold)),
          ]
        )),

        Positioned(top: 120, left: -235, right: 30, child: Container(
          width: 710, height: 760,
          decoration: BoxDecoration(
            color: Colors.yellow.shade600,
            borderRadius: const BorderRadius.all(Radius.circular(300))
          ),
        )),

        Positioned(top: 150, left: -240, right: 40, child: Container(
          width: 700, height: 700,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(300))
          ),
        )),

        // --------------------- Trường nhập ---------------------
        Positioned(top: 180, left: 15, right: 60, child: Column( children: [
          RegularTextField(controller: usernameController,       labelText: "Tên người dùng",    obscureText: false),
          RegularTextField(controller: phonenumberController,    labelText: "Số điện thoại",     obscureText: false),
          RegularTextField(controller: passwordController,       labelText: "Mật khẩu",          obscureText: true),
          RegularTextField(controller: repeatPasswordController, labelText: "Nhập lại mật khẩu", obscureText: true),
        ])),

        // --------------------- Nút đăng ký ---------------------
        Positioned(top: 540, left: 90, right: 120, child: BigButton(
          bold: true,
          label: "Đăng ký ngay!",
          onPressed: () async => register()
        )),

        Positioned(top: 640, left: 15, right: 60, child: MaterialButton(
          onPressed: () => widget.switchToLogin(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Đã có tài khoản rồi? Hãy ", style: TextStyle(fontSize: 16)),
              Text("Đăng nhập", style: TextStyle(color: Colors.orange.shade900, decoration: TextDecoration.underline, fontSize: 16)) 
            ],
          ),
        ))

      ]))
    );     
  }


  Future<void> register() async {
    try {
      final status = await widget.accountViewmodel.updateRegister(usernameController.text, phonenumberController.text, passwordController.text);
      if (status) {
        widget.onLogIn();
      }
      else {
        if (context.mounted) {
          warningModal(context, "Tài khoản không hợp lệ. Hãy kiểm tra giá trị bị thiếu hoặc có khả năng trùng số điện thoại.");
        }
      }
    }
    catch (e) {
      warningModal(context, "Hệ thống đăng nhặp bị lỗi.");
    }
  }
}

