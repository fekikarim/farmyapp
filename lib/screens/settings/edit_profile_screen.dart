import 'dart:async';
import 'dart:io';

import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _usernameDebounce;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  bool _isLoadingProfile = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isUploadingCover = false;
  bool _hasUnsavedChanges = false;
  bool _isHydrating = false;
  String? _loadError;
  String? _syncWarning;
  int _completenessScore = 0;

  XFile? _pendingAvatar;
  XFile? _pendingCover;
  User? _currentUser;
  String _originalUsername = '';

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _websiteController = TextEditingController();
  final _farmPageController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _farmLocationsController = TextEditingController();
  final _productionTypesController = TextEditingController();
  final _workforceSizeController = TextEditingController();
  final _preferredHiringTypesController = TextEditingController();
  final _investmentFocusController = TextEditingController();
  final _budgetRangeController = TextEditingController();
  final _riskProfileController = TextEditingController();
  final _preferredRegionsController = TextEditingController();
  final _involvementLevelController = TextEditingController();

  bool _discoverable = true;
  bool _showContactInfo = false;

  List<TextEditingController> get _allControllers => [
    _nameController,
    _usernameController,
    _phoneController,
    _countryController,
    _cityController,
    _headlineController,
    _bioController,
    _linkedinController,
    _websiteController,
    _farmPageController,
    _businessNameController,
    _farmLocationsController,
    _productionTypesController,
    _workforceSizeController,
    _preferredHiringTypesController,
    _investmentFocusController,
    _budgetRangeController,
    _riskProfileController,
    _preferredRegionsController,
    _involvementLevelController,
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
    _attachListeners();
    _hydrateFromProvider();
    _fetchLiveProfile();
  }

  void _attachListeners() {
    _usernameController.addListener(_onUsernameChanged);
    for (final controller in _allControllers.where(
      (c) => c != _usernameController,
    )) {
      controller.addListener(_markUnsaved);
    }
  }

  void _hydrateFromProvider() {
    final user = context.read<AuthProvider>().user;
    if (user != null) _hydrateFromUser(user, resetUnsaved: true);
  }

  Future<void> _fetchLiveProfile({bool userInitiated = false}) async {
    setState(() {
      _isLoadingProfile = _currentUser == null;
      if (userInitiated) _syncWarning = null;
    });

    try {
      final updatedUser = await AuthService.fetchProfile();
      if (!mounted) return;
      if (updatedUser == null) {
        throw Exception(AppLocalizations.of(context)!.profileLoadError);
      }

      context.read<AuthProvider>().setUser(updatedUser);
      if (_hasUnsavedChanges) {
        setState(() {
          _currentUser = updatedUser;
          _completenessScore =
              updatedUser.profile?.completenessScore ?? _estimateCompleteness();
          _syncWarning =
              'Latest profile synced. Your unsaved edits were kept locally.';
          _isLoadingProfile = false;
        });
      } else {
        _hydrateFromUser(updatedUser, resetUnsaved: true);
        setState(() => _isLoadingProfile = false);
      }
      _entryController.forward();
    } catch (e) {
      if (!mounted) return;
      final message = _friendlyError(
        e,
        AppLocalizations.of(context)!.profileLoadError,
      );
      setState(() {
        _isLoadingProfile = false;
        if (_currentUser == null) {
          _loadError = message;
        } else {
          _syncWarning = message;
        }
      });
      _entryController.forward();
    }
  }

  void _hydrateFromUser(User user, {required bool resetUnsaved}) {
    final profile = user.profile;
    _isHydrating = true;
    _currentUser = user;
    _originalUsername = profile?.username ?? '';
    _setText(_nameController, profile?.name);
    _setText(_usernameController, profile?.username);
    _setText(_phoneController, user.phone);
    _setText(_countryController, profile?.country);
    _setText(_cityController, profile?.city);
    _setText(_headlineController, profile?.headline);
    _setText(_bioController, profile?.bio);
    _setText(_linkedinController, profile?.linkedin);
    _setText(_websiteController, profile?.website);
    _setText(_farmPageController, profile?.farmPage);
    _setText(_businessNameController, profile?.businessName);
    _setText(_farmLocationsController, _joinList(profile?.farmLocations));
    _setText(_productionTypesController, _joinList(profile?.productionTypes));
    _setText(_workforceSizeController, profile?.workforceSize);
    _setText(
      _preferredHiringTypesController,
      _joinList(profile?.preferredHiringTypes),
    );
    _setText(_investmentFocusController, _joinList(profile?.investmentFocus));
    _setText(_budgetRangeController, profile?.budgetRange);
    _setText(_riskProfileController, profile?.riskProfile);
    _setText(_preferredRegionsController, _joinList(profile?.preferredRegions));
    _setText(_involvementLevelController, profile?.involvementLevel);
    _discoverable = profile?.discoverable ?? true;
    _showContactInfo = profile?.showContactInfo ?? false;
    _completenessScore = profile?.completenessScore ?? _estimateCompleteness();
    _isUsernameAvailable = _originalUsername.isNotEmpty ? true : null;
    _loadError = null;
    if (resetUnsaved) {
      _hasUnsavedChanges = false;
      _syncWarning = null;
    }
    _isHydrating = false;
  }

  void _setText(TextEditingController controller, String? value) {
    final next = value ?? '';
    if (controller.text != next) controller.text = next;
  }

  void _onUsernameChanged() {
    _markUnsaved();
    final username = _sanitizeUsername(_usernameController.text);

    if (username.isEmpty ||
        username.length < 3 ||
        username == _originalUsername) {
      _usernameDebounce?.cancel();
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable =
            username == _originalUsername && username.isNotEmpty ? true : null;
      });
      return;
    }

    if (!RegExp(r'^[a-z0-9._-]{3,30}$').hasMatch(username)) {
      _usernameDebounce?.cancel();
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = null;
      });
      return;
    }

    _usernameDebounce?.cancel();
    _usernameDebounce = Timer(const Duration(milliseconds: 550), () async {
      if (!mounted) return;
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
        if (mounted) {
          setState(() {
            _isUsernameAvailable = null;
            _isCheckingUsername = false;
          });
        }
      }
    });
  }

  void _markUnsaved() {
    if (_isHydrating) return;
    final score = _estimateCompleteness();
    if (!_hasUnsavedChanges || _completenessScore != score) {
      setState(() {
        _hasUnsavedChanges = true;
        _completenessScore = score;
      });
    }
  }

  int _estimateCompleteness() {
    final values = [
      _nameController.text,
      _usernameController.text,
      _phoneController.text,
      _countryController.text,
      _cityController.text,
      _headlineController.text,
      _bioController.text,
      _currentUser?.profile?.picture,
      _currentUser?.profile?.coverImage,
    ];
    final filled = values
        .where((value) => (value ?? '').trim().isNotEmpty)
        .length;
    return ((filled / values.length) * 100).round().clamp(0, 100);
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _entryController.dispose();
    _scrollController.dispose();
    for (final controller in _allControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges || _isSaving) return true;
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final user = _currentUser;
    if (user == null) return;

    if (_isCheckingUsername) {
      _showSnack(l10n.waitUsernameCheck, isError: false);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      _showSnack(l10n.correctErrorsInForm, isError: true);
      return;
    }
    if (_isUsernameAvailable == false) {
      _showSnack(l10n.usernameTaken, isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final updates = _buildSanitizedPayload(user.role);
      final updatedUser = await AuthService.updateProfile(updates);
      if (!mounted) return;
      if (updatedUser == null)
        throw Exception('Profile was not updated. Please try again.');

      context.read<AuthProvider>().setUser(updatedUser);
      _hydrateFromUser(updatedUser, resetUnsaved: true);
      setState(() => _isSaving = false);
      _showSnack(l10n.profileUpdatedSuccess, isError: false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack(_friendlyError(e, l10n.profileLoadError), isError: true);
    }
  }

  Map<String, dynamic> _buildSanitizedPayload(String role) {
    final profile = <String, dynamic>{
      'name': _emptyToNull(_sanitizeText(_nameController.text, maxLength: 100)),
      'username': _emptyToNull(_sanitizeUsername(_usernameController.text)),
      'country': _emptyToNull(
        _sanitizeText(_countryController.text, maxLength: 100),
      ),
      'city': _emptyToNull(_sanitizeText(_cityController.text, maxLength: 100)),
      'headline': _emptyToNull(
        _sanitizeText(_headlineController.text, maxLength: 150),
      ),
      'bio': _emptyToNull(
        _sanitizeText(_bioController.text, maxLength: 2000, multiline: true),
      ),
      'portfolio_links': {
        'linkedin': _normalizeLinkedIn(_linkedinController.text),
        'website': _normalizeWebsite(_websiteController.text),
        'farm_page': _normalizeWebsite(_farmPageController.text),
      },
      'privacy_settings': {
        'discoverable': _discoverable,
        'show_contact_info': _showContactInfo,
      },
    };

    if (role.toLowerCase() == 'farmer') {
      profile['farmer_details'] = {
        'business_name': _emptyToNull(
          _sanitizeText(_businessNameController.text, maxLength: 100),
        ),
        'farm_locations': _csvToList(_farmLocationsController.text),
        'production_types': _csvToList(_productionTypesController.text),
        'workforce_size': _emptyToNull(
          _sanitizeText(_workforceSizeController.text, maxLength: 80),
        ),
        'preferred_hiring_types': _csvToList(
          _preferredHiringTypesController.text,
        ),
      };
    }

    if (role.toLowerCase() == 'investor') {
      profile['investor_details'] = {
        'investment_focus': _csvToList(_investmentFocusController.text),
        'budget_range': _emptyToNull(
          _sanitizeText(_budgetRangeController.text, maxLength: 80),
        ),
        'risk_profile': _emptyToNull(
          _sanitizeText(_riskProfileController.text, maxLength: 80),
        ),
        'preferred_regions': _csvToList(_preferredRegionsController.text),
        'involvement_level': _emptyToNull(
          _sanitizeText(_involvementLevelController.text, maxLength: 80),
        ),
      };
    }

    return {
      'phone': _emptyToNull(_sanitizePhone(_phoneController.text)),
      'profile': profile,
    };
  }

  Future<void> _pickAndUploadImage({required bool cover}) async {
    if (_isSaving || _isUploadingAvatar || _isUploadingCover) return;
    final l10n = AppLocalizations.of(context)!;
    final source = await _showImageSourceSheet(cover: cover);
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: cover ? 1800 : 1200,
        maxHeight: cover ? 1000 : 1200,
        imageQuality: cover ? 86 : 88,
      );
      if (picked == null) return;

      setState(() {
        if (cover) {
          _pendingCover = picked;
          _isUploadingCover = true;
        } else {
          _pendingAvatar = picked;
          _isUploadingAvatar = true;
        }
      });

      await AuthService.uploadProfilePicture(
        picked,
        type: cover ? 'cover' : 'picture',
      );
      await _syncAfterMediaUpload();
      if (!mounted) return;
      _showSnack(
        cover ? 'Cover image updated.' : l10n.profilePictureUpdated,
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (cover) _pendingCover = null;
        if (!cover) _pendingAvatar = null;
      });
      _showSnack(
        l10n.uploadFailed(_friendlyError(e, 'Upload failed')),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          if (cover) _isUploadingCover = false;
          if (!cover) _isUploadingAvatar = false;
        });
      }
    }
  }

  Future<void> _syncAfterMediaUpload() async {
    final updatedUser = await AuthService.fetchProfile();
    if (!mounted || updatedUser == null) return;
    context.read<AuthProvider>().setUser(updatedUser);
    setState(() {
      _currentUser = updatedUser;
      _completenessScore =
          updatedUser.profile?.completenessScore ?? _estimateCompleteness();
      _pendingAvatar = null;
      _pendingCover = null;
    });
    if (!_hasUnsavedChanges) _hydrateFromUser(updatedUser, resetUnsaved: true);
  }

  Future<ImageSource?> _showImageSourceSheet({required bool cover}) {
    final theme = Theme.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                cover
                    ? 'Update cover image'
                    : AppLocalizations.of(context)!.changeProfilePicture,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _sourceTile(
                Icons.photo_library_rounded,
                AppLocalizations.of(context)!.chooseFromGallery,
                ImageSource.gallery,
              ),
              _sourceTile(
                Icons.photo_camera_rounded,
                AppLocalizations.of(context)!.takeAPhoto,
                ImageSource.camera,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceTile(IconData icon, String label, ImageSource source) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () => Navigator.pop(context, source),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_hasUnsavedChanges && !_isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            l10n.editProfileTitle,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          actions: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _hasUnsavedChanges
                  ? TextButton(
                      key: const ValueKey('save-action'),
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.saveChangesTooltip),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty-action')),
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_isLoadingProfile)
              _buildLoadingState(theme)
            else if (_loadError != null && _currentUser == null)
              _buildErrorState(theme)
            else
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                          children: [
                            _buildMediaHeader(theme),
                            const SizedBox(height: 18),
                            if (_syncWarning != null) ...[
                              _buildInlineWarning(theme, _syncWarning!),
                              const SizedBox(height: 14),
                            ],
                            _buildCompletenessCard(theme),
                            const SizedBox(height: 18),
                            _buildPersonalSection(theme),
                            const SizedBox(height: 18),
                            _buildProfessionalSection(theme),
                            const SizedBox(height: 18),
                            _buildSocialSection(theme),
                            const SizedBox(height: 18),
                            _buildPrivacySection(theme),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_isSaving) _buildSavingOverlay(theme),
          ],
        ),
        bottomNavigationBar: _buildBottomSaveBar(theme),
      ),
    );
  }

  Widget _buildMediaHeader(ThemeData theme) {
    final user = _currentUser;
    final profile = user?.profile;
    final name = _nameController.text.trim().isEmpty
        ? 'Farmy Member'
        : _nameController.text.trim();
    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCoverPreview(theme, profile),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.14),
                    Colors.black.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: _mediaButton(
                label: _isUploadingCover ? 'Uploading…' : 'Change cover',
                icon: Icons.wallpaper_rounded,
                busy: _isUploadingCover,
                onTap: () => _pickAndUploadImage(cover: true),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildAvatarPreview(theme, profile, name),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: InkWell(
                          onTap: () => _pickAndUploadImage(cover: false),
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: _isUploadingAvatar
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _headlineController.text.trim().isEmpty
                              ? 'Build trust with a complete Farmy profile'
                              : _headlineController.text.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.84),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPreview(ThemeData theme, UserProfile? profile) {
    if (_pendingCover != null)
      return Image.file(File(_pendingCover!.path), fit: BoxFit.cover);
    final url =
        _resolveAssetUrl(profile?.coverImage) ??
        _resolveAssetUrl(profile?.picture);
    if (url != null)
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _gradientCover(theme),
      );
    return _gradientCover(theme);
  }

  Widget _gradientCover(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.primary,
            const Color(0xFFB8C56A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildAvatarPreview(
    ThemeData theme,
    UserProfile? profile,
    String name,
  ) {
    final url = _resolveAssetUrl(profile?.picture);
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.28),
      ),
      child: ClipOval(
        child: _pendingAvatar != null
            ? Image.file(File(_pendingAvatar!.path), fit: BoxFit.cover)
            : url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(theme, name),
              )
            : _avatarFallback(theme, name),
      ),
    );
  }

  Widget _avatarFallback(ThemeData theme, String name) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _mediaButton({
    required String label,
    required IconData icon,
    required bool busy,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletenessCard(ThemeData theme) {
    return _sectionCard(
      theme,
      title: AppLocalizations.of(context)!.profileCompleteness,
      icon: Icons.insights_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$_completenessScore%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Complete profiles build trust and improve marketplace visibility.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _completenessScore / 100,
              minHeight: 10,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.14,
              ),
              valueColor: AlwaysStoppedAnimation(
                _completenessScore >= 90
                    ? Colors.green
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalSection(ThemeData theme) {
    final compact = MediaQuery.sizeOf(context).width < 560;
    return _sectionCard(
      theme,
      title: 'Personal Information',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: AppLocalizations.of(context)!.fullName,
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            maxLength: 100,
            validator: _validateName,
          ),
          _buildTextField(
            controller: _usernameController,
            label: AppLocalizations.of(context)!.usernameLabel,
            icon: Icons.alternate_email_rounded,
            helperText: AppLocalizations.of(context)!.publicUniqueHandle,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]')),
            ],
            validator: _validateUsername,
            suffixIcon: _buildUsernameStatusIcon(),
          ),
          _buildTextField(
            controller: _phoneController,
            label: AppLocalizations.of(context)!.phoneNumber,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
          compact
              ? Column(
                  children: [
                    _buildTextField(
                      controller: _countryController,
                      label: AppLocalizations.of(context)!.countryLabel,
                      icon: Icons.public_rounded,
                      maxLength: 100,
                    ),
                    _buildTextField(
                      controller: _cityController,
                      label: AppLocalizations.of(context)!.cityLabel,
                      icon: Icons.location_city_rounded,
                      maxLength: 100,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _countryController,
                        label: AppLocalizations.of(context)!.countryLabel,
                        icon: Icons.public_rounded,
                        maxLength: 100,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: AppLocalizations.of(context)!.cityLabel,
                        icon: Icons.location_city_rounded,
                        maxLength: 100,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection(ThemeData theme) {
    final role = _currentUser?.role.toLowerCase() ?? 'user';
    return _sectionCard(
      theme,
      title: role == 'investor'
          ? AppLocalizations.of(context)!.investorDetailsTitle
          : 'Professional / Farmer Details',
      icon: Icons.eco_rounded,
      child: Column(
        children: [
          _buildTextField(
            controller: _headlineController,
            label: AppLocalizations.of(context)!.headlineLabel,
            icon: Icons.subtitles_rounded,
            helperText: AppLocalizations.of(context)!.headlineHint,
            maxLength: 150,
            validator: _validateHeadline,
          ),
          _buildTextField(
            controller: _bioController,
            label: AppLocalizations.of(context)!.aboutMe,
            icon: Icons.notes_rounded,
            maxLines: 5,
            maxLength: 2000,
            validator: _validateBio,
          ),
          if (role == 'farmer') ...[
            _buildTextField(
              controller: _businessNameController,
              label: AppLocalizations.of(context)!.businessFarmName,
              icon: Icons.storefront_rounded,
              maxLength: 100,
            ),
            _buildTextField(
              controller: _farmLocationsController,
              label: 'Farm locations',
              icon: Icons.map_rounded,
              helperText: 'Separate multiple values with commas.',
            ),
            _buildTextField(
              controller: _productionTypesController,
              label: 'Production types',
              icon: Icons.grass_rounded,
              helperText: 'Example: vegetables, trees, dairy',
            ),
            _buildTextField(
              controller: _workforceSizeController,
              label: 'Workforce size',
              icon: Icons.groups_rounded,
              maxLength: 80,
            ),
            _buildTextField(
              controller: _preferredHiringTypesController,
              label: 'Preferred hiring types',
              icon: Icons.handshake_rounded,
              helperText: 'Separate multiple values with commas.',
            ),
          ],
          if (role == 'investor') ...[
            _buildTextField(
              controller: _investmentFocusController,
              label: 'Investment focus',
              icon: Icons.trending_up_rounded,
              helperText: 'Separate multiple values with commas.',
            ),
            _buildTextField(
              controller: _budgetRangeController,
              label: AppLocalizations.of(context)!.expectedBudgetRange,
              icon: Icons.monetization_on_rounded,
              helperText: AppLocalizations.of(context)!.budgetRangeHint,
              maxLength: 80,
            ),
            _buildTextField(
              controller: _riskProfileController,
              label: 'Risk profile',
              icon: Icons.shield_rounded,
              maxLength: 80,
            ),
            _buildTextField(
              controller: _preferredRegionsController,
              label: 'Preferred regions',
              icon: Icons.travel_explore_rounded,
              helperText: 'Separate multiple values with commas.',
            ),
            _buildTextField(
              controller: _involvementLevelController,
              label: 'Involvement level',
              icon: Icons.manage_accounts_rounded,
              maxLength: 80,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialSection(ThemeData theme) {
    return _sectionCard(
      theme,
      title: AppLocalizations.of(context)!.portfolioLinks,
      icon: Icons.link_rounded,
      child: Column(
        children: [
          _buildTextField(
            controller: _linkedinController,
            label: AppLocalizations.of(context)!.linkedinProfile,
            icon: Icons.work_outline_rounded,
            keyboardType: TextInputType.url,
            validator: _validateLinkedIn,
          ),
          _buildTextField(
            controller: _websiteController,
            label: AppLocalizations.of(context)!.personalWebsite,
            icon: Icons.language_rounded,
            keyboardType: TextInputType.url,
            validator: _validateWebsite,
          ),
          _buildTextField(
            controller: _farmPageController,
            label: 'Farm page',
            icon: Icons.agriculture_rounded,
            keyboardType: TextInputType.url,
            validator: _validateWebsite,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(ThemeData theme) {
    return _sectionCard(
      theme,
      title: AppLocalizations.of(context)!.privacyControls,
      icon: Icons.privacy_tip_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            theme,
            title: AppLocalizations.of(context)!.discoverableMarketplace,
            subtitle: AppLocalizations.of(context)!.discoverableSubtitle,
            value: _discoverable,
            onChanged: (value) {
              setState(() => _discoverable = value);
              _markUnsaved();
            },
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            theme,
            title: AppLocalizations.of(context)!.showContactInfoLabel,
            subtitle: AppLocalizations.of(context)!.showContactInfoSubtitle,
            value: _showContactInfo,
            onChanged: (value) {
              setState(() => _showContactInfo = value);
              _markUnsaved();
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.72)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        inputFormatters: inputFormatters,
        textInputAction: maxLines > 1
            ? TextInputAction.newline
            : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          prefixIcon: maxLines == 1
              ? Icon(icon)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 84),
                  child: Icon(icon),
                ),
          suffixIcon: suffixIcon,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }

  Widget? _buildUsernameStatusIcon() {
    if (_isCheckingUsername) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final username = _sanitizeUsername(_usernameController.text);
    if (username.isEmpty || username == _originalUsername) return null;
    if (_isUsernameAvailable == true)
      return const Icon(Icons.check_circle_rounded, color: Colors.green);
    if (_isUsernameAvailable == false)
      return const Icon(Icons.error_rounded, color: Colors.redAccent);
    return null;
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      activeThumbColor: theme.colorScheme.primary,
      activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.28),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildInlineWarning(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSaveBar(ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: child,
      ),
      child: _hasUnsavedChanges && !_isLoadingProfile
          ? SafeArea(
              key: const ValueKey('save-bar'),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Unsaved profile changes',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          AppLocalizations.of(context)!.saveChangesTooltip,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('no-save-bar')),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: CircularProgressIndicator(color: theme.colorScheme.primary),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.profileLoadError,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _loadError ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => _fetchLiveProfile(userInitiated: true),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingOverlay(ThemeData theme) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.08),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(width: 14),
                const Text('Saving profile…'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppLocalizations.of(context)!.nameRequired;
    if (text.length < 2) return AppLocalizations.of(context)!.nameTooShort;
    if (text.length > 100) return 'Name must be under 100 characters.';
    if (!RegExp(r"^[\p{L} .'-]+$", unicode: true).hasMatch(text))
      return AppLocalizations.of(context)!.onlyLettersAllowed;
    return null;
  }

  String? _validateUsername(String? value) {
    final text = _sanitizeUsername(value ?? '');
    if (text.isEmpty) return AppLocalizations.of(context)!.usernameRequired;
    if (text.length < 3) return AppLocalizations.of(context)!.tooShortMin3;
    if (!RegExp(r'^[a-z0-9._-]{3,30}$').hasMatch(text))
      return AppLocalizations.of(context)!.usernameFormatError;
    if (_isUsernameAvailable == false)
      return AppLocalizations.of(context)!.usernameTaken;
    return null;
  }

  String? _validatePhone(String? value) {
    final text = _sanitizePhone(value ?? '');
    if (text.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(text))
      return AppLocalizations.of(context)!.invalidPhoneFormat;
    return null;
  }

  String? _validateHeadline(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 150) return 'Headline must be 150 characters or less.';
    if (_containsUnsafeMarkup(text))
      return 'Please remove unsupported characters.';
    return null;
  }

  String? _validateBio(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > 2000) return 'Bio must be 2000 characters or less.';
    if (_containsUnsafeMarkup(text))
      return 'Please remove unsupported characters.';
    return null;
  }

  String? _validateLinkedIn(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final url = _normalizeLinkedIn(text);
    if (url == null ||
        !RegExp(
          r'^https://([a-z]{2,3}\.)?linkedin\.com/(in|company)/[A-Za-z0-9._%-]+/?$',
        ).hasMatch(url)) {
      return AppLocalizations.of(context)!.linkedinUrlError;
    }
    return null;
  }

  String? _validateWebsite(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final url = _normalizeWebsite(text);
    if (url == null) return AppLocalizations.of(context)!.websiteUrlError;
    return null;
  }

  String _sanitizeText(
    String input, {
    required int maxLength,
    bool multiline = false,
  }) {
    final normalized = input
        .replaceAll(RegExp(r'[<>]'), '')
        .replaceAll(RegExp(multiline ? r'[ \t]+' : r'\s+'), ' ')
        .trim();
    return normalized.length > maxLength
        ? normalized.substring(0, maxLength)
        : normalized;
  }

  String _sanitizeUsername(String input) =>
      input.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '');
  String _sanitizePhone(String input) =>
      input.trim().replaceAll(RegExp(r'[^0-9+]'), '');
  bool _containsUnsafeMarkup(String input) => RegExp(r'[<>]').hasMatch(input);
  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  String? _normalizeLinkedIn(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if (RegExp(r'^[A-Za-z0-9._%-]+$').hasMatch(trimmed))
      return 'https://linkedin.com/in/$trimmed';
    return _normalizeWebsite(trimmed, requireLinkedIn: true);
  }

  String? _normalizeWebsite(String value, {bool requireLinkedIn = false}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';
    final uri = Uri.tryParse(candidate);
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty)
      return null;
    if (requireLinkedIn && !uri.host.toLowerCase().contains('linkedin.com'))
      return null;
    return uri.toString();
  }

  List<String> _csvToList(String value) => value
      .split(',')
      .map((item) => _sanitizeText(item, maxLength: 80))
      .where((item) => item.isNotEmpty)
      .take(12)
      .toList();
  String _joinList(List<String>? values) =>
      values?.where((value) => value.trim().isNotEmpty).join(', ') ?? '';

  String? _resolveAssetUrl(String? rawPath) {
    final path = rawPath?.trim();
    if (path == null || path.isEmpty) return null;
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme)
      return uri.scheme == 'http' || uri.scheme == 'https' ? path : null;
    final base = AuthService.baseUrl.endsWith('/')
        ? AuthService.baseUrl.substring(0, AuthService.baseUrl.length - 1)
        : AuthService.baseUrl;
    return path.startsWith('/') ? '$base$path' : '$base/$path';
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String _friendlyError(Object error, String fallback) {
    final raw = error
        .toString()
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .trim();
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') || lower.contains('connection'))
      return 'Unable to reach Farmy. Please check your connection and try again.';
    if (lower.contains('username already'))
      return AppLocalizations.of(context)!.usernameTaken;
    if (lower.contains('validation'))
      return AppLocalizations.of(context)!.correctErrorsInForm;
    return raw.isEmpty ? fallback : raw;
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
