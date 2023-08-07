import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:liveasy/constants/color.dart';
import 'package:liveasy/providerClass/providerData.dart';
import 'package:get/get.dart';
import 'package:liveasy/screens/LoginScreens/loginScreen.dart';
import 'package:liveasy/screens/errorScreen.dart';
import 'package:liveasy/screens/noInternetScreen.dart';
import 'package:liveasy/screens/spashScreenToGetTransporterData.dart';
import 'package:liveasy/widgets/splashScreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity/connectivity.dart';
import 'firebase_options.dart';
import 'language/localization_service.dart';

var firebase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Different Firebase initialization for android app and web app
  // Wherever kIsWeb is used, it means we are having separate code for web app and android app

  firebase = kIsWeb
      ? await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  )
      : Firebase.initializeApp();

  if( kIsWeb ) {
    await dotenv.load(fileName: ".env"); // For loading env files for WEB
  }
  else {
    await FlutterConfig.loadEnvVariables(); // For loading env files for ANDROID & IOS
  }

  await GetStorage.init();
  await GetStorage.init('TransporterIDStorage');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _connectionStatus = "Unknown";
  late Connectivity connectivity;
  late StreamSubscription<ConnectivityResult> subscription;
  bool isDisconnected = false;
  GetStorage tidstorage = GetStorage('TransporterIDStorage');
  String? transporterId;

  @override
  void initState() {
    super.initState();
    setState(() {});
    transporterId = tidstorage.read("transporterId");
    //TODO: Internet connection check and onesignal initialization is only done for android application.
    if (!kIsWeb) {
      checkConnection();
      connectivityChecker();
    }
  }

  void checkConnection() {
    configOneSignel(context);
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          _connectionStatus = result.toString();
          print(_connectionStatus);
          if (result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi) {
            if (isDisconnected) {
              isDisconnected = false;
              connectivityChecker();
              Get.back();
            }
          } else {
            if (!isDisconnected) {
              isDisconnected = true;
              Get.defaultDialog(
                  barrierDismissible: false,
                  content: NoInternetConnection.noInternetDialogue(),
                  onWillPop: () async => false,
                  title: "\nNo Internet",
                  titleStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ));
            } else
              connectivityChecker();
          }
        });
  }

  Future<void> connectivityChecker() async {
    print("Checking internet...");
    try {
      await InternetAddress.lookup('google.com');
    } on SocketException catch (_) {
      isDisconnected = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.defaultDialog(
            barrierDismissible: false,
            content: NoInternetConnection.noInternetDialogue(),
            onWillPop: () async => false,
            title: "\nNo Internet",
            titleStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ));
      });
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> configOneSignel(BuildContext context) async {
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    String oneSignalAppId = FlutterConfig.get('oneSignalAppId').toString();
    OneSignal.shared.setAppId(oneSignalAppId);

    // Get the Onesignal external userId and update that into the firebase.
    // So, that it can be used to send Notifications to users later.̥
    // Returns an `OSDeviceState` object with the current immediate device state info
    final status = await OneSignal.shared.getDeviceState().then((deviceState) {
      print("OneSignal: device state: ${deviceState?.jsonRepresentation()}");
      bool areNotificationsEnabled = deviceState!.hasNotificationPermission;
      if (!areNotificationsEnabled) {
        // Ask permission from user for push notification (>= Android 13)
        OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
          print("Accepted permission: $accepted");
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OverlaySupport(
      child: ChangeNotifierProvider<ProviderData>(
        create: (context) => ProviderData(),
        builder: (context, child) {
          return kIsWeb
              ? GetMaterialApp(
            debugShowCheckedModeBanner: false,
            builder: EasyLoading.init(),
            theme: ThemeData(fontFamily: "Montserrat"),
            translations: LocalizationService(),
            locale: LocalizationService().getCurrentLocale(),
            fallbackLocale: const Locale('en', 'US'),
            //TODO: for home screen in web app we are looking whether used is checked for "Keep me logged in" while logging in.
            //TODO: so according if user enabled that we are navigating directly to HomeScreen of web, else user is asked for login
            // home: prefs.containsKey('uid')?const HomeScreenWeb(): LoginScreen(),
            home: LoginScreen(),
          )
              : FutureBuilder(
              future: firebase,
              builder: (context, snapshot) {
                final provider = Provider.of<ProviderData>(context);
                if (snapshot.connectionState == ConnectionState.done) {
                  if (FirebaseAuth.instance.currentUser == null) {
                    // If no user logged in then delete the previous external id of this device from one signal --
                    OneSignal.shared.removeExternalUserId();

                    return GetMaterialApp(
                      debugShowCheckedModeBanner: false,
                      builder: EasyLoading.init(),
                      theme: ThemeData(fontFamily: "montserrat"),
                      translations: LocalizationService(),
                      locale: LocalizationService().getCurrentLocale(),
                      fallbackLocale: Locale('en', 'US'),
                      // locale: provider.locale,
                      // supportedLocales: L10n.all,
                      // localizationsDelegates: [
                      //   AppLocalizations.delegate,
                      //   GlobalMaterialLocalizations.delegate,
                      //   GlobalCupertinoLocalizations.delegate,
                      //   GlobalWidgetsLocalizations.delegate,
                      // ],
                      home: SplashScreen(),
                    );
                  } else {
                    // print("in not null else block");

                    // debugPrint("User Signed In-------------------------");

                    if (transporterId != null) {
                      // print("not null user");

                      // debugPrint("User Signed In (Transport Id Available)-------------------------");

                      return GetMaterialApp(
                        debugShowCheckedModeBanner: false,
                        builder: EasyLoading.init(),
                        theme: ThemeData(
                            fontFamily: "montserrat",
                            appBarTheme: AppBarTheme(
                                color: statusBarColor,
                                iconTheme: IconThemeData(color: grey))),
                        translations: LocalizationService(),
                        locale: LocalizationService().getCurrentLocale(),
                        fallbackLocale: Locale('en', 'US'),
                        // locale: provider.locale,
                        // supportedLocales: L10n.all,
                        // localizationsDelegates: [
                        //   AppLocalizations.delegate,
                        //   GlobalMaterialLocalizations.delegate,
                        //   GlobalCupertinoLocalizations.delegate,
                        //   GlobalWidgetsLocalizations.delegate,
                        // ],
                        home:
                        // documentUploadScreen()
                        SplashScreenToGetTransporterData(
                          mobileNum: FirebaseAuth
                              .instance.currentUser!.phoneNumber
                              .toString()
                              .substring(3, 13),
                        ),
                      );
                    } else {
                      // print("null user");

                      // debugPrint("User Signed In (NULL Transport ID)-------------------------");

                      return GetMaterialApp(
                        debugShowCheckedModeBanner: false,
                        builder: EasyLoading.init(),
                        theme: ThemeData(fontFamily: "montserrat"),
                        translations: LocalizationService(),
                        locale: LocalizationService().getCurrentLocale(),
                        fallbackLocale: Locale('en', 'US'),
                        // locale: provider.locale,
                        // supportedLocales: L10n.all,
                        // localizationsDelegates: [
                        //   AppLocalizations.delegate,
                        //   GlobalMaterialLocalizations.delegate,
                        //   GlobalCupertinoLocalizations.delegate,
                        //   GlobalWidgetsLocalizations.delegate,
                        // ],
                        home: SplashScreen(),
                      );
                    }
                  }
                } else
                  return ErrorScreen();
              });
        },
      ),
    );
  }
}
