// lib/screens/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_manager/screens/admin/notices/post_notice_screen.dart';
import 'package:society_manager/screens/admin/payments/admin_pending_payments_screen.dart';
import 'package:society_manager/screens/auth/profile_screen.dart';
import 'package:society_manager/screens/admin/maintenance/set_maintenance_screen.dart';
import 'package:society_manager/screens/admin/complaints/admin_complaints_list_screen.dart';
import 'package:society_manager/screens/admin/complaints/admin_complaint_details_screen.dart';
import 'package:society_manager/screens/admin/payments/all_payments_screen.dart';
import 'package:society_manager/screens/admin/users/manage_admins_screen.dart';
import 'package:society_manager/screens/admin/maintenance/maintenance_history_screen.dart';
import 'package:society_manager/screens/admin/notices/notice_history_screen.dart';
import 'package:society_manager/screens/admin/users/approve_residents_screen.dart';
import 'package:society_manager/screens/admin/payments/admin_payment_details_screen.dart';
import 'package:society_manager/screens/resident/payments/pending_payments_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      drawer: const _AdminDrawer(),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF4285F4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.person_outline),
            label: const Text('Profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 24,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SummarySection(),
                const SizedBox(height: 16),
                _QuickRow(
                  onSetMaintenance: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SetMaintenanceScreen()));
                  },
                  onPostNotice: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PostNoticeScreen()));
                  },
                  onViewComplaints: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminComplaintsListScreen()));
                  },
                  onViewPayments: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AllPaymentsScreen()));
                  },
                ),
                const SizedBox(height: 16),
                const _RecentPaymentsCard(),
                const SizedBox(height: 16),
                const _UrgentComplaintsCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================== Admin Drawer (Sidebar) ========================== */
class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF4285F4),
            ),
            child: Text(
              'Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person_add_alt_1_outlined,
            text: 'Approve Residents',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ApproveResidentsScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.admin_panel_settings_outlined,
            text: 'Manage Admins',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageAdminsScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.note_alt_outlined,
            text: 'Manage Notices',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NoticeHistoryScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.history_outlined,
            text: 'Maintenance History',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceHistoryScreen()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.pending,
            text: 'Pending Payments',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPendingPaymentsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}


/* ========================= Summary Section ========================= */
class _SummarySection extends StatelessWidget {
  const _SummarySection();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _SummaryTileStream(label: 'Total Residents', icon: Icons.groups_2_outlined, iconColor: Color(0xFF2563EB), queryKind: _SummaryQueryKind.totalResidents),
        _SummaryTileStream(label: 'Pending Approvals', icon: Icons.person_add_alt_1_outlined, iconColor: Color(0xFFF59E0B), warning: true, queryKind: _SummaryQueryKind.pendingApprovalsCount),
        _SummaryTileStream(label: 'Collected This Month', icon: Icons.currency_rupee, iconColor: Color(0xFF16A34A), accentValue: true, queryKind: _SummaryQueryKind.collectedThisMonthAmount),
        _SummaryTileStream(label: 'Active Complaints', icon: Icons.chat_bubble_outline, iconColor: Color(0xFFE11D48), queryKind: _SummaryQueryKind.activeComplaintsCount),
      ],
    );
  }
}
enum _SummaryQueryKind { totalResidents, pendingApprovalsCount, collectedThisMonthAmount, activeComplaintsCount }
class _SummaryTileStream extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool warning;
  final bool accentValue;
  final _SummaryQueryKind queryKind;
  const _SummaryTileStream({required this.label, required this.icon, required this.iconColor, required this.queryKind, this.warning = false, this.accentValue = false});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width < 600 ? (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2 : 250,
      child: StreamBuilder(
        stream: _streamFor(queryKind),
        builder: (context, snapshot) {
          final valueText = _valueFromSnapshot(queryKind, snapshot);
          return _SummaryTile(label: label, value: valueText, icon: icon, iconColor: iconColor, warning: warning, accentValue: accentValue);
        },
      ),
    );
  }
  Stream<dynamic> _streamFor(_SummaryQueryKind kind) {
    final fs = FirebaseFirestore.instance;
    switch (kind) {
      case _SummaryQueryKind.totalResidents:
        return fs.collection('users').where('isActive', isEqualTo: true).snapshots().map((snap) {
          int count = 0;
          for (final d in snap.docs) {
            final roles = List.from(d.data()['roles'] ?? []);
            if (roles.contains('resident')) count++;
          }
          return count;
        });
      case _SummaryQueryKind.pendingApprovalsCount:
        return fs.collection('users').where('isActive', isEqualTo: false).snapshots().map((s) => s.size);
      case _SummaryQueryKind.collectedThisMonthAmount:
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final nextMonth = DateTime(now.month == 12 ? now.year + 1 : now.year, now.month == 12 ? 1 : now.month + 1, 1);
        return fs.collection('payments').where('status', isEqualTo: 'paid').where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart)).where('paidAt', isLessThan: Timestamp.fromDate(nextMonth)).snapshots().map((s) {
          num total = 0;
          for (final d in s.docs) { total += (d.data()['amount'] ?? 0) as num; }
          return total;
        });
      case _SummaryQueryKind.activeComplaintsCount:
        return fs.collection('complaints').where('status', isNotEqualTo: 'Resolved').snapshots().map((s) => s.size);
    }
  }
  String _valueFromSnapshot(_SummaryQueryKind kind, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return '…';
    if (snapshot.hasError) return '—';
    final v = snapshot.data;
    if (v == null) return '0';
    if (kind == _SummaryQueryKind.collectedThisMonthAmount) {
      final num n = (v is num) ? v : 0;
      return '₹ ${_formatAmount(n)}';
    }
    return v.toString();
  }
  String _formatAmount(num n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final left = s.length - i - 1;
      if (left > 0 && left % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }
}
class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool warning;
  final bool accentValue;
  const _SummaryTile({required this.label, required this.value, required this.icon, required this.iconColor, this.warning = false, this.accentValue = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 8))]),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accentValue ? const Color(0xFF16A34A) : (warning ? const Color(0xFFB91C1C) : const Color(0xFF111827)))),
            ]),
          ),
          if (warning && value != '0') const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
        ],
      ),
    );
  }
}

/* =========================== Quick Actions ========================== */
class _QuickRow extends StatelessWidget {
  final VoidCallback onSetMaintenance;
  final VoidCallback onPostNotice;
  final VoidCallback onViewComplaints;
  final VoidCallback onViewPayments;

  const _QuickRow({
    required this.onSetMaintenance,
    required this.onPostNotice,
    required this.onViewComplaints,
    required this.onViewPayments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _QuickBtn(label: 'Set Maintenance', color: const Color(0xFF2563EB), icon: Icons.settings_suggest_outlined, onTap: onSetMaintenance, filled: true)),
            const SizedBox(width: 12),
            Expanded(child: _QuickBtn(label: 'Post Notice', color: const Color(0xFF16A34A), icon: Icons.campaign_outlined, onTap: onPostNotice, filled: true)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _QuickBtn(label: 'View Complaints', icon: Icons.forum_outlined, onTap: onViewComplaints)),
            const SizedBox(width: 12),
            Expanded(child: _QuickBtn(label: 'View Payments', icon: Icons.receipt_long_outlined, onTap: onViewPayments)),
          ],
        ),
      ],
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool filled;
  final VoidCallback onTap;
  const _QuickBtn({required this.label, required this.icon, this.color, required this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? Theme.of(context).colorScheme.secondary;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: filled ? btnColor : Colors.white, borderRadius: BorderRadius.circular(10), border: filled ? null : Border.all(color: const Color(0xFFE5E7EB)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: filled ? Colors.white : btnColor, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: TextStyle(color: filled ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}


/* ======================== Recent Payments Card ====================== */
class _RecentPaymentsCard extends StatelessWidget {
  const _RecentPaymentsCard();
  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;
    return _CardShell(
      title: 'Recent Payments',
      subtitle: 'Latest payment transactions',
      trailing: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AllPaymentsScreen()));
        },
        child: const Text('View All Payments', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: fs.collection('payments').where('status', isEqualTo: 'paid').orderBy('paidAt', descending: true).limit(2).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const _LoadingList(skeletonCount: 2);
          if (snapshot.hasError) return const _ErrorInfo(text: 'Failed to load payments');
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const _EmptyInfo(text: 'No payments yet');
          return Column(
            children: [
              for (int i = 0; i < docs.length; i++) ...[
                _PaymentRow(doc: docs[i]),
                if (i != docs.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

// UPDATED WIDGET: Made tappable
class _PaymentRow extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _PaymentRow({required this.doc});
  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final name = (data['userName'] ?? '').toString();
    final flat = (data['flat'] ?? '').toString();
    final purpose = (data['purpose'] ?? 'Maintenance').toString();
    final amount = (data['amount'] ?? 0) as num;
    final paidAt = data['paidAt'];
    final dateStr = _fmtDate(paidAt);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPaymentDetailsScreen(paymentId: doc.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name.isEmpty ? 'Resident' : name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text('${flat.isEmpty ? '—' : flat} • $purpose', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹ ${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF16A34A))),
              const SizedBox(height: 4),
              Text(dateStr, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ]),
          ],
        ),
      ),
    );
  }
  String _fmtDate(dynamic ts) {
    if (ts is Timestamp) {
      final d = ts.toDate();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return '—';
  }
}

/* ====================== Urgent Complaints Card ===================== */
class _UrgentComplaintsCard extends StatelessWidget {
  const _UrgentComplaintsCard();

  @override
  Widget build(BuildContext context) {
    final fs = FirebaseFirestore.instance;

    return _CardShell(
      title: 'Urgent Complaints',
      subtitle: 'High priority issues',
      trailing: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminComplaintsListScreen()),
          );
        },
        child: const Text(
          'View All',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: fs
            .collection('complaints')
            .where('priority', isEqualTo: 'High')
            .orderBy('createdAt', descending: true)
            .limit(2)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingList(skeletonCount: 2);
          }
          if (snapshot.hasError) {
            return const _ErrorInfo(text: 'Failed to load complaints');
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const _EmptyInfo(text: 'No high priority complaints');
          }

          return Column(
            children: [
              for (int i = 0; i < docs.length; i++) ...[
                _UrgentRow(doc: docs[i]),
                if (i != docs.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}
class _UrgentRow extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _UrgentRow({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final title = (data['title'] ?? 'Complaint').toString();
    final flat = (data['flat'] ?? '—').toString();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminComplaintDetailsScreen(complaintId: doc.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.report_gmailerrorred_outlined, color: Color(0xFFE11D48), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text('Flat: $flat', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(20)),
              child: const Text('High', style: TextStyle(color: Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================================ Shell & Helpers ============================ */
class _CardShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  const _CardShell({required this.title, required this.child, this.subtitle, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 12))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                  if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))]
                ]),
              ),
              if (trailing != null) trailing!,
            ],
          ),
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
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(text, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)));
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
      children: List.generate(skeletonCount, (i) {
        return Container(
          margin: EdgeInsets.only(bottom: i == skeletonCount - 1 ? 0 : 10),
          height: 56,
          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
        );
      }),
    );
  }
}
