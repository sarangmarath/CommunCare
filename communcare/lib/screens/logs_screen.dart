import 'package:flutter/material.dart';
import '../main.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await supabase
          .from('report')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _reports = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Fixed':
        return const Color(0xFF2D6A4F);
      case 'Approved':
        return const Color(0xFF2461A3);
      case 'Rejected':
        return const Color(0xFF9B3B32);
      default: // Pending
        return const Color(0xFFBA7517);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(child: Text('No reports submitted yet.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, i) {
                      final r = _reports[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kLightGreen.withValues(alpha: 0.3),
                            child: const Icon(Icons.description_outlined, color: kForestGreen),
                          ),
                          title: Text(r['category'] ?? ''),
                          subtitle: Text(r['description'] ?? '',
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Chip(
                            label: Text(r['status'] ?? 'Pending',
                                style: const TextStyle(fontSize: 11, color: Colors.white)),
                            backgroundColor: _statusColor(r['status'] ?? 'Pending'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}