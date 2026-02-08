// screens/edit_profile_screen.dart
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/profile_service.dart';
import 'profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 🔐 Replace with actual token
  String token = 'YOUR_BEARER_TOKEN';

  final Color themeColor = const Color(0xFF1B2B57);
  final Color softWhite = const Color(0xFFF9FAFB);

  bool isLoading = true;
  bool isUpdating = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  String? avatarUrl;
  File? selectedImageFile;

  final ImagePicker _picker = ImagePicker();
  final String baseUrl = 'https://byte.edusaint.in';

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  // --------------------------------------------------
  // FETCH PROFILE
  // --------------------------------------------------
  Future<void> fetchProfile() async {
    try {
      setState(() => isLoading = true);

      final data = await ProfileService.getProfile(token);

      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['mobile'] ?? '';
      classController.text = data['class'] ?? '';
      avatarUrl = data['image'];
    } catch (e) {
      debugPrint('PROFILE ERROR: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load profile')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --------------------------------------------------
  // AVATAR IMAGE HANDLER (NO ASSET IMAGE)
  // --------------------------------------------------
  ImageProvider<Object>? _avatarImageProvider() {
    if (selectedImageFile != null) {
      return FileImage(selectedImageFile!);
    }

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http')) {
        return NetworkImage(avatarUrl!);
      }
      if (avatarUrl!.startsWith('/')) {
        return NetworkImage('$baseUrl$avatarUrl');
      }
    }

    return null;
  }

  // --------------------------------------------------
  // IMAGE PICKER
  // --------------------------------------------------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked != null) {
        setState(() {
          selectedImageFile = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // UPDATE PROFILE
  // --------------------------------------------------
  Future<void> _updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() => isUpdating = true);

    try {
      final res = await ProfileService.updateProfile(
        token: token,
        name: nameController.text.trim(),
        studentClass: classController.text.trim(),
        mobile: phoneController.text.trim(),
        imageFile: selectedImageFile,
      );

      if (res['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Update failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Update failed')));
    } finally {
      setState(() => isUpdating = false);
    }
  }

  // --------------------------------------------------
  // TEXT FIELD BUILDER (UNCHANGED STYLE)
  // --------------------------------------------------
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: themeColor.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: themeColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: softWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 120),
            child: Column(
              children: [
                // AVATAR
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _avatarImageProvider(),
                          child: _avatarImageProvider() == null
                              ? Icon(Icons.person, size: 55, color: themeColor)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showAvatarPicker,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                _buildTextField(
                  "Full Name",
                  nameController,
                  icon: Icons.person,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  "Email Address",
                  emailController,
                  icon: Icons.email,
                  readOnly: true,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  "Phone Number",
                  phoneController,
                  icon: Icons.phone,
                ),
                const SizedBox(height: 18),
                _buildTextField("Class", classController, icon: Icons.school),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isUpdating ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: isUpdating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // APP BAR
          Container(
            height: kToolbarHeight + 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.bottomCenter,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0A0F), Color(0xFF1A2339)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(FontAwesomeIcons.qrcode, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
