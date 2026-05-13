import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/config/app_config.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Ambil Saldo Spesifik User (Penting agar poin Driver & Mitra tidak tertukar)
  Stream<int> getBalance(String userId) {
    return _db.collection('ledger_transactions')
        .where('partnerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['coinReward'] as num?)?.toInt() ?? 0;
          }
          return total;
        });
  }

  // 2. Buat Permintaan Baru (Limbah atau Pupuk)
  Future<void> createPickupRequest(String partnerName, String location, String type) async {
    try {
      await _db.collection('pickup_requests').add({
        'partnerName': partnerName,
        'location': location,
        'status': 'pending', 
        'type': type, 
        'timestamp': FieldValue.serverTimestamp(),
        'coordinates': const GeoPoint(-6.175392, 106.827153), 
      });
    } catch (e) {
      rethrow;
    }
  }

  // 3. Driver Finish (Sampai di Lokasi)
  Future<void> completeRequest(String requestId, double weight, String partnerId, String driverId) async {
    final coinReward = AppConfig.calculatePoints(weight);
    WriteBatch batch = _db.batch();
    
    batch.update(_db.collection('pickup_requests').doc(requestId), {'status': 'completed'});
    
    // Poin untuk Mitra
    batch.set(_db.collection('ledger_transactions').doc(), {
      'partnerId': partnerId,
      'coinReward': coinReward,
      'type': 'reward_partner',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Poin untuk Driver
    batch.set(_db.collection('ledger_transactions').doc(), {
      'partnerId': driverId,
      'coinReward': coinReward, 
      'type': 'reward_driver',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> acceptRequest(String requestId, String driverId) async {
    await _db.collection('pickup_requests').doc(requestId).update({
      'status': 'in_progress',
      'driverId': driverId,
    });
  }

  Future<void> redeemCoins(String userId, int amount) async {
    await _db.collection('ledger_transactions').add({
      'partnerId': userId,
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

  Stream<QuerySnapshot> getRequestsByStatus(String status) {
    return _db.collection('pickup_requests')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  Stream<DocumentSnapshot> getDriverLocation(String driverId) {
    return _db.collection('pickup_requests').doc('mock_id').snapshots();
  }
}
