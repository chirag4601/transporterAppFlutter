import 'dart:convert';
import 'package:get/get.dart';
import 'package:liveasy/controller/transporterIdController.dart';
import 'package:liveasy/functions/loadOnGoingData.dart';
import 'package:liveasy/models/BookingModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';
import 'package:liveasy/models/onGoingCardModel.dart';

import 'loadOnGoingOrdersData.dart';

onGoingOrdersApiCall(int i) async {
  final String bookingApiUrl = FlutterConfig.get('bookingApiUrl');
  TransporterIdController transporterIdController =
      Get.find<TransporterIdController>();
  // List<BookingModel> modelList = [];
  List<OngoingCardModel?> modelList = [];
  print("transported id");
  print(transporterIdController.transporterId.value);
  // http.Response response = await http.get(Uri.parse(
  //     '$bookingApiUrl?postLoadId=${transporterIdController.transporterId.value}&completed=false&cancel=false&pageNo=$i'));
  http.Response response = await http.get(Uri.parse(
      '$bookingApiUrl?transporterId=${transporterIdController.transporterId.value}&completed=false&cancel=false&pageNo=$i'));

  var jsonData = json.decode(response.body);

  print(jsonData);
  for (var json in jsonData) {
    print("\n\n");
    print(json);
    BookingModel bookingModel = new BookingModel();
    bookingModel.bookingDate =
        json['bookingDate'] != null ? json['bookingDate'] : 'NA';
    bookingModel.loadId = json['loadId'] != null ? json['loadId'] : 'NA';
    // bookingModel.transporterId =
    //     json['transporterId'] != null ? json['transporterId'] : 'NA';
    // bookingModel.truckId = json['truckId'] != null ? json['truckId'] : 'NA';
    bookingModel.cancel = json['cancel'] != null ? json['cancel'] : false;
    bookingModel.completed =
        json['completed'] != null ? json['completed'] : false;
    bookingModel.completedDate =
        json['completedDate'] != null ? json['completedDate'] : 'NA';
    bookingModel.postLoadId =
        json['postLoadId'] != null ? json['postLoadId'] : 'NA';
    bookingModel.bookingId =
        json['bookingId'] != null ? json['bookingId'] : 'NA';
    bookingModel.rateString =
        json['rate'] != null ? json['rate'].toString() : 'NA';
    bookingModel.unitValue =
        json['unitValue'] != null ? json['unitValue'] : 'NA';

    bookingModel.driverName =
        json['driverName'] != null ? json['driverName'] : 'NA';
    bookingModel.driverPhoneNum =
        json['driverPhoneNum'] != null ? json['driverPhoneNum'] : 'NA';
    bookingModel.transporterId =
        json['transporterId'] != null ? json['transporterId'] : 'NA';
    bookingModel.driverPhoneNum =
        json['driverPhoneNum'] != null ? json['driverPhoneNum'] : 'NA';
    bookingModel.loadingPointCity =
        json['loadingPointCity'] != null ? json['loadingPointCity'] : 'NA';
    bookingModel.unloadingPointCity =
        json['unloadingPointCity'] != null ? json['unloadingPointCity'] : 'NA';
    bookingModel.truckNo = json['truckNo'] != null ? json['truckNo'] : 'NA';
    // bookingModel.deviceId = json['deviceId'] != null ? json['deviceId'] : 'NA';
    bookingModel.deviceId =
        json['deviceId'] != null ? int.parse(json["deviceId"]) : 0;
//     print(bookingModel);

// // var loadAllDataModel = BookingModel(bookingModel);
//     modelList.add(bookingModel);

    // modelList.add(bookingModel);
    var loadAllDataModel = await loadAllOnGoingOrdersData(bookingModel);
    modelList.add(loadAllDataModel);
  }
  print(modelList);
  print(modelList);
  print(modelList);
  print(modelList);

  return modelList;
}