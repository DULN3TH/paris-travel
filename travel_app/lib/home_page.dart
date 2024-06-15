import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:travel_app/activities/cinema.dart';
import 'package:travel_app/geolocator/geolocation.dart';
import 'package:travel_app/login1.dart';
import 'package:travel_app/preferences/pref_ui.dart';
import 'package:travel_app/recommended.dart';

import 'activities.dart';
import 'destinations.dart';
import 'details/EiffelTowerDetails.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required List<String> selectedPreferences})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryState = state;
      });
    });
  }

  Future<void> _getBatteryLevel() async {
    final int batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    super.dispose();
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Sign-out error: $e');
    }
  }

  void _goToPreferencesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PreferencesScreen()),
    );
  }

  void _geolocation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Geolocation()),
    );
  }

  void _recommend() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Recommended()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.battery_full),
                SizedBox(width: 5),
                StreamBuilder<BatteryState>(
                  stream: _battery.onBatteryStateChanged,
                  initialData: _batteryState,
                  builder: (context, snapshot) {
                    return Text('$_batteryLevel% (${snapshot.data})');
                  },
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.person),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Logout'),
                value: 'logout',
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _signOut();
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: GNav(
        selectedIndex: 0,
        onTabChange: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/liked_places');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/compass');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/accelerometer');
          }
        },
        tabBorderRadius: 90,
        tabBorder: Border.all(color: Colors.deepPurple, width: 1),
        color: Colors.grey[800],
        activeColor: Colors.deepPurple,
        tabBackgroundColor:
            Theme.of(context).colorScheme.background.withOpacity(0.1),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        duration: Duration(milliseconds: 300),
        tabMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        gap: 4,
        tabs: const [
          GButton(
            icon: Icons.home_outlined,
            text: 'Home',
            iconSize: 24,
            iconColor: Colors.deepPurple,
          ),
          GButton(
            icon: Icons.favorite_outline,
            text: 'Liked',
            iconSize: 24,
            iconColor: Colors.deepPurple,
          ),
          GButton(
            icon: Icons.settings_outlined,
            text: 'Settings',
            iconSize: 24,
            iconColor: Colors.deepPurple,
          ),
          GButton(
            icon: Icons.explore_outlined,
            text: 'Compass',
            iconSize: 24,
            iconColor: Colors.deepPurple,
          ),
          GButton(
            icon: Icons.speed_outlined,
            text: 'Accelerometer',
            iconSize: 24,
            iconColor: Colors.deepPurple,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.withOpacity(0.1),
              Colors.purple.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  "What to do in Paris?",
                  style: GoogleFonts.bebasNeue(
                    fontSize: 50,
                  ),
                ),
              ),
              SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Where do you wanna go?',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _geolocation,
                      child: Text(
                        "Weather",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: _recommend,
                      child: Text(
                        "Recommended",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 25),
              SizedBox(
                height: 400,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EiffelTowerDetails(),
                          ),
                        );
                      },
                      child: destinations(
                        image: 'assets/images/paris-1.jpg',
                        name: 'Eiffel Tower',
                        price: '10100',
                        description:
                            'The Eiffel Tower is a wrought-iron lattice tower located on the Champ de Mars in Paris, France. It is named after the engineer Gustave Eiffel, whose company designed and built the tower.',
                      ),
                    ),
                    destinations(
                      image: 'assets/images/louvre.jpg',
                      name: 'Louvre Museum',
                      price: '9500',
                      description:
                          'The Louvre is the world\'s largest art museum and a historic monument in Paris, France.',
                    ),
                    destinations(
                      image: 'assets/images/notredame.jpg',
                      name: 'Notre-Dame-de-Paris',
                      price: '0',
                      description:
                          'Notre-Dame de Paris, often referred to simply as Notre-Dame, is a medieval Catholic cathedral on the Île de la Cité in the 4th arrondissement of Paris.',
                    ),
                    destinations(
                      image: 'assets/images/arc-de.jpg',
                      name: 'Arc de Triomphe',
                      price: '4300',
                      description:
                          'The Arc de Triomphe de l\'Étoile is one of the most famous monuments in Paris, standing at the western end of the Champs-Élysées at the center of Place Charles de Gaulle.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              ActivitiesSection(),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _goToPreferencesScreen,
                child: Text('Go to Preferences'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivitiesSection extends StatelessWidget {
  const ActivitiesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Activities in Paris",
            style: GoogleFonts.bebasNeue(
              fontSize: 30,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivitiesDetails1(),
                      ),
                    );
                  },
                  child: const Activities(
                    image: 'assets/images/cinema.jpg',
                    actName: 'Tour the Latin Quarter’s arthouse cinemas',
                    desc:
                        'A historic flytrap for Parisian cinephiles, the 5th and 6th arrondissements are still full of independent cinemas, most notably Le Champo on Rue des Écoles, where many of the Nouvelle Vague directors hung about in the \’50s and \’60s.',
                  ),
                ),
                const Activities(
                  image: 'assets/images/petite.jpg',
                  actName: 'Stroll along the abandoned Petite Ceinture',
                  desc:
                      'Built 150 years ago, La Petite Ceinture is almost 32km long. A public transport network until 1934, it was then used to transport goods until the late 1970s. Untouched for years, it has been cut up and transformed into various distinct sections, much like New York\'s High Line. The Petite Ceinture\'s best-known part begins in the 12th, a bucolic vision of plants and trees, but stretches across the 15th, 16th and 18th arrondissements, too.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
