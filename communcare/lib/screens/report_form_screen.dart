import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import 'success_screen.dart';

class ReportFormScreen extends StatefulWidget {
  final String category;
  const ReportFormScreen({super.key, required this.category});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  int _step = 0;
  File? _photo;
  double? _lat;
  double? _lng;
  final _descController = TextEditingController();
  bool _submitting = false;

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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
        _lat = position.latitude;
        _lng = position.longitude;
      });
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (_photo == null) {
      _snack('Please take a geo-tagged photo.');
      setState(() => _step = 0);
      return;
    }
    if (_descController.text.trim().isEmpty) {
      _snack('Please add a description.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('report-photos').upload(fileName, _photo!);
      final photoUrl = supabase.storage.from('report-photos').getPublicUrl(fileName);

      final inserted = await supabase.from('report').insert({
        'photo_url': photoUrl,
        'latitude': _lat,
        'longitude': _lng,
        'category': widget.category,
        'description': _descController.text.trim(),
        'status': 'Pending',
      }).select().single();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(reportId: inserted['id'].toString()),
          ),
        );
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: Column(
        children: [
          // Step progress bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(2, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: active ? kForestGreen : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _step == 0 ? _buildPhotoStep() : _buildDetailsStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const Text('Step 1 of 2',
            style: TextStyle(color: kMidGreen, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Take a Geo-tagged Photo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _photo == null
            ? GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kLightGreen, width: 1.5),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 48, color: kForestGreen),
                      SizedBox(height: 10),
                      Text('Tap to capture photo'),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_photo!, height: 220, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  Text('📍 ${_lat?.toStringAsFixed(4)}, ${_lng?.toStringAsFixed(4)}'),
                  TextButton(onPressed: _takePhoto, child: const Text('Retake Photo')),
                ],
              ),
        const Spacer(),
        FilledButton(
          onPressed: _photo == null ? null : () => setState(() => _step = 1),
          child: const Text('Next Step'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const Text('Step 2 of 2',
            style: TextStyle(color: kMidGreen, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Describe the Issue',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          controller: _descController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'What did you notice? Add details...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const Spacer(),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Submit Report'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => _step = 0),
          child: const Text('Back'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}