import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/medical_record_model.dart';
import '../../controllers/medical_record_controller.dart';

class AddMedicalRecordView extends StatefulWidget {
  const AddMedicalRecordView({super.key});

  @override
  State<AddMedicalRecordView> createState() => _AddMedicalRecordViewState();
}

class _AddMedicalRecordViewState extends State<AddMedicalRecordView> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  
  DateTime? _selectedDate;
  DateTime? _nextDueDate;
  bool _hasAttachment = false; // Mocking attachment state

  @override
  void dispose() {
    _diagnosisController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isNextDue) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8A2BE2),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isNextDue) {
          _nextDueDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      final controller = context.read<MedicalRecordController>();
      
      // Mock ID generation
      final String id = DateTime.now().millisecondsSinceEpoch.toString();

      final newRecord = MedicalRecord(
        recordId: id,
        petId: controller.mockPetId,
        vetId: 'vet_owner_added', 
        diagnosis: _diagnosisController.text,
        treatment: _treatmentController.text,
        vaccinationDate: _selectedDate,
        nextDueDate: _nextDueDate,
        attachmentUrl: _hasAttachment ? 'https://example.com/uploaded_file.pdf' : null,
      );

      controller.addRecord(newRecord);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Record added successfully!',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: const Color(0xFF8A2BE2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Add Medical Record',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Diagnosis / Title'),
              _buildTextField(
                controller: _diagnosisController,
                hint: 'e.g., Annual Checkup, Rabies Vaccine',
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              
              _buildLabel('Treatment / Notes'),
              _buildTextField(
                controller: _treatmentController,
                hint: 'Describe the treatment or notes...',
                maxLines: 4,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Date'),
                        GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: _buildDatePickerField(_selectedDate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Next Due Date'),
                        GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: _buildDatePickerField(_nextDueDate),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel('Attachment'),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasAttachment = !_hasAttachment;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: _hasAttachment 
                          ? const Color(0xFF8A2BE2).withValues(alpha: 0.1) 
                          : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasAttachment 
                          ? const Color(0xFF8A2BE2) 
                          : Colors.grey.shade300,
                      style: BorderStyle.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _hasAttachment ? Icons.check_circle : Icons.cloud_upload_outlined,
                        size: 40,
                        color: _hasAttachment ? const Color(0xFF8A2BE2) : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hasAttachment ? 'File Uploaded' : 'Tap to upload Document/Photo',
                        style: TextStyle(
                          color: _hasAttachment ? const Color(0xFF8A2BE2) : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A2BE2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Record',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF333333),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
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
          borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date != null ? DateFormat.yMMMd().format(date) : 'Select Date',
            style: TextStyle(
              color: date != null ? const Color(0xFF333333) : Colors.grey.shade400,
            ),
          ),
          Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
