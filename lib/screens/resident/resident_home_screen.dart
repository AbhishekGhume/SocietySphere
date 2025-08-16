// lib/screens/resident_home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_manager/screens/auth/profile_screen.dart';
import 'package:society_manager/screens/resident/notices/notices_screen.dart';
import 'package:society_manager/screens/resident/notices/notice_details_screen.dart';
import 'package:society_manager/screens/resident/complaints/complaints_screen.dart';
import 'package:society_manager/screens/resident/complaints/new_complaint_screen.dart';
import 'package:society_manager/screens/resident/complaints/complaint_details_screen.dart';
import 'package:society_manager/screens/resident/payments/make_payment_screen.dart';
import 'package:society_manager/screens/resident/payments/payment_history_screen.dart';
import 'package:society_manager/screens/resident/payments/pending_payments_screen.dart';

class ResidentHomeScreen extends StatelessWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 24),
              const _QuickActions(),
              const SizedBox(height: 24),
              const _PendingPaymentsCard(),
              const SizedBox(height: 16),
              const _RecentNoticesCard(),
              const SizedBox(height: 16),
              const _MyComplaintsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Header ------------------------------ */
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFF4285F4),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.home_outlined, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: uid == null
              ? const _HeaderText(name: 'Resident', role: 'Resident')
              : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const _HeaderText(name: 'Loading…', role: 'Resident');
              final data = snapshot.data!.data() ?? {};
              final firstName = (data['firstName'] ?? 'Resident').toString();
              return _HeaderText(name: firstName, role: 'Resident');
            },
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.person_outline, size: 18),
          label: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String name;
  final String role;
  const _HeaderText({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, $name',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 2),
        Text(role, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
      ],
    );
  }
}

/* --------------------------- Quick Actions -------------------------- */
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 12) / 2;
        return Column(
          children: [
            Row(
              children: [
                _ActionTile(
                  label: 'Pay Bills',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.blue.shade700,
                  width: tileWidth,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PendingPaymentsScreen()));
                  },
                ),
                const SizedBox(width: 12),
                _ActionTile(
                  label: 'Notices',
                  icon: Icons.notifications_none_rounded,
                  color: Colors.green.shade700,
                  width: tileWidth,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticesScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionTile(
                  label: 'Complaints',
                  icon: Icons.report_gmailerrorred_outlined,
                  color: Colors.orange.shade800,
                  width: tileWidth,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplaintsScreen()));
                  },
                ),
                const SizedBox(width: 12),
                _ActionTile(
                  label: 'History',
                  icon: Icons.history,
                  color: Colors.purple.shade700,
                  width: tileWidth,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentHistoryScreen()));
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double width;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

/* ------------------------- Pending Payments ------------------------- */
class _PendingPaymentsCard extends StatelessWidget {
  const _PendingPaymentsCard();
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return _CardShell(
      title: 'Pending Payments',
      trailing: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: uid == null ? null : FirebaseFirestore.instance.collection('payments').where('userId', isEqualTo: uid).where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          final hasPayments = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
          return hasPayments ? Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle), child: const Icon(Icons.error_outline, color: Colors.white, size: 16)) : const SizedBox.shrink();
        },
      ),
      child: uid == null
          ? const _EmptyInfo(text: 'Sign in to view payments')
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('payments').where('userId', isEqualTo: uid).where('status', isEqualTo: 'pending').orderBy('dueDate').limit(2).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingList(skeletonCount: 2);
          if (snapshot.hasError) return _ErrorInfo(text: 'Error: ${snapshot.error}');
          final pendingDocs = snapshot.data?.docs ?? [];
          if (pendingDocs.isEmpty) return const _EmptyInfo(text: 'No pending payments');

          return Column(
            children: [
              for (int i = 0; i < pendingDocs.length; i++) ...[
                _PaymentRow(title: (pendingDocs[i]['title'] ?? 'Payment').toString(), amount: (pendingDocs[i]['amount'] ?? 0), dueDateLabel: _formatDue(pendingDocs[i]['dueDate']), isOverdue: _isOverdue(pendingDocs[i]['dueDate'])),
                if (i != pendingDocs.length - 1) const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MakePaymentScreen()));
                  },
                  child: const Text(
                    'View All Payments',
                    style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  static String _formatDue(dynamic ts) {
    if (ts is Timestamp) {
      final d = ts.toDate();
      return 'Due: ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return 'Due: —';
  }
  static bool _isOverdue(dynamic ts) {
    if (ts is Timestamp) {
      final dueDate = ts.toDate();
      final today = DateTime.now();
      return dueDate.isBefore(DateTime(today.year, today.month, today.day));
    }
    return false;
  }
}
class _PaymentRow extends StatelessWidget {
  final String title;
  final num amount;
  final String dueDateLabel;
  final bool isOverdue;
  const _PaymentRow({required this.title, required this.amount, required this.dueDateLabel, this.isOverdue = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFCA5A5))),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))), Text('₹ ${_formatAmount(amount)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)))]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(dueDateLabel, style: TextStyle(fontSize: 12, color: isOverdue ? const Color(0xFFDC2626) : const Color(0xFF6B7280), fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal)),
            if (isOverdue) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(12)), child: const Text('OVERDUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
          ]),
        ],
      ),
    );
  }
  String _formatAmount(num amount) {
    if (amount is int) return amount.toString();
    return (amount as double).toStringAsFixed(0);
  }
}


/* --------------------------- Recent Notices ------------------------- */
class _RecentNoticesCard extends StatelessWidget {
  const _RecentNoticesCard();
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Recent Notices',
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('notices').orderBy('date', descending: true).limit(2).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingList(skeletonCount: 2);
          if (snapshot.hasError) return const _ErrorInfo(text: 'Failed to load notices');
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const _EmptyInfo(text: 'No recent notices');
          return Column(
            children: [
              for (int i = 0; i < docs.length; i++) ...[
                _NoticeRow(docId: docs[i].id, title: (docs[i]['title'] ?? 'Notice').toString(), dateLabel: _formatDate(docs[i]['date']), priority: (docs[i]['priority'] ?? 'low').toString()),
                if (i != docs.length - 1) const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticesScreen())), child: const Text('View All Notices', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700)))),
            ],
          );
        },
      ),
    );
  }
  static String _formatDate(dynamic ts) {
    if (ts is Timestamp) {
      final d = ts.toDate();
      return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
    }
    return '—';
  }
}
class _NoticeRow extends StatelessWidget {
  final String docId;
  final String title;
  final String dateLabel;
  final String priority;
  const _NoticeRow({required this.docId, required this.title, required this.dateLabel, required this.priority});
  Color get chipBg {
    switch (priority.toLowerCase()) {
      case 'high': return const Color(0xFFFFE4E6);
      case 'medium': return const Color(0xFFFFF7ED);
      default: return const Color(0xFFEFF6FF);
    }
  }
  Color get chipFg {
    switch (priority.toLowerCase()) {
      case 'high': return const Color(0xFFB91C1C);
      case 'medium': return const Color(0xFFB45309);
      default: return const Color(0xFF1D4ED8);
    }
  }
  String get chipText => priority.toLowerCase();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeDetailsScreen(noticeId: docId))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, color: Color(0xFF9CA3AF), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                Text(dateLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ]),
            ),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(20)), child: Text(chipText, style: TextStyle(color: chipFg, fontSize: 12, fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }
}

/* --------------------------- My Complaints -------------------------- */
class _MyComplaintsCard extends StatelessWidget {
  const _MyComplaintsCard();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return _CardShell(
      title: 'My Complaints',
      child: uid == null
          ? const _EmptyInfo(text: 'Sign in to view complaints')
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('complaints').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).limit(2).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingList(skeletonCount: 2);
          if (snapshot.hasError) return _ErrorInfo(text: 'Failed to load complaints: ${snapshot.error}');
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Column(
              children: [
                const _EmptyInfo(text: 'You have no active complaints.'),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewComplaintScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white),
                    child: const Text('New Complaint'),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              for (int i = 0; i < docs.length; i++) ...[
                _ComplaintRow(complaint: docs[i]),
                if (i != docs.length - 1) const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplaintsScreen())),
                    child: const Text('View All', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewComplaintScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white),
                    child: const Text('New Complaint'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ComplaintRow extends StatelessWidget {
  final QueryDocumentSnapshot complaint;
  const _ComplaintRow({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final data = complaint.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'Pending';
    final title = data['title'] ?? 'Complaint';

    Color chipBg, chipFg;

    switch (status.toLowerCase()) {
      case 'resolved':
        chipBg = const Color(0xFFE6F4EA);
        chipFg = const Color(0xFF1B5E20);
        break;
      case 'in progress':
        chipBg = const Color(0xFFFFF7ED);
        chipFg = const Color(0xFFB45309);
        break;
      default: // Pending
        chipBg = const Color(0xFFFEE2E2);
        chipFg = const Color(0xFFB91C1C);
    }

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintDetailsScreen(complaintId: complaint.id))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(
          children: [
            Expanded(
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: TextStyle(color: chipFg, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}


/* ------------------------------- Shell & Helpers ------------------------------ */
class _CardShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _CardShell({required this.title, required this.child, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 12))], border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))), const Spacer(), if (trailing != null) trailing!]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
class _EmptyInfo extends StatelessWidget {
  final String text;
  const _EmptyInfo({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)));
  }
}
class _ErrorInfo extends StatelessWidget {
  final String text;
  const _ErrorInfo({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(children: [const Icon(Icons.error_outline, size: 18, color: Colors.red), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.red, fontSize: 13))]);
  }
}
class _LoadingList extends StatelessWidget {
  final int skeletonCount;
  const _LoadingList({this.skeletonCount = 2});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(skeletonCount, (index) {
        return Container(
          margin: EdgeInsets.only(bottom: index == skeletonCount - 1 ? 0 : 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: Row(
            children: [
              Container(width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 12, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(8)))),
            ],
          ),
        );
      }),
    );
  }
}
