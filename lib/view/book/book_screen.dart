import 'dart:async';
import "dart:developer" as developer;

import 'package:flutter/material.dart';


//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';

import '/service/firebase_service.dart' as noti;

import '/view_model/account_viewmodel.dart';
import '/view_model/map_api_viewmodel.dart';

import '/view/book/before_search.dart';
import '/view/book/after_search.dart';
import '/view/book/before_taxi.dart';
import '/view/book/during_taxi.dart';
import '/view/book/after_taxi.dart';
import '/view/book/schedule_taxi.dart';
import '/view/decoration.dart';

import '/general/function.dart';



enum BookState {
  beforeSearch,         // Chưa đặt địa chỉ cần đến: Yêu cầu sệt
  afterSearch,          // Hiện thông tin đường đi giữa điểm bắt đầu và điểm kết thúc, giá tiền, quãng đường và thời gian
  beforeTaxiArrival,    // Chờ tài xế phản hồi
  duringTaxiArrival,    // Chờ tài xế trước và sau khi chở mình đi đến nơi cần đến
  afterTaxiArrival,     // Kết thúc
  scheduleTaxiArrival,  // Dành cho khách hàng VIP: đặt cuộc hẹn
  error
}



class BookScreen extends StatefulWidget {
  const BookScreen({
    Key? key,
    required this.vehicleID,
    this.dropoffAddress = "",
    this.dropoffLatitude = 0.0,
    this.dropoffLongitude = 0.0,
    required this.accountViewmodel,
    required this.duringTrip,
    required this.saveDuringTrip
  }) : super(key: key);

  final int vehicleID;
  final String dropoffAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final AccountViewmodel accountViewmodel;
  final bool duringTrip;
  final Function(bool) saveDuringTrip;

  @override
  State<BookScreen> createState() => _BookScreenState();
}



class _BookScreenState extends State<BookScreen> {

  // Thông tin người dùng (vị trí hiện tại, vị trí cần đến, khoảng cách, thời gian)
  int vehicleID = 0;
  BookState bookState = BookState.beforeSearch;

  // Thông tin liên quan để hiển thị trên bản đồ
  bool allowedNavigation = true;
  Location location = Location();
  MapController mapController = MapController();



  bool duringLoading = false;

  bool goodHour = true;
  bool goodWeather = true;

  // Thông tin tài xế
  bool driverPickingUp = false;
  bool loadTripOnce = false;

  late var listenLocation;



  // --------------------  Các hàm chính -------------------- 



  @override
  void initState() {
    super.initState();
    location.enableBackgroundMode(enable: true);
  }



  @override
  void dispose() {
    super.dispose();
    listenLocation.cancel();
    patchCustomerTimer?.cancel();
    driverFoundTimer?.cancel();
  }
  


  @override
  Widget build(BuildContext context) {

    // Widget
    return Scaffold(
        
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Text("Đặt vị trí", style: TextStyle(fontSize: 28)),
        backgroundColor: Colors.amber.shade300,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {
          Navigator.pop(context);
        })
      ),


      
      body: ChangeNotifierProvider(

        create: (_) {
          MapAPIViewmodel mapAPIViewmodel = MapAPIViewmodel();

          // location.requestPermission().then((granted) {
          //   listenLocation = location.onLocationChanged.listen((LocationData currLocation) {
          //     setState(() { mapAPIViewmodel.mapAPI.pickupLatLng = LatLng(currLocation.latitude!, currLocation.longitude!);
          //                 allowedNavigation = true; });
          //   });
          // }).catchError((e) {
          //   developer.log("Error when listening the location. Error: $e");
          //   setState(() => allowedNavigation = false);
          // });

          // // Lắng nghe định vị GPS
          listenLocation = location.onLocationChanged.listen((LocationData currLocation) {
            mapAPIViewmodel.updatePickupLatLng(LatLng(currLocation.latitude!, currLocation.longitude!));
            setState(() => allowedNavigation = true);
          });

          return mapAPIViewmodel;
        },


        builder: (BuildContext context, Widget? child) => Stack(children: [
        
          Positioned(top: 0, bottom: 0, left: 0, right: 0, child: StreamBuilder<int>(
        
            stream: _readDriver(context.read<MapAPIViewmodel>()),
        
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) => FlutterMap(
        
              mapController: mapController,
              options: MapOptions(center: context.watch<MapAPIViewmodel>().mapAPI.pickupLatLng, zoom: 16.5),
        
              nonRotatedChildren: [
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors',
                                          onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')))
                  ],
                ),
              ],
        
              children: [
        
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app'),
        
                PolylineLayer(
                  polylines: [
                    context.watch<MapAPIViewmodel>().mapAPI.s2ePolylines,
                    if (bookState == BookState.duringTaxiArrival && !driverPickingUp) context.watch<MapAPIViewmodel>().mapAPI.d2sPolylines
                  ],
                ),
        
                MarkerLayer(
                  markers: [
                    if (allowedNavigation)
                      Marker( point: context.watch<MapAPIViewmodel>().mapAPI.pickupLatLng, width: 20, height: 20, builder: (context) => const CustomerPoint() ),
                    if (bookState != BookState.beforeSearch)
                      Marker( point: context.watch<MapAPIViewmodel>().mapAPI.dropoffLatLng, width: 20, height: 20, builder: (context) => const DestiPoint() ),
                    if ((bookState == BookState.duringTaxiArrival) && !driverPickingUp)
                      Marker( point: context.watch<MapAPIViewmodel>().mapAPI.driverLatLng, width: 20, height: 20,  builder: (context) => const DriverPoint() )
                  ],
                )
        
              ],
            )
          )),
        
          Positioned(top: 0, bottom: 0, left: 0, right: 0, child: (() {
            
            switch (bookState) {

              case BookState.beforeSearch:
                return BeforeSearchBox(
                  duringLoading: duringLoading,
                  accountViewmodel: widget.accountViewmodel,
                  vehicleID: vehicleID,
                  onSubmitted: (PickedData pickedData) async {
                    context.read<MapAPIViewmodel>().updateDropoffAddr(pickedData.address);
                    context.read<MapAPIViewmodel>().updateDropoffLatLng(LatLng(pickedData.latLong.latitude, pickedData.latLong.longitude));
                    context.read<MapAPIViewmodel>().updatePickupAddr(
                          await context.read<MapAPIViewmodel>().getAddr(context.read<MapAPIViewmodel>().mapAPI.pickupLatLng));
                    
                    if (context.mounted) await context.read<MapAPIViewmodel>().updateS2EPolyline(vehicleID: vehicleID);
                    await saveBookState(BookState.afterSearch);
                    setState(() => mapController.move(context.read<MapAPIViewmodel>().mapAPI.pickupLatLng, 16));
                  }
                );

              case BookState.afterSearch:
                return AfterSearchBox(
                  accountViewmodel: widget.accountViewmodel,
                  vehicleID: vehicleID,
                  mapAPIViewmodel: context.watch<MapAPIViewmodel>(),

                  onPressCancel: () async => await saveBookState(BookState.beforeSearch),
                  
                  onPressOK: (bool selectingDate) async {
                    if (selectingDate) {
                      noti.showBoxWithTimes("Đã đến giờ khởi hành!", "Hãy chuẩn bị mọi thứ trước khi đi.", context.read<MapAPIViewmodel>().mapAPI.bookingTime);
                      await saveBookState(BookState.scheduleTaxiArrival);
                    }
                    else {
                      if (context.mounted) await context.read<MapAPIViewmodel>().postBookingRequest(widget.accountViewmodel.account.map["phone"], vehicleID);
                      await saveBookState(BookState.beforeTaxiArrival);
                    }
                    if (context.mounted) await context.read<MapAPIViewmodel>().saveCustomer();
                    await widget.saveDuringTrip(true);
                  },

                  onChangeVehicleLeft: () => setState( () {
                    setState(() => vehicleID--);
                    context.read<MapAPIViewmodel>().updatePrice(
                      getPrice(context.read<MapAPIViewmodel>().mapAPI.distance, vehicleID, goodHour: goodHour, goodWeather: goodWeather)
                    );
                  }),
                  onChangeVehicleRight: () => setState( () {
                    setState(() => vehicleID++);
                    context.read<MapAPIViewmodel>().updatePrice(
                      getPrice(context.read<MapAPIViewmodel>().mapAPI.distance, vehicleID, goodHour: goodHour, goodWeather: goodWeather)
                    );
                  }),

                  onChangeTimeForVip: (int hour, int minute) => context.read<MapAPIViewmodel>().updateDatetime(hour, minute)
                );

              case BookState.beforeTaxiArrival:
                return BeforeTaxiTrip(
                  accountViewmodel: widget.accountViewmodel,
                  vehicleID: vehicleID,
                  mapAPIViewmodel: context.watch<MapAPIViewmodel>(),
                  onCancel: () async {
                    if (await context.read<MapAPIViewmodel>().cancelBookingRequest()) {
                      await widget.saveDuringTrip(false);
                      await saveBookState(BookState.beforeSearch);
                      if (context.mounted) await context.read<MapAPIViewmodel>().clearAll();
                      driverFoundTimer?.cancel();
                      setState(() => loadDriverFoundTimerOnce = false);
                    }
                  }
                );

              case BookState.duringTaxiArrival:
                return DuringTaxiTrip(
                  accountViewmodel: widget.accountViewmodel,
                  vehicleID: vehicleID,
                  mapAPIViewmodel: context.watch<MapAPIViewmodel>()
                );

              case BookState.afterTaxiArrival:
                return AfterTaxiTrip(
                  accountViewmodel: widget.accountViewmodel,
                  onRated:   (int star) async {
                    await widget.saveDuringTrip(false);
                    if (context.mounted) await context.read<MapAPIViewmodel>().rateDriver(star);
                    if (context.mounted) await context.read<MapAPIViewmodel>().clearAll();
                    if (context.mounted) Navigator.pop(context);
                  },
                  onIgnored: () async {
                    await widget.saveDuringTrip(false);
                    if (context.mounted) await context.read<MapAPIViewmodel>().clearAll();
                    if (context.mounted) Navigator.pop(context);
                  }
                );

              case BookState.scheduleTaxiArrival:
                return ScheduleTaxiTrip(
                  accountViewmodel: widget.accountViewmodel,
                  onReturn: () async {
                    if (context.mounted) Navigator.pop(context);
                  }
                );

              default: return const Text("ERROR at BookState");
            }
          } ()))
        
        ]),
      )
    );
  }



  Timer? patchCustomerTimer;
  Timer? driverFoundTimer;
  
  bool loadPatchCustomerOnce = false;
  bool loadDriverFoundTimerOnce = false;


  Stream<int> _readDriver(mapAPIViewmodel) async* {
    
    if (!loadTripOnce) {
      loadTripOnce = true;

      if (widget.duringTrip) {
        developer.log("Pre-loading trip");
        vehicleID = widget.vehicleID;

        await loadBookState();
        switch (bookState) {

          case BookState.scheduleTaxiArrival:
            developer.log(" > Scheduled taxi arrival.");

            final newBookingTime = await mapAPIViewmodel.loadBookingTime();
            final timeDist = newBookingTime.compareTo(DateTime.now());

            if (timeDist < 0) {                // Đã đến hoặc đã qua thời điểm cần đặt
              await mapAPIViewmodel.loadCustomer();
              await saveBookState(BookState.beforeTaxiArrival);
              setState(() {
                allowedNavigation = true;
                mapController.move(mapAPIViewmodel.mapAPI.pickupLatLng, 16);
              });
            }
            break;


          case BookState.beforeTaxiArrival:
            developer.log(" > Before taxi arrival.");
            await mapAPIViewmodel.loadCustomer();
            setState(() {
              allowedNavigation = true;
              mapController.move(mapAPIViewmodel.mapAPI.pickupLatLng, 16);
            });
            break;

          
          case BookState.duringTaxiArrival:
            developer.log(" > During taxi arrival.");
            await mapAPIViewmodel.loadCustomer();
            await mapAPIViewmodel.loadDriver();
            setState(() {
              allowedNavigation = true;
              mapController.move(mapAPIViewmodel.mapAPI.pickupLatLng, 16);
            });
            break;
          

          default:
            developer.log(" > Invalid taxi arrival. State: ${bookState.name}.");
            await mapAPIViewmodel.clearAll();
            await widget.saveDuringTrip(false);
            await saveBookState(BookState.beforeSearch);
            break;
        }
      }
      else {
        developer.log("Pre-loading dropoff data if it exists");

        if (vehicleID == 0) {
          vehicleID = widget.vehicleID;
        }

        // Cập nhật vị trí cần đến
        if (widget.dropoffAddress.isNotEmpty) {
          try {
            setState(() => duringLoading = true);
            final currLocation = await location.getLocation();
            final newLocation = LatLng(currLocation.latitude!, currLocation.longitude!);
            if (mounted) {
              mapAPIViewmodel.updatePickupLatLng(newLocation);
              mapAPIViewmodel.updatePickupAddr(await mapAPIViewmodel.getAddr(newLocation));
              mapAPIViewmodel.updateDropoffLatLng(LatLng(widget.dropoffLatitude, widget.dropoffLongitude));
              mapAPIViewmodel.updateDropoffAddr(widget.dropoffAddress);
              await mapAPIViewmodel.updateS2EPolyline(vehicleID: vehicleID);
              await saveBookState(BookState.afterSearch);
              setState(() { mapController.move(mapAPIViewmodel.mapAPI.pickupLatLng, 16);
                            allowedNavigation = true; });
            }
          }
          catch (e) {
            developer.log("ERRRORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR. Error type: $e");
          }
          setState(() => duringLoading = false);
        }
      }
    }



    if (!loadPatchCustomerOnce) {
      loadPatchCustomerOnce = true;
      // Lắng nghe định vị GPS
      patchCustomerTimer = Timer.periodic(const Duration(seconds: 10), (timerRunning) async {
        final currLocation = await location.getLocation();
        print("COORD! ${currLocation.latitude}, ${currLocation.longitude}");
        mapAPIViewmodel.updatePickupLatLng(LatLng(currLocation.latitude!, currLocation.longitude!));
        await mapAPIViewmodel.patchPickupLatLng();
      });
    }


    // Chờ tài xế chấp nhận cước đi
    if (!loadDriverFoundTimerOnce) {
      if ((bookState == BookState.beforeTaxiArrival) || (bookState == BookState.duringTaxiArrival)) {
        loadDriverFoundTimerOnce = true;
        driverFoundTimer = Timer.periodic(const Duration(seconds: 10), (timerRunning) async {

          if (mounted) {
            if (await mapAPIViewmodel.getDriverLocation()) {

              await mapAPIViewmodel.saveDriver();

              if (bookState == BookState.beforeTaxiArrival) {
                await saveBookState(BookState.duringTaxiArrival);
                await mapAPIViewmodel.updateD2SPolyline();
              }
              else if (bookState == BookState.duringTaxiArrival) {

                // Cập nhật nếu gặp được tài xế
                if (getDescrateDistanceSquare(mapAPIViewmodel.mapAPI.pickupLatLng, mapAPIViewmodel.mapAPI.driverLatLng) < 10e-7 && !driverPickingUp) {
                  setState(() => driverPickingUp = true);
                  noti.showNormalBox("Taxi đã đến", "Hãy bắt đầu hành trình đi đến nơi cần đến nào!");
                }

                // Cập nhật nếu đến đích
                if (getDescrateDistanceSquare(mapAPIViewmodel.mapAPI.pickupLatLng, mapAPIViewmodel.mapAPI.dropoffLatLng) < 10e-7) {
                  await saveBookState(BookState.afterTaxiArrival);
                }
              }
            }
          }
        });
      }
    }

    yield 0;
  }




  Future<void> saveBookState(BookState value) async {
    developer.log("[Save bookstate] Save $value. Save vehicle type: $vehicleID");
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt("bookState", value.index);
    await sp.setInt("vehicleID", vehicleID);
    setState(() => bookState = value);
  }

  Future<void> loadBookState() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    int temp1 = sp.getInt("bookState") ?? 0;
    int temp2 = sp.getInt("vehicleID") ?? vehicleID;
    setState(() { bookState = BookState.values[temp1]; 
                  vehicleID = temp2; });
    developer.log("[Load bookstate] Load $bookState. Load vehicle type: $vehicleID");
  }
}



            // await mapAPIViewmodel.setTemp(<String, dynamic>{
            //   "pickup_address": "Hẻm 541 Đường Ðiện Biên Phủ, Phường 3, Quận 3, Thành phố Hồ Chí Minh, 72406, Việt Nam",
            //   "dropoff_address": "Cho Ben Thanh, Ho Chi Minh City, HC, Vietnam",
            //   "pickup_latitude": 10.77045,
            //   "pickup_longitude": 106.67747,
            //   "dropoff_latitude":  10.77242,
            //   "dropoff_longitude": 106.69811,
            //   "price": 30135,
            //   "distance": 3044,
            //   "duration": 676,
            //   "booking_time": DateTime.parse("2023-09-08T10:35:50.699+00:00")
            // });


