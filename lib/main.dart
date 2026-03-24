import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const WegoApp());
}

// --- GLOBAL DATABASE (SIMULATED) ---
// This stores every single ride and rating for the Admin to see
List<Map<String, dynamic>> allBookings = [];

// Yaoundé Driver Fleet
List<Map<String, String>> drivers = [
  {'name': 'Amadou', 'car': 'Toyota Yaris', 'plate': 'CE 123 AA', 'rating': '4.8'},
  {'name': 'Chidi', 'car': 'Hyundai Elantra', 'plate': 'LT 456 BB', 'rating': '4.9'},
  {'name': 'Jean-Paul', 'car': 'Suzuki Swift', 'plate': 'CE 789 CC', 'rating': '4.7'},
  {'name': 'Ekani', 'car': 'Kia Rio', 'plate': 'CE 012 DD', 'rating': '5.0'},
];

class WegoApp extends StatelessWidget {
  const WegoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wego Yaoundé',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
      home: const WelcomeScreen(),
    );
  }
}

// --- 1. WELCOME SCREEN ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo, Colors.blueAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_taxi, size: 100, color: Colors.white),
            const Text('WEGO', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Yaoundé Signature Edition', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
              style: ElevatedButton.styleFrom(minimumSize: const Size(220, 55), shape: const StadiumBorder()),
              child: const Text('START MOVING', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. MAIN MAP SCREEN ---
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _destController = TextEditingController();
  String _calculatedPrice = "0";
  String _mapStatus = "Yaoundé Central";

  void _updatePrice(String val) {
    setState(() {
      _calculatedPrice = val.isEmpty ? "0" : (val.length * 320).toString();
      _mapStatus = val.isEmpty ? "Yaoundé Central" : "Routing to $val...";
    });
  }

  void _bookRide() {
    if (_destController.text.isEmpty) return;
    
    // Assign Driver
    var driver = drivers[Random().nextInt(drivers.length)];
    
    // Add to Global DB
    Map<String, dynamic> newRide = {
      'destination': _destController.text,
      'price': '$_calculatedPrice XAF',
      'driver': driver['name'],
      'car': driver['car'],
      'status': 'In Progress',
      'rating': 'Pending',
    };
    
    setState(() {
      allBookings.insert(0, newRide);
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmationScreen(rideData: newRide)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideMenu(context),
      appBar: AppBar(title: const Text("Wego Yaoundé")),
      body: Stack(
        children: [
          Container(color: Colors.grey[200], child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.map, size: 80, color: Colors.blueGrey),
              Text(_mapStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          )),
          Positioned(bottom: 0, left: 0, right: 0, child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: _destController, onChanged: _updatePrice, decoration: const InputDecoration(hintText: "Enter destination (Simbock, Bastos...)", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Est. Fare:"),
                Text("$_calculatedPrice XAF", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ]),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _bookRide, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)), child: const Text("CONFIRM RIDE")),
            ]),
          ))
        ],
      ),
    );
  }

  Drawer _buildSideMenu(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(decoration: BoxDecoration(color: Colors.indigo), child: Text("WEGO MENU", style: TextStyle(color: Colors.white))),
        ListTile(leading: const Icon(Icons.history), title: const Text("History"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()))),
        ListTile(leading: const Icon(Icons.admin_panel_settings, color: Colors.red), title: const Text("Admin Panel"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminScreen()))),
      ]),
    );
  }
}

// --- 3. CONFIRMATION & RATING ---
class ConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;
  const ConfirmationScreen({super.key, required this.rideData});
  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  double _userRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const Text("Arriving Soon!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text("Destination: ${widget.rideData['destination']}"),
          const Divider(),
          Text("DRIVER: ${widget.rideData['driver']}", style: const TextStyle(fontSize: 20)),
          Text("VEHICLE: ${widget.rideData['car']}"),
          const SizedBox(height: 40),
          const Text("Rate your driver:"),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => IconButton(
            icon: Icon(index < _userRating ? Icons.star : Icons.star_border, color: Colors.orange, size: 35),
            onPressed: () => setState(() => _userRating = index + 1.0),
          ))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {
            widget.rideData['rating'] = _userRating.toString();
            widget.rideData['status'] = "Completed";
            Navigator.pop(context);
          }, child: const Text("FINISH & SAVE")),
        ]),
      ),
    );
  }
}

// --- 4. HISTORY SCREEN ---
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: ListView.builder(
        itemCount: allBookings.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(allBookings[index]['destination']),
          subtitle: Text("Driver: ${allBookings[index]['driver']} | Rating: ${allBookings[index]['rating']}★"),
          trailing: Text(allBookings[index]['price'], style: const TextStyle(color: Colors.green)),
        ),
      ),
    );
  }
}

// --- 5. ADMIN PANEL ---
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("System Control"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(20), color: Colors.indigo[900], 
          child: Text("TOTAL TRIPS TODAY: ${allBookings.length}", style: const TextStyle(color: Colors.white))),
        Expanded(child: ListView.builder(
          itemCount: allBookings.length,
          itemBuilder: (context, index) => Card(child: ListTile(
            title: Text("RIDE TO: ${allBookings[index]['destination']}"),
            subtitle: Text("DRIVER: ${allBookings[index]['driver']} | STATUS: ${allBookings[index]['status']}"),
            trailing: Text("RATING: ${allBookings[index]['rating']}"),
          )),
        )),
      ]),
    );
  }
}