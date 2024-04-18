import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

void main() {
  runApp(MyApp());
}

Color myTealColor = Color(0xFF3AAFA9); // Define custom teal color

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Set SplashScreen as the initial screen
      title: 'Penguins Gallery',
      theme: ThemeData(
        primaryColor: myTealColor, // Use custom teal color as primary color
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          color: myTealColor, // Use custom teal color for app bar
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal, // Use custom teal color as primary swatch
          accentColor: Colors.white,
          brightness: Brightness.light,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: myTealColor, // Use custom teal color for buttons
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 2 seconds before navigating to the main screen
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ImageList()), // Navigate to ImageList
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/penguinz2.png', // Path to your splash screen image asset
          width: 200, // Set width as needed
          height: 200, // Set height as needed
        ),
      ),
    );
  }
}

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  final String apiKey = "7xR4wPRK19kIZbcitGcfANAEGQrHEMVR8bQGAN8wY3Qc0QCUez75ZwMG";
  List<dynamic> _photos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPhotos("penguin");
  }

  Future<void> fetchPhotos(String query) async {
    setState(() {
      _isLoading = true;
    });
    final String url = "https://api.pexels.com/v1/search?query=$query&per_page=5";
    final response = await http.get(Uri.parse(url), headers: {
      "Authorization": apiKey,
    });
    if (response.statusCode == 200) {
      setState(() {
        _photos = json.decode(response.body)["photos"];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load photos');
    }
  }

  // Function to generate random prices
  String generateRandomPrice() {
    Random random = Random();
    double price = random.nextDouble() * 20 + 10; // Random price between 10 and 30 CAD
    return price.toStringAsFixed(2) + " CAD";
  }

  // Function to generate random names for penguins
  String generateRandomName() {
    List<String> names = ["Waddles", "Fluffy", "broski", "Squawk", "Snowy"];
    return names[Random().nextInt(names.length)];
  }

  void displayPaymentMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Successful"),
          content: Text("Thank you for your purchase!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penguins Gallery'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => fetchPhotos("penguin"),
        child: ListView.builder(
          itemCount: _photos.length,
          itemBuilder: (BuildContext context, int index) {
            String imageUrl = _photos[index]["src"]["medium"];
            String price = generateRandomPrice();
            String name = generateRandomName();
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(
                      imageUrl: imageUrl,
                      onBuy: () {
                        displayPaymentMessage();
                      },
                    ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            price,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onBuy;

  const FullScreenImage({Key? key, required this.imageUrl, this.onBuy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (onBuy != null) {
                  onBuy!();
                }
              },
              child: Text("Buy this"),
            ),
          ),
        ],
      ),
    );
  }
}
