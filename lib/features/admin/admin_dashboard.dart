import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Magloop Control Center'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Logistik'),
              Tab(text: 'Ledger Koin'),
            ],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildLogistikTab(context),
            _buildLedgerTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogistikTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatusList(context, 'Menunggu (Pending)', 'pending', Colors.orange),
          _buildStatusList(context, 'Dalam Perjalanan (On Progress)', 'in_progress', Colors.blue),
          _buildStatusList(context, 'Selesai (Completed)', 'completed', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildLedgerTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ledger_transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada transaksi ledger.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final int reward = data['coinReward'] ?? 0;
            final isRedeem = reward < 0;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isRedeem ? Colors.red[50] : AppColors.primarySurface,
                  child: Icon(isRedeem ? Icons.remove_circle_outline : Icons.add_circle_outline, 
                    color: isRedeem ? Colors.red : AppColors.primary),
                ),
                title: Text(isRedeem ? 'Penukaran Koin (Redeem)' : 'Reward Penjemputan'),
                subtitle: Text('ID: ${data['partnerId'] ?? 'Demo-User'}'),
                trailing: Text('${reward > 0 ? "+" : ""}$reward GC', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: isRedeem ? Colors.red : AppColors.primary)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusList(BuildContext context, String title, String status, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService().getRequestsByStatus(status),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Text('Tidak ada data', style: TextStyle(fontSize: 12, color: Colors.grey)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: ListTile(
                    title: Text(data['partnerName'] ?? ''),
                    subtitle: Text('Status: $status'),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
