import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/job_request_model.dart';
import '../../../providers/job_request_provider.dart';
import '../../../providers/land_provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class PostJobModal extends StatefulWidget {
  final String? initialLandId;

  const PostJobModal({super.key, this.initialLandId});

  @override
  State<PostJobModal> createState() => _PostJobModalState();
}

class _PostJobModalState extends State<PostJobModal> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedLandId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _durationController = TextEditingController();
  final _taskTypeController = TextEditingController();
  final List<String> _skills = [];
  final _skillController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedLandId = widget.initialLandId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _durationController.dispose();
    _taskTypeController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLandId == null) {
      _showError(AppLocalizations.of(context)!.selectLandError);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final job = JobRequest(
        id: '',
        farmerId: '',
        landId: _selectedLandId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requiredSkills: _skills,
        salary: double.tryParse(_salaryController.text),
        duration: _durationController.text.trim(),
        taskType: _taskTypeController.text.trim(),
        status: JobRequestStatus.open,
      );

      final success = await context.read<JobRequestProvider>().createJobRequest(job);
      
      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.jobPostedSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error = context.read<JobRequestProvider>().error;
        _showError(error ?? 'Failed to post job request');
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final landProvider = context.watch<LandProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: bottomInset + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.postNewJob,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle(AppLocalizations.of(context)!.selectLand),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLandId,
                decoration: _buildInputDecoration(
                  hint: AppLocalizations.of(context)!.selectLand,
                  prefixIcon: Icons.landscape_outlined,
                ),
                dropdownColor: Theme.of(context).cardColor,
                items: landProvider.myLands.map((land) {
                  return DropdownMenuItem(
                    value: land.id,
                    child: Text(land.name, style: const TextStyle(fontSize: 15)),
                  );
                }).toList(),
                validator: (val) => val == null ? AppLocalizations.of(context)!.selectLandError : null,
                onChanged: (val) => setState(() => _selectedLandId = val),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle(AppLocalizations.of(context)!.jobTitle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration(
                  hint: 'e.g. Senior Harvester',
                  prefixIcon: Icons.work_outline,
                ),
                style: const TextStyle(fontSize: 15),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter a title';
                  if (val.length < 3) return 'Title too short';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildSectionTitle(AppLocalizations.of(context)!.description),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _buildInputDecoration(
                  hint: 'Describe the tasks and expectations...',
                ),
                style: const TextStyle(fontSize: 15),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter a description';
                  if (val.length < 10) return 'Description must be at least 10 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(AppLocalizations.of(context)!.salaryTND),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _salaryController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                            hint: '0.00',
                            prefixIcon: Icons.payments_outlined,
                          ),
                          style: const TextStyle(fontSize: 15),
                          validator: (val) {
                            if (val != null && val.isNotEmpty) {
                              final price = double.tryParse(val);
                              if (price == null || price <= 0) return 'Invalid amount';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(AppLocalizations.of(context)!.duration),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durationController,
                          decoration: _buildInputDecoration(
                            hint: 'e.g. 2 weeks',
                            prefixIcon: Icons.timer_outlined,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSectionTitle(AppLocalizations.of(context)!.taskType),
              const SizedBox(height: 8),
              TextFormField(
                controller: _taskTypeController,
                decoration: _buildInputDecoration(
                  hint: 'e.g. Harvesting, Irrigation',
                  prefixIcon: Icons.category_outlined,
                ),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle(AppLocalizations.of(context)!.requiredSkills),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillController,
                      decoration: _buildInputDecoration(
                        hint: AppLocalizations.of(context)!.addSkillHint,
                      ),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _addSkill,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) => Chip(
                  label: Text(skill, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  onDeleted: () => setState(() => _skills.remove(skill)),
                  backgroundColor: Colors.green.withOpacity(0.1),
                  deleteIconColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.green.withOpacity(0.2)),
                )).toList(),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.postJob,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, IconData? prefixIcon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: Colors.green) : null,
      filled: true,
      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
