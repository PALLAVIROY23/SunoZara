import 'package:flutter/material.dart';
import 'package:flutter_cart/cart.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:sunozara/provider/download.dart';
import 'package:sunozara/splash.dart';
import 'package:sunozara/constants.dart';
import 'package:sunozara/provider/miniplayer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import the ScreenUtil package

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var cart = FlutterCart();
  await cart.initializeCart(isPersistenceSupportEnabled: true);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MiniPlayerProvider()),
        ChangeNotifierProvider(create: (context) => DownloadProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        splitScreenMode: true, // Set your design size (width, height)
        minTextAdapt: true, // This ensures the text scales properly
        builder: (context, child) {
          return MaterialApp(
            title: 'SunoZara',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              applyElevationOverlayColor: false,
              primarySwatch: Colors.red,
              canvasColor: THEME_BLACK,
              bottomAppBarTheme: BottomAppBarTheme(color: THEME_BLACK),
              scaffoldBackgroundColor: THEME_BLACK.withOpacity(0.7),
            ),
            home: child, // Pass the SplashScreen widget here
          );
        },
        child: const SplashScreen(), // SplashScreen is now wrapped by ScreenUtil
      ),
    );
  }
}
