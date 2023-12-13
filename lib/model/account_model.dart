class AccountModel {  // Singleton

  Map<String, dynamic> map = {
    "_id": "",
    "phone": "",
    "fullname": "",
    "location":{
      "longitude": -1,
      "latitude": -1
    },
    "is_Vip": true
  };

  static final AccountModel _instance = AccountModel._internal();
  AccountModel._internal();

  factory AccountModel() {
    return _instance;
  }

  void clear() {
    map = {
      "_id": "",
      "phone": "",
      "fullname": "",
      "location":{
        "longitude": -1,
        "latitude": -1
      },
      "is_Vip": true
    };
  }
}