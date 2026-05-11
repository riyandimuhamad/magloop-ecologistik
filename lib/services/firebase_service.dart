import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // 1. Mitra Request
  Future<void> createPickupRequest(String partnerName, String location) async {
    await _db.collection('pickup_requests').add({
      'partnerName': partnerName,
      'location': location,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 2. Driver ACC (Terima Order)
  Future<void> acceptRequest(String requestId, String driverId) async {
    await _db.collection('pickup_requests').doc(requestId).update({
      'status': 'in_progress',
      'assignedDriver': driverId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. Driver Finish (Sampai di Peternakan)
  Future<void> completeRequest(String requestId, double weight, String partnerId) async {
    final coinReward = (weight * 10).toInt();
    
    // Gunakan WriteBatch agar transaksi aman (Atomic)
    WriteBatch batch = _db.batch();

    // Update status request
    batch.update(_db.collection('pickup_requests').doc(requestId), {
      'status': 'completed',
      'finalWeight': weight,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Tambah Koin ke Ledger
    DocumentReference ledgerRef = _db.collection('ledger_transactions').doc();
    batch.set(ledgerRef, {
      'timestamp': FieldValue.serverTimestamp(),
      'partnerId': partnerId,
      'coinReward': coinReward,
      'type': 'pickup_reward',
    });

    await batch.commit();
  }

  // ─── STREAMS UNTUK UI ───
  Stream<QuerySnapshot> getRequestsByStatus(String status) {
    return _db.collection('pickup_requests')
        .where('status', isEqualTo: status)
        .snapshots();
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

  Future<void> redeemCoins(int amount) async {
    await _db.collection('ledger_transactions').add({
      'timestamp': FieldValue.serverTimestamp(),
      'coinReward': -amount,
      'type': 'redeem',
    });
  }
}
