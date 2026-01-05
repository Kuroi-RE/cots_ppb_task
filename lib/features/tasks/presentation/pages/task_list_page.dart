import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/route_names.dart';
import '../../../../core/design_system/colors.dart';
import '../../../../core/design_system/spacing.dart';
import '../../../../core/design_system/typography.dart';
import '../../state/task_provider.dart';
import '../widgets/task_card.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch tasks when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      if (provider.tasks.isEmpty) {
        provider.fetchTasks();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Daftar Tugas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<TaskProvider>().refreshTasks();
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.errorMessage.isNotEmpty &&
              taskProvider.tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Terjadi Kesalahan',
                      style: AppTypography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      taskProvider.errorMessage,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: () {
                        taskProvider.refreshTasks();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final displayTasks = taskProvider.filteredTasks;

          return Column(
            children: [
              // Search Bar
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    taskProvider.setSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari tugas berdasarkan judul, mata kuliah, atau catatan...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: taskProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              taskProvider.clearSearch();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),

              // Filter Tabs
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context: context,
                        label: 'Semua',
                        isSelected: taskProvider.selectedStatus == null,
                        onTap: () {
                          taskProvider.setSelectedStatus(null);
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(
                        context: context,
                        label: 'Berjalan',
                        isSelected: taskProvider.selectedStatus == 'BERJALAN',
                        onTap: () {
                          taskProvider.setSelectedStatus('BERJALAN');
                        },
                        color: AppColors.statusBerjalan,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(
                        context: context,
                        label: 'Selesai',
                        isSelected: taskProvider.selectedStatus == 'SELESAI',
                        onTap: () {
                          taskProvider.setSelectedStatus('SELESAI');
                        },
                        color: AppColors.statusSelesai,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(
                        context: context,
                        label: 'Terlambat',
                        isSelected: taskProvider.selectedStatus == 'TERLAMBAT',
                        onTap: () {
                          taskProvider.setSelectedStatus('TERLAMBAT');
                        },
                        color: AppColors.statusTerlambat,
                      ),
                    ],
                  ),
                ),
              ),

              // Task List
              Expanded(
                child: displayTasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                taskProvider.searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.inbox_outlined,
                                size: 80,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                taskProvider.searchQuery.isNotEmpty
                                    ? 'Tidak Ada Hasil'
                                    : 'Belum Ada Tugas',
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                taskProvider.searchQuery.isNotEmpty
                                    ? 'Tidak ada tugas yang cocok dengan pencarian Anda'
                                    : 'Tambahkan tugas pertama Anda',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => taskProvider.refreshTasks(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: displayTasks.length,
                          itemBuilder: (context, index) {
                            final task = displayTasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteNames.taskDetail,
                                  arguments: task,
                                );
                              },
                              onCheckChanged: (value) {
                                if (value != null && task.id != null) {
                                  taskProvider.toggleTaskCompletion(
                                    task.id!,
                                    value,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.addTask);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? (color ?? AppColors.primary) : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.buttonSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
