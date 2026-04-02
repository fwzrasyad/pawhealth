import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/vet_controller.dart';
import '../auth/login_view.dart';
import '../profile/edit_profile_view.dart';

class VetProfileView extends StatefulWidget {
  const VetProfileView({super.key});

  @override
  State<VetProfileView> createState() => _VetProfileViewState();
}

class _VetProfileViewState extends State<VetProfileView> {
  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

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
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          ),
        ]),
        backgroundColor: success ? _purple : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _purple, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final vc = context.watch<VetController>();
    final user = auth.currentUser;
    final profile = vc.myProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFF6B21A8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 3),
                        ),
                        child: Center(
                          child: Text(
                            _initials(user?.name ?? 'D'),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? 'Doctor',
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body Content ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Professional Info Card ─────────────────────────────
                  _SectionCard(
                    title: 'Professional Profile',
                    trailing: IconButton(
                      icon: Icon(_isEditing ? Icons.close : Icons.edit, color: _purple, size: 20),
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                    ),
                    children: [
                      if (_isEditing) ...[
                        // Bio field
                        TextFormField(
                          controller: _bioController,
                          decoration: _fieldDecoration('Bio / About', Icons.info_outline),
                          style: const TextStyle(fontFamily: 'Poppins'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Working hours
                        TextFormField(
                          controller: _workingHoursController,
                          decoration: _fieldDecoration('Working Hours', Icons.access_time),
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 16),

                        // Specialties editor
                        const Text('Specialties',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _specialties.map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _purple)),
                            backgroundColor: _lightPurple,
                            deleteIcon: const Icon(Icons.close, size: 16, color: _purple),
                            onDeleted: () => _removeSpecialty(s),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide.none,
                          )).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _specialtyInputController,
                                decoration: InputDecoration(
                                  hintText: 'Add specialty...',
                                  hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade400),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _purple, width: 2)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                                onSubmitted: (_) => _addSpecialty(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(12)),
                              child: IconButton(
                                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                                onPressed: _addSpecialty,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _purple,
                              disabledBackgroundColor: _lightPurple,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isSaving
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Save Changes',
                                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                          ),
                        ),
                      ] else ...[
                        // Display mode
                        _InfoRow(icon: Icons.info_outline, label: 'Bio', value: profile?.bio ?? 'Not set'),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.access_time, label: 'Working Hours', value: profile?.workingHours ?? 'Not set'),
                        const SizedBox(height: 12),
                        const Text('Specialties',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 8),
                        if (profile?.specialties.isEmpty ?? true)
                          Text('No specialties added yet',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade400))
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (profile?.specialties ?? []).map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: _lightPurple, borderRadius: BorderRadius.circular(20)),
                              child: Text(s, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: _purple)),
                            )).toList(),
                          ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Account Settings ─────────────────────────────────────
                  _SectionCard(
                    title: 'Account',
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Edit Account Details',
                        subtitle: 'Update name, phone number',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileView())),
                      ),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: user?.email ?? '',
                        enabled: false,
                      ),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _SettingsTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        subtitle: user?.phoneNumber ?? 'Not set',
                        enabled: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Logout ───────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context.read<AuthController>().logout();
                        if (context.mounted) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                      label: const Text('Log Out',
                          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({required this.title, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8A2BE2)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: const Color(0xFF8A2BE2)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black)),
                  Text(subtitle, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (enabled) const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
