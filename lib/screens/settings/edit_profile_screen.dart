import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  Timer? _usernameDebounce;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;

  bool _isLoading = false;
  bool _isLoadingProfile = true; // robust loading system
  bool _isUploadingPicture = false;
  bool _hasUnsavedChanges = false;
  int _completenessScore = 0;

  // Form Controllers - Core Identity
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  // Form Controllers - Trust
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _websiteController = TextEditingController();

  // Form Controllers - Role Specific (Farmer / Investor)
  final _businessNameController = TextEditingController();
  final _budgetRangeController = TextEditingController();

  // Privacy controls
  bool _discoverable = true;
  bool _showContactInfo = false;

  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
    _fetchLiveProfile();
  }

  Future<void> _fetchLiveProfile() async {
    try {
      final updatedUser = await AuthService.fetchProfile();
      if (updatedUser != null && mounted) {
        context.read<AuthProvider>().setUser(updatedUser);
        _loadInitialData();
        setState(() {
          _hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert(
          'Failed to sync profile: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _loadInitialData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      _currentUser = authProvider.user!;
      final profile = _currentUser.profile;

      _nameController.text = profile?.name ?? '';
      _usernameController.text = profile?.username ?? '';
      _isUsernameAvailable = _usernameController.text.isNotEmpty;
      _phoneController.text = _currentUser.phone ?? '';
      _countryController.text = profile?.country ?? '';
      _cityController.text = profile?.city ?? '';

      _headlineController.text = profile?.headline ?? '';
      _bioController.text = profile?.bio ?? '';
      _linkedinController.text = profile?.linkedin ?? '';
      _websiteController.text = profile?.website ?? '';

      _businessNameController.text = profile?.businessName ?? '';
      _budgetRangeController.text = profile?.budgetRange ?? '';

      _discoverable = profile?.discoverable ?? true;
      _showContactInfo = profile?.showContactInfo ?? false;

      _completenessScore = profile?.completenessScore ?? 0;
    }

    // Listen for changes
    _usernameController.addListener(_onUsernameChanged);
    for (var controller in [
      _nameController,
      _phoneController,
      _countryController,
      _cityController,
      _headlineController,
      _bioController,
      _linkedinController,
      _websiteController,
      _businessNameController,
      _budgetRangeController,
    ]) {
      controller.addListener(_markUnsaved);
    }
  }

  void _onUsernameChanged() {
    _markUnsaved();
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = null;
      });
      return;
    }

    if (username == _currentUser.profile?.username) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = true;
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = null;
      });
      return;
    }

    if (_usernameDebounce?.isActive ?? false) _usernameDebounce!.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _isCheckingUsername = true);
      try {
        final available = await AuthService.isUsernameAvailable(username);
        if (mounted) {
          setState(() {
            _isUsernameAvailable = available;
            _isCheckingUsername = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isCheckingUsername = false);
      }
    });
  }

  void _markUnsaved() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _tabController.dispose();
    _nameController.removeListener(_markUnsaved);
    _usernameController.removeListener(_onUsernameChanged);
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _businessNameController.dispose();
    _budgetRangeController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveProfile() async {
    if (_isCheckingUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for username availability check'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showErrorAlert('Please correct the errors in the form');
      return;
    }

    if (_isUsernameAvailable == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This username is already taken'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      String linkedinText = _linkedinController.text.trim();
      if (linkedinText.isNotEmpty && !linkedinText.startsWith('http')) {
        linkedinText = linkedinText.contains('.')
            ? 'https://$linkedinText'
            : 'https://linkedin.com/in/$linkedinText';
      }

      String websiteText = _websiteController.text.trim();
      if (websiteText.isNotEmpty && !websiteText.startsWith('http')) {
        websiteText = 'https://$websiteText';
      }

      final updates = {
        'phone': _phoneController.text.trim(),
        'profile': {
          'name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'country': _countryController.text.trim(),
          'city': _cityController.text.trim(),
          'headline': _headlineController.text.trim(),
          'bio': _bioController.text.trim(),
          'portfolio_links': {'linkedin': linkedinText, 'website': websiteText},
          'privacy_settings': {
            'discoverable': _discoverable,
            'show_contact_info': _showContactInfo,
          },
        },
      };

      if (_currentUser.role == 'farmer') {
        (updates['profile'] as Map<String, dynamic>)['farmer_details'] = {
          'business_name': _businessNameController.text.trim(),
        };
      } else if (_currentUser.role == 'investor') {
        (updates['profile'] as Map<String, dynamic>)['investor_details'] = {
          'budget_range': _budgetRangeController.text.trim(),
        };
      }

      final updatedUser = await AuthService.updateProfile(updates);

      if (updatedUser != null && mounted) {
        context.read<AuthProvider>().setUser(updatedUser);
        setState(() {
          _hasUnsavedChanges = false;
          _completenessScore = updatedUser.profile?.completenessScore ?? 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();

    // Bottom sheet for source selection
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingPicture = true);

      final result = await AuthService.uploadProfilePicture(
        pickedFile,
      );

      if (result != null && mounted) {
        // Soft-sync the state
        _fetchLiveProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert(
          'Upload failed: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPicture = false);
      }
    }
  }


  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Identity'),
              Tab(text: 'Trust'),
              Tab(text: 'Role & Privacy'),
            ],
            indicatorColor: theme.colorScheme.primary,
          ),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                onPressed: _isLoading ? null : _saveProfile,
                tooltip: 'Save Changes',
              ),
          ],
        ),
        body: _isLoadingProfile
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Completeness Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Profile Completeness',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_completenessScore%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _completenessScore / 100,
                              minHeight: 8,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _completenessScore == 100
                                    ? Colors.green
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildIdentityTab(theme),
                          _buildTrustTab(theme),
                          _buildRolePrivacyTab(theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: (_hasUnsavedChanges && !_isLoadingProfile)
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildIdentityTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Stack(
            children: [
              InkWell(
                onTap: _isUploadingPicture ? null : _pickAndUploadImage,
                borderRadius: BorderRadius.circular(50),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: _currentUser.profilePicture != null
                      ? NetworkImage(
                          _currentUser.profilePicture!.startsWith('http')
                              ? _currentUser.profilePicture!
                              : '${AuthService.baseUrl}${_currentUser.profilePicture!}',
                        )
                      : null,
                  child:
                      _currentUser.profilePicture == null &&
                          !_isUploadingPicture
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: theme.colorScheme.primary,
                        )
                      : (_isUploadingPicture
                            ? CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              )
                            : null),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingPicture ? null : _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: _isUploadingPicture
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Name is required';
            if (val.trim().length < 2) return 'Name is too short';
            if (!RegExp(r"^[a-zA-Z\s']+$").hasMatch(val.trim())) {
              return 'Only letters and spaces allowed';
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _usernameController,
          label: 'Username',
          icon: Icons.alternate_email,
          helperText: 'Public unique handle',
          validator: (val) {
            if (val == null || val.isEmpty) return 'Username is required';
            if (val.length < 3) return 'Too short (min 3)';
            if (!RegExp(r'^[a-z0-9._]{3,20}$').hasMatch(val)) {
              return 'Use lowercase, numbers, dots, underscores';
            }
            if (_isUsernameAvailable == false) {
              return 'Username is already taken';
            }
            return null;
          },
          suffixIcon: _isLoadingProfile
              ? null
              : (_isCheckingUsername
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_usernameController.text.isNotEmpty &&
                              _usernameController.text !=
                                  _currentUser.profile?.username
                          ? Icon(
                              _isUsernameAvailable == true
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _isUsernameAvailable == true
                                  ? Colors.green
                                  : Colors.red,
                            )
                          : null)),
        ),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (val) {
            if (val != null && val.isNotEmpty) {
              if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(val)) {
                return 'Invalid phone format';
              }
            }
            return null;
          },
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _countryController,
                label: 'Country',
                icon: Icons.public,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrustTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTextField(
          controller: _headlineController,
          label: 'Headline',
          icon: Icons.subtitles_outlined,
          helperText: 'A short description of what you do',
          maxLength: 150,
        ),
        _buildTextField(
          controller: _bioController,
          label: 'About Me',
          icon: Icons.info_outline,
          maxLines: 4,
          maxLength: 2000,
        ),
        const SizedBox(height: 16),
        Text(
          'Portfolio & Links',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _linkedinController,
          label: 'LinkedIn Profile',
          icon: Icons.link,
          keyboardType: TextInputType.url,
          validator: (val) {
            if (val != null && val.trim().isNotEmpty) {
              final text = val.trim();
              if (!text.contains('linkedin.com') &&
                  !RegExp(r'^[\w\-_]+$').hasMatch(text)) {
                return 'Enter a valid LinkedIn URL or handle';
              }
            }
            return null;
          },
        ),
        _buildTextField(
          controller: _websiteController,
          label: 'Personal Website',
          icon: Icons.language,
          keyboardType: TextInputType.url,
          validator: (val) {
            if (val != null && val.trim().isNotEmpty) {
              final text = val.trim();
              final urlRegex = RegExp(
                r'^(https?:\/\/)?([\w\d\-_]+\.)+[\w\d\-_]+(\/.*)?$',
              );
              if (!urlRegex.hasMatch(text)) {
                return 'Enter a valid website URL';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRolePrivacyTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Role specifics
        if (_currentUser.role == 'farmer') ...[
          Text(
            'Farmer Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _businessNameController,
            label: 'Business/Farm Name',
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 24),
        ] else if (_currentUser.role == 'investor') ...[
          Text(
            'Investor Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _budgetRangeController,
            label: 'Expected Budget Range',
            icon: Icons.monetization_on_outlined,
            helperText: 'e.g. \$10,000 - \$50,000',
          ),
          const SizedBox(height: 24),
        ],

        Text(
          'Privacy Controls',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Discoverable in Marketplace'),
                subtitle: const Text('Let others find and view your profile'),
                value: _discoverable,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) => setState(() {
                  _discoverable = val;
                  _markUnsaved();
                }),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Show Contact Info'),
                subtitle: const Text(
                  'Make phone and email visible to connections',
                ),
                value: _showContactInfo,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) => setState(() {
                  _showContactInfo = val;
                  _markUnsaved();
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int? maxLength,
    String? helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          prefixIcon: maxLines == 1 ? Icon(icon) : null,
          suffixIcon: suffixIcon,
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
