import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liveasy/constants/color.dart';
import 'package:liveasy/constants/fontSize.dart';
import 'package:liveasy/constants/fontWeights.dart';
import 'package:liveasy/constants/radius.dart';
import 'package:liveasy/constants/spaces.dart';
import 'package:liveasy/controller/transporterIdController.dart';
import 'package:liveasy/functions/truckApiCalls.dart';
import 'package:liveasy/models/biddingModel.dart';
import 'package:liveasy/models/driverModel.dart';
import 'package:liveasy/models/loadDetailsScreenModel.dart';
import 'package:liveasy/models/truckModel.dart';
import 'package:liveasy/providerClass/providerData.dart';
import 'package:liveasy/screens/TruckScreens/AddNewTruck/truckNumberRegistration.dart';
import 'package:liveasy/widgets/buttons/confirmButtonSendRequest.dart';
import 'package:liveasy/widgets/buttons/CancelSelectedTruckDriverButton.dart';
import 'package:provider/provider.dart';
import 'addDriverAlertDialog.dart';

// ignore: must_be_immutable
class BookLoadAlertDialogBox extends StatefulWidget {
  List? truckModelList ;
  List? driverModelList;
  LoadDetailsScreenModel? loadDetailsScreenModel;
  BiddingModel? biddingModel;
  bool? directBooking;
  String? postLoadId;

  BookLoadAlertDialogBox(
      {

        this.truckModelList,
        this.postLoadId,
       this.driverModelList,
      this.loadDetailsScreenModel,
       this.biddingModel,
      required this.directBooking});

  @override
  _BookLoadAlertDialogBoxState createState() =>
      _BookLoadAlertDialogBoxState();
}

class _BookLoadAlertDialogBoxState extends State<BookLoadAlertDialogBox> {

  String? selectedTruck;
  String? selectedDriver;
  String? selectedDriverName;

  TransporterIdController transporterIdController = Get.find();

  TruckApiCalls truckApiCalls = TruckApiCalls();

  // List? truckDropDownList ;

  late TruckModel truckModel = TruckModel(truckApproved: false , truckId: 'Add new Truck' , truckNo: 'Add new Truck' );
  late DriverModel driverModel = DriverModel(driverId: 'Add new Driver' , driverName: 'Add new Driver' , phoneNum: '');
  @override
  Widget build(BuildContext context) {

    ProviderData providerData = Provider.of<ProviderData>(context);


      widget.truckModelList!.add(truckModel);


      widget.driverModelList!.add(driverModel);



    return AlertDialog(
      contentPadding: EdgeInsets.all(space_1),
      insetPadding: EdgeInsets.only(
        left: space_4,
        right: space_4,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: space_2),
            child: Text(
              "Select a Truck",
              style: TextStyle(fontSize: size_9, fontWeight: normalWeight),
            ),
          ),
          Container(
            height: space_7 + 2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius_4 + 2),
                border: Border.all(color: darkGreyColor)),
            child: Padding(
              padding: EdgeInsets.only(
                left: space_2 - 2,
                right: space_2 - 2,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedTruck,
                  icon: Icon(Icons.arrow_drop_down_circle_sharp),
                  iconEnabledColor: darkBlueColor,
                  style: TextStyle(
                      fontSize: size_7,
                      fontWeight: regularWeight,
                      color: Colors.black),
                  onChanged: (String? truckId) {
                    if(truckId == 'Add new Truck'){
                      providerData.updateIsAddTruckSrcDropDown(true);
                      Navigator.pop(context);
                      Get.to(() => AddNewTruck());
                    }
                    else{
                      setState(() {
                        selectedTruck = truckId;
                        for ( TruckModel truckModel in widget.truckModelList!){
                          if(truckModel.truckId == selectedTruck){
                            if(truckModel.driverId != null){
                              selectedDriver = truckModel.driverId;
                              for(DriverModel driverModel in widget.driverModelList!){
                                if(driverModel.driverId == selectedDriver){
                                  selectedDriverName =driverModel.driverName;
                                }
                              }
                            }
                            //executed if truck doesn't have a driver
                            else{
                              selectedDriver = null;
                              selectedDriverName = null;
                            }
                            break;
                          }//first if
                        }//outer for
                      }
                      );//set state
                    }
                  },
                  items: widget.truckModelList!.map<DropdownMenuItem<String>>(
                          (e) =>
                          DropdownMenuItem<String>(
                            value: e.truckId,
                            child: Text(e.truckNo),
                          )
                  ).toList(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: space_2 + 2,
          ),
          Text(
            "Select a Driver",
            style: TextStyle(fontSize: size_9, fontWeight: normalWeight),
          ),
          SizedBox(
            height: space_2,
          ),
          Container(
            height: space_7 + 2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius_4 + 2),
                border: Border.all(color: Color(0xFF878787))),
            child: Padding(
              padding: EdgeInsets.only(
                left: space_2 - 2,
                right: space_2 - 2,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDriver,
                  icon: Icon(Icons.arrow_drop_down_circle_sharp),
                  iconEnabledColor: darkBlueColor,
                  style: TextStyle(
                      fontSize: size_7,
                      fontWeight: regularWeight,
                      color: Colors.black),
                  onChanged: (String? driverId) {
                    if(driverId == 'Add new Driver'){
                      providerData.updateIsAddTruckSrcDropDown(true);
                      Navigator.pop(context);
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AddDriverAlertDialog());
                    }
                    else{
                      setState(() {
                        selectedDriver = driverId;
                        truckApiCalls.updateDriverIdForTruck(truckID: selectedTruck!, driverID: selectedDriver!);
                      });
                    }
                  },
                  items: widget.driverModelList!.map<DropdownMenuItem<String>>(
                          (e) =>
                          DropdownMenuItem<String>(
                            value: e.driverId,
                            child: Text('${e.driverName} - ${e.phoneNum}'),
                          )
                  ).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(top: space_11, bottom: space_4 + 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.loadDetailsScreenModel != null
                  ?
              ConfirmButtonSendRequest(
                loadDetailsScreenModel: widget.loadDetailsScreenModel,
                truckId: selectedTruck,
                directBooking: true,
              )
                  :
                  ConfirmButtonSendRequest(
                    directBooking: false,
                    postLoadId: widget.postLoadId,
                    truckId: selectedTruck,
                    biddingModel: widget.biddingModel,
                  ),
               CancelSelectedTruckDriverButton(
                 driverModelList: widget.driverModelList,
                 truckModelList: widget.truckModelList,
               )
            ],
          ),
        )
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius_2 - 2)),
      ),
    );
  }
}