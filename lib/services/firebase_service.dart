import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/config/app_config.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Ambil Saldo GreenCoin Mitra
  Stream<int> getBalance() {
    return _db.collection('ledger_transactions')
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['coinReward'] as num?)?.toInt() ?? 0;
          }
          return total;
        });
  }

  // 2. Buat Permintaan Penjemputan Baru
  Future<void> createPickupRequest(String partnerName, String location) async {
    await _db.collection('pickup_requests').add({
      'partnerName': partnerName,
      'location': location,
      'status': 'pending', 
      'timestamp': FieldValue.serverTimestamp(),
      'coordinates': const GeoPoint(-6.175392, 106.827153), 
    });
  }

  // 3. Driver Finish (Sampai di Peternakan)
  Future<void> completeRequest(String requestId, double weight, String partnerId) async {
    final coinReward = AppConfig.calculatePoints(weight);
    WriteBatch batch = _db.batch();
    batch.update(_db.collection('pickup_requests').doc(requestId), {'status': 'completed'});
    batch.set(_db.collection('ledger_transactions').doc(), {
      'partnerId': partnerId,
      'coinReward': coinReward,
      'type': 'reward',
      'timestamp': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  // 4. Driver Accept Request
  Future<void> acceptRequest(String requestId, String driverId) async {
    await _db.collection('pickup_requests').doc(requestId).update({
      'status': 'in_progress',
      'driverId': driverId,
    });
  }

  // 5. Tukar Koin (Redeem)
  Future<void> redeemCoins(int amount) async {
    await _db.collection('ledger_transactions').add({
      'timestamp': FieldValue.serverTimestamp(),
      'coinReward': -amount,
      'type': 'redeem',
    });
  }

  // 6. Record Ledger Transaction (For Manual Input/Scanner)
  Future<void> recordTransaction({
    required String partnerId,
    required double weight,
    required String type,
  }) async {
    await _db.collection('ledger_transactions').add({
      'partnerId': partnerId,
      'weight': weight,
      'type': type,
      'coinReward': (weight * 10).toInt(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 7. Ambil Request berdasarkan Status
  Stream<QuerySnapshot> getRequestsByStatus(String status) {
    return _db.collection('pickup_requests')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  // 8. Mock functions untuk Logistik Screen (Mencegah Compile Error)
  Stream<LatLng> getDriverLocation(String driverId) {
    return Stream.value(const LatLng(-6.175392, 106.827153));
  }

  Future<void> simulateMovement(String driverId) async {
    // Demo simulation
  }
}
