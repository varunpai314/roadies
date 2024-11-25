import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:roadies/model/squad.dart';
import 'package:roadies/pages/create_squad_page.dart';
import 'package:roadies/pages/profile_page.dart';
import 'package:roadies/pages/squad_page.dart';
import 'package:roadies/requests/squad_members_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Add this line

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isInSquad = false;
  List<Map<String, dynamic>> userSquads =
      []; // List of squads the user is a part of

  late Location _locationService;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _locationService = Location();
    _checkSquadMembership();
    _initializeLocation();
  }

  // Fetch the current location
  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _currentLocation = await _locationService.getLocation();
    _locationService.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentLocation = locationData;
      });
    });
  }

  // Check if the user is in any squad and get the list of squads
  Future<void> _checkSquadMembership() async {
    final userId = await SquadMembersService.getUserId();
    if (userId != null) {
      final squads = await SquadMembersService.getUserSquads(userId);
      setState(() {
        _isInSquad = squads.isNotEmpty;
        userSquads = squads.cast<Map<String, dynamic>>();
      });
    }
  }

  // Show the modal bottom sheet to join or create a squad
  void _showJoinOrCreateSquadModal(BuildContext context) {
    final TextEditingController squadNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: squadNameController,
                decoration: const InputDecoration(
                  labelText: 'Squad Name',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  int? userId = await SquadMembersService.getUserId();
                  if (userId != null) {
                    await SquadMembersService.joinSquad(
                      int.parse(squadNameController.text),
                      userId,
                    );
                    await _checkSquadMembership();
                    setState(() {
                      _isInSquad = true;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Join Squad'),
              ),
              const Divider(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateSquadPage()));
                },
                child: const Text('Create Squad'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Text('Roadies'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
            icon: const Icon(Icons.person_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  if (_currentLocation != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.hardEdge,
                      height: 200,
                      child: GoogleMap(
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_currentLocation!.latitude!,
                              _currentLocation!.longitude!),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('currentLocation'),
                            position: LatLng(_currentLocation!.latitude!,
                                _currentLocation!.longitude!),
                          ),
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Row with "My Squads" and Icon button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Squads', style: TextStyle(fontSize: 18)),
                if (_isInSquad)
                  IconButton(
                    onPressed: () {
                      _showJoinOrCreateSquadModal(context);
                    },
                    icon: const Icon(Icons.add),
                    color: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Show the user's squads if they are part of any
            if (_isInSquad)
              Expanded(
                child: ListView.builder(
                  itemCount: userSquads.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(userSquads[index]['squadName']),
                      subtitle: Text(userSquads[index]['squadDescription']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SquadPage(
                                // squad: Squad.fromMap(userSquads[index]),
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else
              // If not in any squad, show message below FAB
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Click on the '+' button to create or join a squad.",
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _isInSquad
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                _showJoinOrCreateSquadModal(context);
              },
              child: Icon(Icons.add, color: Colors.green[800]),
            ),
    );
  }
}
