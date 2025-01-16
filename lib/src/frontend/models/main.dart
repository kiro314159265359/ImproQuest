import 'package:flutter/material.dart';

void main() {
  runApp(const StartScreen());
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(context) {
    //this StartScreen class return a widget

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.amber),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.amber,
          child: const Icon(Icons.play_arrow),
        ),
        //here i set the backgrund of my app
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color.fromARGB(151, 207, 122, 244),
              Color.fromARGB(255, 7, 4, 23),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Center(
            //in the cneter widget I added a Column widget
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //in the childern named argument of the Clumn widget you can add your list of widgets
                //-------------------------------------------------------------------------
                // I started with an image //
                //add your image here
                Image.asset(
                  'assets/images/quiz-logo.png',
                  width: 300, //here set the width of the image
                ),
                //use SizedBox widget to add space between the image and the text
                const SizedBox(height: 80),
                //-----------------------------------------------------------------------------
                const Text("Learn flutter the fun way",
                    style: TextStyle(color: Colors.red, fontSize: 15)),

                //use SizedBox widget to add space between the text and the text
                const SizedBox(height: 80),

                const Text("My name is Mina Asaad",
                    style: TextStyle(color: Colors.red, fontSize: 15)),

                //use SizedBox widget to add space between the text and the text
                const SizedBox(height: 30),
                //Now add the outlinedButton and its function and its style! and the text that is shown 'Start Quiz'
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                      "Start Quiz"), // add your text here 'Start Quiz'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
