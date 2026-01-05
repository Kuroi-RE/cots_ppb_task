import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/design_system/colors.dart';
import '../../../../core/design_system/spacing.dart';
import '../../../../core/design_system/typography.dart';
import '../../data/models/task.dart';
import '../../state/task_provider.dart';
import '../widgets/status_chip.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _noteController;
  bool _isEditingNote = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.task.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _saveNote() async {
    if (widget.task.id == null) return;

    final provider = context.read<TaskProvider>();
    final success = await provider.updateTaskNote(
      widget.task.id!,
      _noteController.text,
    );

    if (success && mounted) {
      setState(() {
        _isEditingNote = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil disimpan'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage.isNotEmpty
                ? provider.errorMessage
                : 'Gagal menyimpan catatan',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleCompletion(bool isDone) async {
    if (widget.task.id == null) return;

    final provider = context.read<TaskProvider>();
    final success = await provider.toggleTaskCompletion(
      widget.task.id!,
      isDone,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isDone
                ? 'Tugas ditandai sebagai selesai'
                : 'Tugas ditandai belum selesai',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage.isNotEmpty
                ? provider.errorMessage
                : 'Gagal mengubah status',
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
          'Detail Tugas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // Find the updated task from provider
          final updatedTask = taskProvider.tasks.firstWhere(
            (t) => t.id == widget.task.id,
            orElse: () => widget.task,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                Text('Judul Tugas', style: AppTypography.label),
                const SizedBox(height: AppSpacing.sm),
                Text(updatedTask.title, style: AppTypography.h3),
                const SizedBox(height: AppSpacing.xxl),

                // Course Section
                _buildDetailRow(
                  icon: Icons.book_outlined,
                  label: 'Mata Kuliah',
                  value: updatedTask.course,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Deadline Section
                _buildDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tenggat Waktu',
                  value: _formatDate(updatedTask.deadline),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Status Section
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: AppSpacing.iconMd,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Status', style: AppTypography.label),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                StatusChip(status: updatedTask.status),
                const SizedBox(height: AppSpacing.xxl),

                // Completion Toggle Section
                Card(
                  elevation: 2,
                  shadowColor: AppColors.shadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Penyelesaian',
                                style: AppTypography.h4,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                updatedTask.isDone
                                    ? 'Tugas sudah selesai'
                                    : 'Tugas belum selesai',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: updatedTask.isDone,
                          onChanged: taskProvider.isLoading
                              ? null
                              : (value) {
                                  _toggleCompletion(value);
                                },
                          activeThumbColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Note Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Catatan', style: AppTypography.h4),
                    if (!_isEditingNote)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditingNote = true;
                          });
                        },
                        icon: const Icon(Icons.edit, size: AppSpacing.iconSm),
                        label: const Text('Edit'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                if (_isEditingNote)
                  Column(
                    children: [
                      TextField(
                        controller: _noteController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Tulis catatan...',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.borderFocus,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: taskProvider.isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _noteController.text = updatedTask.note;
                                        _isEditingNote = false;
                                      });
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: taskProvider.isLoading
                                  ? null
                                  : _saveNote,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              child: taskProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Simpan',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      updatedTask.note.isEmpty
                          ? 'Belum ada catatan'
                          : updatedTask.note,
                      style: AppTypography.bodyMedium.copyWith(
                        color: updatedTask.note.isEmpty
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xxl),

                // Created and Updated Info
                if (updatedTask.createdAt != null)
                  _buildInfoRow('Dibuat', _formatDate(updatedTask.createdAt!)),
                if (updatedTask.updatedAt != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _buildInfoRow(
                    'Diperbarui',
                    _formatDate(updatedTask.updatedAt!),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSpacing.iconMd, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: AppTypography.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.bodySmall),
      ],
    );
  }
}
