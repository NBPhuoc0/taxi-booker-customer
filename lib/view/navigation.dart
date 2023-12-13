import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


//import '/service/firebase_service.dart';

import '/service/firebase_service.dart' as noti;
import '/view_model/account_viewmodel.dart';

import '/view/navigation/home_screen.dart' show HomeScreen;
import '/view/navigation/history_screen.dart' show HistoryScreen;
import '/view/navigation/profile_screen.dart' show ProfileScreen;

import '/view/account/register_screen.dart' show RegisterScreen;
import '/view/account/login_screen.dart' show LoginScreen;
import '/view/decoration.dart';





enum ScreenState {
  registerScreen,
  loginScreen,
  applicationScreens
} ScreenState screenState = ScreenState.registerScreen;




class NavigationChange extends StatefulWidget {
  const NavigationChange({ Key? key }) : super(key: key);

  @override
  State<NavigationChange> createState() => _NavigationChangeState();
}


class _NavigationChangeState extends State<NavigationChange> {

  int bottomId = 0;             // Navigation
  List<Widget> _children = [];  // Navigation

  bool logoutAble = true;


  @override
  void initState() {
    super.initState();
    noti.initialize();
  }



  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      
      create: (_) {
        AccountViewmodel accountViewmodel = AccountViewmodel();

        _children = [
          HomeScreen(accountViewmodel: accountViewmodel, setLogoutAble: (bool value) => setState(() => logoutAble = value)),
          HistoryScreen(accountViewmodel: accountViewmodel),
          ProfileScreen(accountViewmodel: accountViewmodel, onLogOut: () async {
            if (logoutAble) {
              setState(() { bottomId = 0;
                            screenState = ScreenState.registerScreen; });
              await accountViewmodel.updateLogOut();
            }
            else {
              warningModal(context, "Chuyến đi chưa kết thúc. Hãy tiếp tục chuyến đi của bạn để có thể đăng xuất.");
            }
          })
        ];

        FirebaseMessaging.onMessage.listen(noti.showFCMBox);
        FirebaseMessaging.onMessageOpenedApp.listen(noti.showFCMBox);
        FirebaseMessaging.onBackgroundMessage(noti.showFCMBox);


        return accountViewmodel;
      },


      builder: (context, child) => StreamBuilder<int> (
        
        stream: preload(Provider.of<AccountViewmodel>(context)),
    
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
    
          if (Provider.of<AccountViewmodel>(context).account.map["_id"] != "") {
            screenState = ScreenState.applicationScreens;
          }
          else {
            if (screenState == ScreenState.applicationScreens) {
              screenState = ScreenState.registerScreen;
            }
          }

          
    
          switch (screenState) {
    
            case ScreenState.registerScreen:
              return RegisterScreen(
                accountViewmodel: Provider.of<AccountViewmodel>(context),
                onLogIn: () => setState(() => screenState = ScreenState.applicationScreens),
                switchToLogin: () => setState(() => screenState = ScreenState.loginScreen)
              );
    
              
            case ScreenState.loginScreen:
              
              return LoginScreen(
                accountViewmodel: Provider.of<AccountViewmodel>(context),
                onLogIn: () => setState(() => screenState = ScreenState.applicationScreens),
                switchToRegister: () => setState(() => screenState = ScreenState.registerScreen)
              );
            
            
            case ScreenState.applicationScreens:
              return Scaffold(
    
                backgroundColor: Colors.yellow.shade100,
                body: SafeArea(child: IndexedStack(index: bottomId, children: _children)),
    
                bottomNavigationBar: BottomNavigationBar(
    
                  type: BottomNavigationBarType.fixed,
    
                  selectedItemColor: Colors.deepOrange.shade800,
                  unselectedItemColor: Colors.orange.shade600,
                  
                  selectedLabelStyle:   const TextStyle( fontWeight: FontWeight.bold ),
                  unselectedLabelStyle: const TextStyle( ),
                  selectedIconTheme:    const IconThemeData( size: 32 ),
                  unselectedIconTheme:  const IconThemeData( size: 24 ),
    
                  currentIndex: bottomId,
                  onTap: (value) => setState(() => bottomId = value),
                  
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.map),     label: "Bản đồ"),
                    BottomNavigationBarItem(icon: Icon(Icons.wallet),  label: "Lịch sử"),
                    BottomNavigationBarItem(icon: Icon(Icons.person),  label: "Tài khoản"),
                  ],
                ),
              );
    
    
            default:
              return Text("Lỗi ScreenState: $screenState");
          }
        }
      ),
    );
  }



  bool preloadOnce = false;
  Stream<int> preload(accountViewmodel) async* {
    if (!preloadOnce) {
      await accountViewmodel.preload();
      preloadOnce = true;
    }
  }
}


