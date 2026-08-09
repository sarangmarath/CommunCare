import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import 'profile_screen.dart';
import 'success_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _photo;
  double? _lat;
  double? _lng;
  final _descController = TextEditingController();
  String? _category;
  bool _submitting = false;
  List<Map<String, dynamic>> _recent = [];
  bool _loadingRecent = true;

  final _categories = ['Pothole', 'Pipe Leakage', 'Waste Management', 'Gutter Issue', 'Road Damage', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    try {
      final data = await supabase.from('report').select().order('created_at', ascending: false).limit(4);
      setState(() {
        _recent = List<Map<String, dynamic>>.from(data);
        _loadingRecent = false;
      });
    } catch (e) {
      setState(() => _loadingRecent = false);
    }
  }

  Future<void> _takePhoto() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _snack('Location permission is required.');
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
        _lat = position.latitude;
        _lng = position.longitude;
      });
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (_photo == null) return _snack('Take a geo-tagged photo first.');
    if (_category == null) return _snack('Select an issue category.');
    if (_descController.text.trim().isEmpty) return _snack('Add a description.');

    setState(() => _submitting = true);
    try {
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('report-photos').upload(fileName, _photo!);
      final photoUrl = supabase.storage.from('report-photos').getPublicUrl(fileName);

      final inserted = await supabase.from('report').insert({
        'user_id': supabase.auth.currentUser!.id,
        'photo_url': photoUrl,
        'latitude': _lat,
        'longitude': _lng,
        'category': _category,
        'description': _descController.text.trim(),
        'status': 'Pending',
      }).select().single();

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => SuccessScreen(reportId: inserted['id'].toString())))
            .then((_) {
          setState(() {
            _photo = null;
            _lat = null;
            _lng = null;
            _category = null;
            _descController.clear();
          });
          _loadRecent();
        });
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CommunCare', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF74A98C)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadRecent,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 24),
              children: [
                _glassCard(
                  icon: Icons.camera_alt_outlined,
                  title: '1. Take a geo-tagged photo',
                  child: _photo == null
                      ? OutlinedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Capture photo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                          ),
                        )
                      : Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_photo!, height: 140, width: double.infinity, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '📍 ${_lat?.toStringAsFixed(4)}, ${_lng?.toStringAsFixed(4)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            TextButton(
                              onPressed: _takePhoto,
                              child: const Text('Retake', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 14),
                _glassCard(
                  icon: Icons.description_outlined,
                  title: '2. Fill submission form',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        dropdownColor: const Color(0xFF2D6A4F),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        decoration: _glassInputDecoration('Category'),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _category = v),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: _glassInputDecoration('Describe the issue...'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _glassCard(
                  icon: Icons.history,
                  title: '3. Recent history',
                  child: _loadingRecent
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _recent.isEmpty
                          ? const Text('No reports yet.', style: TextStyle(color: Colors.white70))
                          : Column(
                              children: _recent.map((r) {
                                final status = r['status'] ?? 'Pending';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r['category'] ?? '',
                                          style: const TextStyle(color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _statusColor(status),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kForestGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('4. Submit Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _glassInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _glassCard({required IconData icon, required String title, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}