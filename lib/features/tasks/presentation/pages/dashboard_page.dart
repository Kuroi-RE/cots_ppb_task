import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/route_names.dart';
import '../../../../core/design_system/colors.dart';
import '../../../../core/design_system/spacing.dart';
import '../../../../core/design_system/typography.dart';
import '../../data/models/task.dart';
import '../../state/task_provider.dart';
import '../widgets/status_chip.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Task Manager',
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

          return RefreshIndicator(
            onRefresh: () => taskProvider.refreshTasks(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text('Selamat Datang! 👋', style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Kelola tugas Anda dengan efisien',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Summary Cards
                  Text('Ringkasan Tugas', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.lg),

                  // Total Tasks Card
                  _buildSummaryCard(
                    context: context,
                    title: 'Total Tugas',
                    count: taskProvider.totalTasks,
                    icon: Icons.assignment_outlined,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.taskList);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Status Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusCard(
                          context: context,
                          title: 'Berjalan',
                          count: taskProvider.berjalaanCount,
                          icon: Icons.play_circle_outline,
                          color: AppColors.statusBerjalan,
                          backgroundColor: AppColors.statusBerjalaanBg,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatusCard(
                          context: context,
                          title: 'Selesai',
                          count: taskProvider.selesaiCount,
                          icon: Icons.check_circle_outline,
                          color: AppColors.statusSelesai,
                          backgroundColor: AppColors.statusSelesaiBg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildSummaryCard(
                    context: context,
                    title: 'Terlambat',
                    count: taskProvider.terlambatCount,
                    icon: Icons.warning_amber_outlined,
                    color: AppColors.statusTerlambat,
                    backgroundColor: AppColors.statusTerlambatBg,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Nearest Tasks Section
                  if (taskProvider.nearestTasks.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tugas Terdekat', style: AppTypography.h3),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RouteNames.taskList);
                          },
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...taskProvider.nearestTasks.map((task) {
                      return _buildNearestTaskCard(
                        context: context,
                        task: task,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.taskDetail,
                            arguments: task,
                          );
                        },
                      );
                    }),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],

                  // Quick Actions
                  Text('Aksi Cepat', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.lg),

                  _buildActionButton(
                    context: context,
                    title: 'Lihat Semua Tugas',
                    icon: Icons.list_alt,
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.taskList);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildActionButton(
                    context: context,
                    title: 'Tambah Tugas Baru',
                    icon: Icons.add_circle_outline,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.addTask);
                    },
                  ),
                ],
              ),
            ),
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

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, size: AppSpacing.iconXl, color: color),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      count.toString(),
                      style: AppTypography.h2.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppSpacing.iconSm,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppSpacing.iconLg, color: color),
            const SizedBox(height: AppSpacing.md),
            Text(
              count.toString(),
              style: AppTypography.h2.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(title, style: AppTypography.bodySmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppSpacing.iconLg,
                color: color ?? AppColors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.h4.copyWith(
                    color: color ?? AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: AppSpacing.iconSm,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearestTaskCard({
    required BuildContext context,
    required Task task,
    required VoidCallback onTap,
  }) {
    String formatDate(String dateStr) {
      try {
        final date = DateTime.parse(dateStr);
        final now = DateTime.now();
        final difference = date.difference(now).inDays;

        String relativeTime;
        if (difference < 0) {
          relativeTime = '${difference.abs()} hari yang lalu';
        } else if (difference == 0) {
          relativeTime = 'Hari ini';
        } else if (difference == 1) {
          relativeTime = 'Besok';
        } else {
          relativeTime = '$difference hari lagi';
        }

        final formattedDate = DateFormat('dd MMM yyyy', 'id_ID').format(date);
        return '$formattedDate ($relativeTime)';
      } catch (e) {
        return dateStr;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: AppTypography.h4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(status: task.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.book_outlined,
                    size: AppSpacing.iconSm,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      task.course,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: AppSpacing.iconSm,
                    color: task.status == 'TERLAMBAT'
                        ? AppColors.statusTerlambat
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      formatDate(task.deadline),
                      style: AppTypography.bodySmall.copyWith(
                        color: task.status == 'TERLAMBAT'
                            ? AppColors.statusTerlambat
                            : AppColors.textSecondary,
                        fontWeight: task.status == 'TERLAMBAT'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
