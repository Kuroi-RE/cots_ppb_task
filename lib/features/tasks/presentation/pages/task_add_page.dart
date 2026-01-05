import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system/colors.dart';
import '../../../../core/design_system/spacing.dart';
import '../../../../core/design_system/typography.dart';
import '../../data/models/task.dart';
import '../../state/task_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class TaskAddPage extends StatefulWidget {
  const TaskAddPage({super.key});

  @override
  State<TaskAddPage> createState() => _TaskAddPageState();
}

class _TaskAddPageState extends State<TaskAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedStatus = 'BERJALAN';
  bool _isDone = false;
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _deadlineController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  String _formatDeadlineForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal tenggat waktu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final task = Task(
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      deadline: _formatDeadlineForApi(_selectedDeadline!),
      status: _selectedStatus,
      note: _noteController.text.trim(),
      isDone: _isDone,
    );

    final provider = context.read<TaskProvider>();
    final success = await provider.addTask(task);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil ditambahkan'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
      // Refresh tasks
      provider.refreshTasks();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage.isNotEmpty
                ? provider.errorMessage
                : 'Gagal menambahkan tugas',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Tugas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  AppTextField(
                    label: 'Judul Tugas *',
                    hintText: 'Masukkan judul tugas',
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul tugas tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Course Field
                  AppTextField(
                    label: 'Mata Kuliah *',
                    hintText: 'Masukkan nama mata kuliah',
                    controller: _courseController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mata kuliah tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Deadline Field
                  AppTextField(
                    label: 'Tenggat Waktu *',
                    hintText: 'Pilih tanggal tenggat waktu',
                    controller: _deadlineController,
                    readOnly: true,
                    onTap: _selectDate,
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tenggat waktu tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Status Field
                  Text('Status *', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      color: AppColors.surface,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                        ),
                        style: AppTypography.bodyMedium,
                        items: const [
                          DropdownMenuItem(
                            value: 'BERJALAN',
                            child: Text('Berjalan'),
                          ),
                          DropdownMenuItem(
                            value: 'SELESAI',
                            child: Text('Selesai'),
                          ),
                          DropdownMenuItem(
                            value: 'TERLAMBAT',
                            child: Text('Terlambat'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Note Field
                  AppTextField(
                    label: 'Catatan (Opsional)',
                    hintText: 'Tambahkan catatan untuk tugas ini',
                    controller: _noteController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Is Done Checkbox
                  Card(
                    elevation: 2,
                    shadowColor: AppColors.shadow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: CheckboxListTile(
                      value: _isDone,
                      onChanged: (value) {
                        setState(() {
                          _isDone = value ?? false;
                        });
                      },
                      title: Text(
                        'Tandai sebagai selesai',
                        style: AppTypography.bodyMedium,
                      ),
                      subtitle: Text(
                        'Centang jika tugas sudah selesai',
                        style: AppTypography.bodySmall,
                      ),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Save Button
                  PrimaryButton(
                    text: 'Simpan Tugas',
                    icon: Icons.save_outlined,
                    onPressed: _saveTask,
                    isLoading: taskProvider.isLoading,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: taskProvider.isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTypography.button.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
