import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/vet_controller.dart';
import '../auth/auth_wrapper.dart';
import '../profile/edit_profile_view.dart';

class VetProfileView extends StatefulWidget {
  const VetProfileView({super.key});

  @override
  State<VetProfileView> createState() => _VetProfileViewState();
}

class _VetProfileViewState extends State<VetProfileView> {
  final _bioController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _specialtyInputController = TextEditingController();

  List<String> _specialties = [];
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vc = context.read<VetController>();
      vc.fetchMyVetProfile().then((_) {
        if (mounted && vc.myProfile != null) {
          setState(() {
            _bioController.text = vc.myProfile!.bio;
            _workingHoursController.text = vc.myProfile!.workingHours;
            _specialties = List<String>.from(vc.myProfile!.specialties);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _workingHoursController.dispose();
    _specialtyInputController.dispose();
    super.dispose();
  }

  void _addSpecialty() {
    final value = _specialtyInputController.text.trim();
    if (value.isNotEmpty && !_specialties.contains(value)) {
      setState(() {
        _specialties.add(value);
        _specialtyInputController.clear();
      });
    }
  }

  void _removeSpecialty(String s) {
    setState(() => _specialties.remove(s));
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final vc = context.read<VetController>();
    final success = await vc.updateVetProfile(
      bio: _bioController.text.trim(),
      workingHours: _workingHoursController.text.trim(),
      specialties: _specialties,
    );
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(success ? Icons.check_circle : Icons.error, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(
            success ? 'Profile updated!' : 'Failed to update profile',
            style: const TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600),
          ),
        ]),
        backgroundColor: success ? const Color(0xFF15803D) : const Color(0xFFB45309),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'D';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final vc = context.watch<VetController>();
    final user = auth.currentUser;
    final profile = vc.myProfile;
    
    final mainSpecialty = (profile?.specialties.isNotEmpty == true) ? profile!.specialties.first : 'Veterinarian';
    final workingHours = profile?.workingHours.isNotEmpty == true ? profile!.workingHours : 'Hours not set';

    return Scaffold(
      backgroundColor: const Color(0xFF7C3AED),
      body: Column(
        children: [
          _buildHeroHeader(user?.name ?? 'Doctor', mainSpecialty, workingHours, user, profile, vc),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F5FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfessionalProfileCard(profile),
                      const SizedBox(height: 12),
                      _buildAccountCard(user),
                      const SizedBox(height: 12),
                      _buildLogOutButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(String name, String specialty, String workingHours, dynamic user, dynamic profile, VetController vc) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6D28D9).withValues(alpha: 0.4),
            ),
          ),
        ),
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4C1D95).withValues(alpha: 0.3),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => vc.uploadProfilePicture(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: (user != null && profile?.profileImageUrl != null && profile!.profileImageUrl.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: profile.profileImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _initials(name),
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: -4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Center(
                              child: Icon(Icons.camera_alt, color: Color(0xFF7C3AED), size: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Dr. $name',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 14, top: 3),
                    child: Text(
                      '$specialty • PawHealth Clinic',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              workingHours,
                              style: const TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF15803D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          specialty.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalProfileCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Professional Profile',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A0F2E),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isEditing = !_isEditing),
                child: Icon(_isEditing ? Icons.close : Icons.edit_outlined, color: const Color(0xFF7C3AED), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditing) ...[
            TextFormField(
              controller: _bioController,
              decoration: _editFieldDecoration('Bio / About'),
              style: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF1A0F2E)),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _workingHoursController,
              decoration: _editFieldDecoration('Working Hours'),
              style: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF1A0F2E)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Specialties',
              style: TextStyle(fontFamily: 'Figtree', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A0F2E)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specialties.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s, style: const TextStyle(fontFamily: 'Figtree', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeSpecialty(s),
                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                    ),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _specialtyInputController,
                    decoration: _editFieldDecoration('Add specialty...'),
                    style: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF1A0F2E)),
                    onSubmitted: (_) => _addSpecialty(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addSpecialty,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF7C3AED), size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bio',
                        style: TextStyle(fontFamily: 'Figtree', fontSize: 11, color: Color(0xFF9B8CB8)),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: profile?.bio ?? 'No bio provided.',
                          style: const TextStyle(fontFamily: 'Figtree', fontSize: 12, color: Color(0xFF1A0F2E), height: 1.5),
                          children: [
                            if ((profile?.bio ?? '').length > 100)
                              const TextSpan(text: ' Read more', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFEDE8F8), height: 1),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medical_services_outlined, color: Color(0xFF7C3AED), size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Specialties',
                        style: TextStyle(fontFamily: 'Figtree', fontSize: 11, color: Color(0xFF9B8CB8)),
                      ),
                      const SizedBox(height: 6),
                      if (profile?.specialties.isEmpty ?? true)
                        const Text('No specialties added', style: TextStyle(fontFamily: 'Figtree', fontSize: 12, color: Color(0xFF1A0F2E)))
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (profile?.specialties ?? []).map<Widget>((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(s, style: const TextStyle(fontFamily: 'Figtree', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _editFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF9B8CB8)),
      filled: true,
      fillColor: const Color(0xFFF7F5FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDE8F8))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDE8F8))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
    );
  }

  Widget _buildAccountCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A0F2E),
            ),
          ),
          const SizedBox(height: 4),
          _buildAccountRow(
            icon: Icons.person_outline,
            title: 'Edit Account Details',
            subtitle: 'Update name, phone number',
            showChevron: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileView())),
          ),
          const Divider(color: Color(0xFFEDE8F8), height: 1),
          _buildAccountRow(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: user?.email ?? '',
          ),
          const Divider(color: Color(0xFFEDE8F8), height: 1),
          _buildAccountRow(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: user?.phoneNumber ?? 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow({required IconData icon, required String title, required String subtitle, bool showChevron = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7C3AED), size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A0F2E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 11,
                      color: Color(0xFF9B8CB8),
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right, color: Color(0xFFC4B5FD), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await context.read<AuthController>().logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthWrapper()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, color: Colors.white, size: 16),
        label: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A0F2E),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
