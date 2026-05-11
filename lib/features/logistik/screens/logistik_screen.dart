import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/firebase_service.dart';

class LogistikScreen extends StatefulWidget {
  const LogistikScreen({super.key});

  @override
  State<LogistikScreen> createState() => _LogistikScreenState();
}

class _LogistikScreenState extends State<LogistikScreen> {
  late GoogleMapController mapController;
  final FirebaseService _firebaseService = FirebaseService();
  
  // Marker Set
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  
  static const LatLng _initialCenter = LatLng(-6.175392, 106.827153);
  final String _driverId = "TRUCK_01"; // Driver ID simulasi

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updateMarkers(double lat, double lng) {
    final MarkerId markerId = MarkerId(_driverId);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Armada Magloop 01', snippet: 'In-Transit'),
    );

    setState(() {
      markers[markerId] = marker;
    });

    // Animasi gerak kamera mengikuti marker
    mapController.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Tracking Logistik Real-time'),
      ),
      body: Stack(
        children: [
          // ── Stream Lokasi Driver ──
          StreamBuilder<DocumentSnapshot>(
            stream: _firebaseService.getDriverLocation(_driverId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final double lat = data['lat'] ?? _initialCenter.latitude;
                final double lng = data['lng'] ?? _initialCenter.longitude;
                
                // Update marker tiap kali ada data baru
                WidgetsBinding.instance.addPostFrameCallback((_) {
                   _updateMarkers(lat, lng);
                });
              }

              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _initialCenter,
                  zoom: 15.0,
                ),
                markers: Set<Marker>.of(markers.values),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              );
            },
          ),

          // ── Kontrol Simulasi ──
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _firebaseService.simulateMovement(_driverId),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Mulai Rute (Simulasi)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Data lokasi diambil real-time dari Firestore.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
