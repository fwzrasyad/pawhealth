import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pet_controller.dart';
import '../../models/health_journal_model.dart';
import 'package:intl/intl.dart';

class HealthJournalFormView extends StatefulWidget {
  final String petId;

  const HealthJournalFormView({super.key, required this.petId});

  @override
  State<HealthJournalFormView> createState() => _HealthJournalFormViewState();
}

class _HealthJournalFormViewState extends State<HealthJournalFormView> {
  static const _purple = Color(0xFF8A2BE2);
  static const _availableSymptoms = [
    'Lethargic',
    'Vomiting',
    'Diarrhea',
    'Normal Appetite',
    'Loss of Appetite',
    'Wound Healing',
    'Limping',
    'Coughing',
    'Sneezing',
    'Scratching',
  ];

  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late Set<String> _selectedSymptoms;
  late String _observations;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedSymptoms = {};
    _observations = '';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newEntry = HealthJournalEntry(
        id: 'hj_${DateTime.now().millisecondsSinceEpoch}',
        petId: widget.petId,
        date: _selectedDate,
        symptomTags: _selectedSymptoms.toList(),
        observations: _observations.trim(),
      );

      final petController = Provider.of<PetController>(context, listen: false);
      await petController.addHealthJournalEntry(widget.petId, newEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Health journal entry saved successfully!',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            ),
            backgroundColor: _purple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Add Health Journal Entry',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Picker
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.calendar_today, size: 18, color: _purple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    child: Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Symptom Tags Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_hospital_outlined, size: 18, color: _purple),
                        const SizedBox(width: 8),
                        const Text(
                          'Symptoms',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableSymptoms.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom);
                        return FilterChip(
                          label: Text(
                            symptom,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.add(symptom);
                              } else {
                                _selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                          backgroundColor: const Color(0xFFF8F9FA),
                          selectedColor: _purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              color: Color(0xFFE0E0E0),
                              width: 1,
                            ),
                          ),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Observations TextField
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notes_outlined, size: 18, color: _purple),
                        const SizedBox(width: 8),
                        const Text(
                          'Observations',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Describe any specific observations about your pet\'s health and recovery progress...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _purple, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      onSaved: (value) => _observations = value ?? '',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe your observations';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
