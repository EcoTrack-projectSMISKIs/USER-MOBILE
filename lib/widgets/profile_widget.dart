import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ProfileImageWidget extends StatefulWidget {
  const ProfileImageWidget({super.key});

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImageFromStorage();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final directory = await getApplicationDocumentsDirectory();
      final name = basename(picked.path);
      final savedImage = await File(picked.path).copy('${directory.path}/$name');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedImage.path);

      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<void> _loadImageFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _imageFile = File(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : const AssetImage("assets/profile_icon.png") as ImageProvider,
            child: Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: const Icon(Icons.edit, size: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text("Tap image to change", style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
