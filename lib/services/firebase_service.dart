import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // ─── ALUR PENJEMPUTAN (AUDIT FIX) ───
  
  // 1. Mitra buat permintaan
  Future<void> createPickupRequest(String partnerName, String location) async {
    await _db.collection('pickup_requests').add({
      'partnerName': partnerName,
      'location': location,
      'status': 'pending', // pending -> assigned -> completed
      'timestamp': FieldValue.serverTimestamp(),
      'coordinates': const GeoPoint(-6.175392, 106.827153), // Mock Jakarta Pusat
    });
  }

  // 2. Admin lihat antrian permintaan
  Stream<QuerySnapshot> getPendingRequests() {
    return _db.collection('pickup_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // 3. Admin tugaskan Driver (Mock Logic)
  Future<void> assignDriver(String requestId, String driverId) async {
    await _db.collection('pickup_requests').doc(requestId).update({
      'status': 'assigned',
      'assignedDriver': driverId,
    });
  }

  // ─── BLOCKCHAIN LEDGER & COINS ───
  
  Future<void> recordTransaction({
    required String partnerId,
    required double weight,
    required String type,
  }) async {
    final coinReward = (weight * 10).toInt();
    await _db.collection('ledger_transactions').add({
      'timestamp': FieldValue.serverTimestamp(),
      'partnerId': partnerId,
      'weight': weight,
      'coinReward': coinReward,
      'status': 'verified',
    });
  }

  Stream<int> getBalance() {
    return _db.collection('ledger_transactions').snapshots().map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['coinReward'] as num).toInt();
      }
      return total;
    });
  }

  // Penukaran Koin (Redeem)
  Future<void> redeemCoins(int amount) async {
    await _db.collection('ledger_transactions').add({
      'timestamp': FieldValue.serverTimestamp(),
      'coinReward': -amount, // Mengurangi saldo
      'type': 'redeem',
      'status': 'processed',
    });
  }
}
