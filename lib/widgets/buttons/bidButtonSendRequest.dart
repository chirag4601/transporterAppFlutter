import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liveasy/constants/color.dart';
import 'package:liveasy/constants/fontSize.dart';
import 'package:liveasy/constants/fontWeights.dart';
import 'package:liveasy/constants/radius.dart';
import 'package:liveasy/constants/spaces.dart';
import 'package:liveasy/controller/transporterIdController.dart';
import 'package:liveasy/functions/postBidApi.dart';
import 'package:liveasy/providerClass/providerData.dart';
import 'package:liveasy/widgets/alertDialog/bidButtonAlertDialog.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class BidButtonSendRequest extends StatelessWidget {
  String loadId, unit;

  BidButtonSendRequest(this.loadId, this.unit);

  TransporterIdController tIdController = Get.find<TransporterIdController>();

  @override
  Widget build(BuildContext context) {
    var providerData = Provider.of<ProviderData>(context, listen: false);
    return GestureDetector(
      onTap: () {
        print(Provider.of<ProviderData>(context, listen: false).rate);

        if (Provider.of<ProviderData>(context, listen: false).rate == "" ||
            Provider.of<ProviderData>(context, listen: false).rate == null) {
          Get.snackbar("Please Enter Rate", "",
              snackPosition: SnackPosition.BOTTOM,
              colorText: Colors.red,
              backgroundColor: white,
              margin: EdgeInsets.only(bottom: 5.0));
        } else {
          postBidAPi(
              loadId,
              Provider.of<ProviderData>(context, listen: false).rate,
              tIdController.transporterId.value,
              unit);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Bidding Request Send')));
          providerData.updateRate(newValue: "");
          Navigator.of(context).pop();
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: space_3),
        height: space_6 + 1,
        width: space_16,
        decoration: BoxDecoration(
            color: darkBlueColor,
            borderRadius: BorderRadius.circular(radius_4)),
        child: Center(
          child: Text(
            "Bid",
            style: TextStyle(
                color: Colors.white,
                fontWeight: normalWeight,
                fontSize: size_6 + 2),
          ),
        ),
      ),
    );
  }
}
