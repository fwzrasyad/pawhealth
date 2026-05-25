import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../controllers/pet_controller.dart';
import '../../models/daily_routine_model.dart';
import 'package:intl/intl.dart';

class DailyRoutineFormView extends StatefulWidget {
  final String petId;

  const DailyRoutineFormView({super.key, required this.petId});

  @override
  State<DailyRoutineFormView> createState() => _DailyRoutineFormViewState();
}

class _DailyRoutineFormViewState extends State<DailyRoutineFormView> {
  final _formKey = GlobalKey<FormState>();
  
  late double _weight;
  String _dietNotes = '';
  String _activityLevel = 'Moderate';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final petController = Provider.of<PetController>(context, listen: false);
    final pet = petController.pets.firstWhere((p) => p.petId == widget.petId);
    _weight = pet.weight;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newLog = DailyRoutineLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        petId: widget.petId,
        date: _selectedDate,
        weight: _weight,
        dietNotes: _dietNotes,
        activityLevel: _activityLevel,
      );

      final petController = Provider.of<PetController>(context, listen: false);
      await petController.addDailyRoutineLog(widget.petId, newLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily routine saved successfully!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context); // Go back to profile view
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: Text('Log Daily Routine', style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Picker Simulation (Just a styled container for visual)
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                TextFormField(
                  initialValue: _weight.toString(),
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter weight';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                  onSaved: (value) => _weight = double.parse(value!),
                ),

                const SizedBox(height: 20),
                
                DropdownButtonFormField<String>(
                  initialValue: _activityLevel,
                  decoration: InputDecoration(
                    labelText: 'Activity Level',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  items: ['Low', 'Moderate', 'High Activity'].map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _activityLevel = val);
                  },
                  onSaved: (value) => _activityLevel = value!,
                ),

                SizedBox(height: 20),
                
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Diet Notes',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter some diet notes';
                    return null;
                  },
                  onSaved: (value) => _dietNotes = value!,
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    final petController = Provider.of<PetController>(context, listen: false);
                    if(petController.isLoading) return;
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Consumer<PetController>(
                    builder: (context, controller, child) {
                      return controller.isLoading
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text('Save Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
                    },
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