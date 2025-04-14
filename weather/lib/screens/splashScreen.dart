import 'package:flutter/material.dart';
import 'package:weather/screens/mainScreen.dart';
 // Accuweather

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  loadNextpage() async{
    await Future.delayed(Duration(seconds: 2), (){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainScreen()));
       });

  }
  

@override
void initState() {
  super.initState();
  loadNextpage();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
        Image.asset("assets/images/logo.png",
       width: 200),
        Text("Weather App", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        Spacer(),
        Text("Developed By", style: TextStyle(fontSize: 18)),
        Text("Tajinder Singh", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        SizedBox(height: 20,)
      ],) ),
    );
  }
}  