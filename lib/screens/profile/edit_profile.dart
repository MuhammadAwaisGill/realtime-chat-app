import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_service_provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final userService = ref.read(userServiceProvider);
      final userDoc = await userService.getUserData(user.uid);

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        _displayNameController.text = userData?['displayName'] ?? '';
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).value;
      final userService = ref.read(userServiceProvider);

      await userService.updateUserProfile(
        user!.uid,
        _displayNameController.text.trim(),
      );

      await user.updateDisplayName(_displayNameController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  // Upload image to Firebase Storage and update user photoURL
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  // Upload image to Firebase Storage and update user photoURL
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),                ],
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: user?.email ?? '',
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }
}