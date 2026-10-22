import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/avatar_stack.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/data/mock_data.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../../domain/trip_entity.dart';
import '../../../itinerary/domain/itinerary_item_entity.dart';
import '../../../itinerary/presentation/providers/itinerary_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/domain/expense_entity.dart';
import '../../../packing/presentation/providers/packing_provider.dart';
import '../../../notes/presentation/providers/notes_provider.dart';
import '../../../voting/presentation/providers/voting_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    final user = ref.watch(currentUserProvider);

    final upcoming = trips.where((t) => t.isUpcoming).toList();
    final ongoing = trips.where((t) => t.isOngoing).toList();
    final past = trips.where((t) => t.isPast).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hey, ${user?.displayName.split(' ').first ?? 'Traveler'} 👋',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                          const SizedBox(height: 4),
                          Text(
                            'Where to next?',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1),
                        ],
                      ),
                    ),
                    // Theme Switcher Button
                    IconButton(
                      icon: Icon(
                        ref.watch(themeModeProvider) == ThemeMode.dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryCyan
                            : AppColors.primaryPurple,
                      ),
                      onPressed: () {
                        final current = ref.read(themeModeProvider);
                        ref.read(themeModeProvider.notifier).state =
                            current == ThemeMode.dark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                      },
                    ).animate(delay: 150.ms).fadeIn(),
                    
                    const SizedBox(width: 8),

                    // Profile avatar
                    GestureDetector(
                          onTap: () => _showProfileMenu(context, ref),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AppFormatters.initials(
                                  user?.displayName ?? '?',
                                ),
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate(delay: 200.ms)
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8)),
                  ],
                ),
              ),
            ),

            // ── Action Buttons ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        text: 'Create Trip',
                        icon: Icons.add_rounded,
                        height: 50,
                        onPressed: () => _showCreateTrip(context, ref),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showJoinTrip(context, ref),
                        icon: const Icon(Icons.group_add_rounded, size: 20),
                        label: const Text('Join Trip'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryCyan,
                          side: BorderSide(
                            color: AppColors.primaryCyan.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
            ),

            // ── Ongoing Trips ──
            if (ongoing.isNotEmpty) ...[
              _SectionHeader(title: '🔥 Happening Now', count: ongoing.length),
              _TripsList(trips: ongoing, delay: 400),
            ],

            // ── Upcoming Trips ──
            if (upcoming.isNotEmpty) ...[
              _SectionHeader(title: '✈️ Upcoming', count: upcoming.length),
              _TripsList(trips: upcoming, delay: 500),
            ],

            // ── Past Trips ──
            if (past.isNotEmpty) ...[
              _SectionHeader(title: '📸 Past Adventures', count: past.length),
              _TripsList(trips: past, delay: 600),
            ],

            // ── Empty State ──
            if (trips.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.flight_takeoff_rounded,
                  title: 'No trips yet',
                  subtitle:
                      'Create your first trip or join one with an invite code!',
                  actionLabel: 'Create Trip',
                  onAction: () => _showCreateTrip(context, ref),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final nameCtrl = TextEditingController(text: authState.user?.displayName ?? '');
    final emailCtrl = TextEditingController(text: authState.backupEmail ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings_outlined, color: AppColors.primaryPurple, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Profile & Backup Settings',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'e.g. Alex Traveler',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textPrimary
                      : AppColors.textPrimaryLight,
                ),
                decoration: const InputDecoration(
                  labelText: 'Backup Email',
                  hintText: 'your@email.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Provide your email address for cloud backup and account restoration purposes.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Save Profile',
                icon: Icons.save_rounded,
                isLoading: ref.watch(authProvider).isLoading,
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  await ref.read(authProvider.notifier).updateProfile(
                        nameCtrl.text.trim(),
                        emailCtrl.text.trim(),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile saved! 💾'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(authProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                label: Text(
                  authState.isDemo ? 'Exit Demo Mode' : 'Sign Out',
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTrip(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime startDate = DateTime.now().add(const Duration(days: 7));
    DateTime endDate = DateTime.now().add(const Duration(days: 10));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a Trip',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Trip Name',
                    hintText: 'e.g. Goa Beach Weekend',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: destCtrl,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'e.g. Goa, India',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Tell your friends what it\'s about',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setSheetState(() => startDate = picked);
                          }
                        },
                        child: _DateChip(label: 'Start', date: startDate),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setSheetState(() => endDate = picked);
                          }
                        },
                        child: _DateChip(label: 'End', date: endDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Create Trip',
                  icon: Icons.rocket_launch_rounded,
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty ||
                        destCtrl.text.trim().isEmpty) {
                      return;
                    }
                    ref
                        .read(tripsProvider.notifier)
                        .addTrip(
                          name: nameCtrl.text.trim(),
                          destination: destCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty
                              ? null
                              : descCtrl.text.trim(),
                          startDate: startDate,
                          endDate: endDate,
                        );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJoinTrip(BuildContext context, WidgetRef ref) {
    final codeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join a Trip',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-character invite code shared by your friend',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codeCtrl,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 8,
                ),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'ABC123',
                  hintStyle: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                    letterSpacing: 8,
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Join Trip',
                icon: Icons.group_add_rounded,
                onPressed: () {
                  if (codeCtrl.text.trim().length != 6) return;
                  try {
                    ref
                        .read(tripsProvider.notifier)
                        .joinTrip(codeCtrl.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Joined trip successfully! 🎉'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Trip not found: ${e.toString()}'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Row(
          children: [
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryCyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsList extends StatelessWidget {
  final List<TripEntity> trips;
  final int delay;

  const _TripsList({required this.trips, required this.delay});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TripCard(trip: trips[index]),
              )
              .animate(delay: Duration(milliseconds: delay + index * 80))
              .fadeIn()
              .slideY(begin: 0.1);
        }, childCount: trips.length),
      ),
    );
  }
}

class _TripCard extends ConsumerWidget {
  final TripEntity trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedTripProvider.notifier).state = trip;
        // Navigate using GoRouter - handled in router
        _navigateToTrip(context, trip.id);
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: trip.coverImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(trip.coverImageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.35),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: trip.coverImageUrl == null
              ? AppColors.primaryGradient
              : null,
        ),
        child: Stack(
          children: [
            // Glass overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trip.name,
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trip.destination,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppFormatters.dateRange(
                              trip.startDate,
                              trip.endDate,
                            ),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          AvatarStack(
                            size: 28,
                            overlap: 8,
                            avatars: trip.members
                                .map(
                                  (m) => AvatarData(
                                    name: m.user?.displayName ?? '?',
                                  ),
                                )
                                .toList(),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(trip).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _statusColor(
                                  trip,
                                ).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              _statusLabel(trip),
                              style: AppTypography.caption.copyWith(
                                color: _statusColor(trip),
                                fontWeight: FontWeight.w600,
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

            // Invite code badge
            Positioned(
              top: 12,
              right: 12,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                borderRadius: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trip.inviteCode,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTrip(BuildContext context, String tripId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: _TripDashboardWrapper(tripId: tripId),
          );
        },
      ),
    );
  }

  String _statusLabel(TripEntity trip) {
    if (trip.isOngoing) return 'Ongoing';
    if (trip.isUpcoming) return 'Upcoming';
    return 'Completed';
  }

  Color _statusColor(TripEntity trip) {
    if (trip.isOngoing) return AppColors.success;
    if (trip.isUpcoming) return AppColors.primaryCyan;
    return AppColors.textSecondary;
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime date;

  const _DateChip({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.dateShort(date),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Temporary wrapper to import the dashboard - will be replaced by GoRouter
class _TripDashboardWrapper extends StatelessWidget {
  final String tripId;
  const _TripDashboardWrapper({required this.tripId});

  @override
  Widget build(BuildContext context) {
    // Lazy import
    return _TripDashboard(tripId: tripId);
  }
}

class _TripDashboard extends ConsumerStatefulWidget {
  final String tripId;
  const _TripDashboard({required this.tripId});

  @override
  ConsumerState<_TripDashboard> createState() => _TripDashboardState();
}

class _TripDashboardState extends ConsumerState<_TripDashboard> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripByIdProvider(widget.tripId));
    if (trip == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: Text('Trip not found')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.name,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              trip.destination,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded),
            onPressed: () => _showMembers(context, trip),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showTripSettings(context, trip),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _ItineraryTab(tripId: widget.tripId),
          _ExpensesTab(tripId: widget.tripId),
          _PackingTab(tripId: widget.tripId),
          _NotesAndPollsTab(tripId: widget.tripId),
          _ChatTab(tripId: widget.tripId),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Icons.map_outlined, Icons.map_rounded, 'Itinerary'),
              _navItem(
                1,
                Icons.account_balance_wallet_outlined,
                Icons.account_balance_wallet_rounded,
                'Expenses',
              ),
              _navItem(
                2,
                Icons.luggage_outlined,
                Icons.luggage_rounded,
                'Packing',
              ),
              _navItem(
                3,
                Icons.sticky_note_2_outlined,
                Icons.sticky_note_2_rounded,
                'Notes',
              ),
              _navItem(
                4,
                Icons.chat_bubble_outline_rounded,
                Icons.chat_bubble_rounded,
                'Chat',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.primaryCyan
                  : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isSelected
                    ? AppColors.primaryCyan
                    : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMembers(BuildContext context, TripEntity trip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Members',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${trip.members.length}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryCyan,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Invite Code: ',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trip.inviteCode,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryCyan,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...trip.members.map(
              (m) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryPurple,
                  child: Text(
                    AppFormatters.initials(m.user?.displayName ?? '?'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                title: Text(
                  m.user?.displayName ?? 'Unknown',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: m.isAdmin
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Admin',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripSettings(BuildContext context, TripEntity trip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.edit_rounded,
                color: AppColors.textSecondary,
              ),
              title: Text(
                'Edit Trip',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.share_rounded,
                color: AppColors.textSecondary,
              ),
              title: Text(
                'Share Invite Code',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                trip.inviteCode,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryCyan,
                  letterSpacing: 2,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              title: Text(
                'Delete Trip',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
              ),
              onTap: () {
                ref.read(tripsProvider.notifier).deleteTrip(trip.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// TAB: ITINERARY
// ═══════════════════════════════════════════════

class _ItineraryTab extends ConsumerWidget {
  final String tripId;
  const _ItineraryTab({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itineraryProvider(tripId));
    final notifier = ref.read(itineraryProvider(tripId).notifier);
    final grouped = notifier.groupedByDate;

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.map_rounded,
        title: 'No itinerary yet',
        subtitle: 'Start planning your trip day-by-day!',
        actionLabel: 'Add Activity',
        onAction: () => _showAddActivity(context, ref),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final date = grouped.keys.elementAt(index);
            final dayItems = grouped[date]!;
            final dayNum = index + 1;

            return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day header
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Day $dayNum',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppFormatters.dateWithDay(date),
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Timeline items
                    ...dayItems.asMap().entries.map((entry) {
                      final item = entry.value;
                      final isLast = entry.key == dayItems.length - 1;
                      return _buildTimelineItem(item, isLast, context, ref);
                    }),
                  ],
                )
                .animate(delay: Duration(milliseconds: 100 * index))
                .fadeIn()
                .slideX(begin: 0.05);
          },
        ),
        // FAB
        Positioned(
          right: 16,
          bottom: 96,
          child: FloatingActionButton(
            heroTag: 'itinerary_fab',
            onPressed: () => _showAddActivity(context, ref),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    ItineraryItemEntity item,
    bool isLast,
    BuildContext context,
    WidgetRef ref,
  ) {
    final color = AppColors.getCategoryColor(item.category);
    final icon = AppColors.getCategoryIcon(item.category);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (item.startTime != null)
                        Text(
                          AppFormatters.timeFromTimeOfDay(
                            item.startTime!.hour,
                            item.startTime!.minute,
                          ),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (item.location != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.location!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddActivity(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String category = 'activity';
    final trip = ref.read(tripByIdProvider(tripId));
    DateTime selectedDate = trip?.startDate ?? DateTime.now();

    final categories = ['transport', 'stay', 'activity', 'food', 'other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Activity',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Activity Title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category selector
                Wrap(
                  spacing: 8,
                  children: categories.map((c) {
                    final isSelected = category == c;
                    return ChoiceChip(
                      label: Text(c[0].toUpperCase() + c.substring(1)),
                      selected: isSelected,
                      onSelected: (_) => setSheetState(() => category = c),
                      selectedColor: AppColors.getCategoryColor(
                        c,
                      ).withValues(alpha: 0.2),
                      avatar: Icon(
                        AppColors.getCategoryIcon(c),
                        size: 16,
                        color: AppColors.getCategoryColor(c),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: trip?.startDate ?? DateTime.now(),
                      lastDate:
                          trip?.endDate ??
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setSheetState(() => selectedDate = picked);
                    }
                  },
                  child: _DateChip(label: 'Date', date: selectedDate),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Add to Itinerary',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) {
                      return;
                    }
                    ref
                        .read(itineraryProvider(tripId).notifier)
                        .addItem(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim().isEmpty
                              ? null
                              : descCtrl.text.trim(),
                          location: locationCtrl.text.trim().isEmpty
                              ? null
                              : locationCtrl.text.trim(),
                          date: selectedDate,
                          category: category,
                        );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// TAB: EXPENSES
// ═══════════════════════════════════════════════

class _ExpensesTab extends ConsumerWidget {
  final String tripId;
  const _ExpensesTab({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider(tripId));
    final total = ref.watch(totalExpenseProvider(tripId));
    final balances = ref.watch(balancesProvider(tripId));
    final byCategory = ref.watch(expensesByCategoryProvider(tripId));

    if (expenses.isEmpty) {
      return EmptyState(
        icon: Icons.account_balance_wallet_rounded,
        title: 'No expenses yet',
        subtitle: 'Track shared expenses and see who owes whom!',
        actionLabel: 'Add Expense',
        onAction: () => _showAddExpense(context, ref),
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
          children: [
            // ── Total & Summary Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expenses',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.currency(total),
                      style: AppTypography.amountLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: byCategory.entries
                          .map(
                            (e) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${e.key[0].toUpperCase()}${e.key.substring(1)}: ${AppFormatters.currency(e.value)}',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
            ),

            const SizedBox(height: 16),

            // ── Paywise Pending Bills Slider ──
            _buildPendingBills(expenses),

            // ── Settlements ──
            if (balances.isNotEmpty) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Settlements Needed',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: balances.map(
                    (b) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                            child: Text(
                              AppFormatters.initials(b.fromUserName),
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.success.withValues(alpha: 0.15),
                            child: Text(
                              AppFormatters.initials(b.toUserName),
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${b.fromUserName.split(' ').first} owes ${b.toUserName.split(' ').first}',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Pending payment',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppFormatters.currency(b.amount),
                                style: AppTypography.amountSmall.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _confirmSettleDebt(context, ref, b),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'Settle Up',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],

            // ── Completed/All Expenses List ──
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Completed Bills',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: expenses.asMap().entries.map((entry) {
                  final e = entry.value;
                  return _buildCompletedBillItem(e)
                      .animate(delay: Duration(milliseconds: 40 * entry.key))
                      .fadeIn();
                }).toList(),
              ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 96,
          child: FloatingActionButton(
            heroTag: 'expense_fab',
            onPressed: () => _showAddExpense(context, ref),
            backgroundColor: AppColors.primaryPurple,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingBills(List<ExpenseEntity> expenses) {
    if (expenses.isEmpty) return const SizedBox.shrink();
    final pending = expenses.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Pending Bills',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 164,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final e = pending[index];
              final color = AppColors.getCategoryColor(e.category);
              
              final Gradient cardGradient;
              if (index % 3 == 0) {
                cardGradient = const LinearGradient(
                  colors: [Color(0xFF1E2640), Color(0xFF12182B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );
              } else if (index % 3 == 1) {
                cardGradient = const LinearGradient(
                  colors: [Color(0xFF5E5425), Color(0xFF2E2812)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );
              } else {
                cardGradient = const LinearGradient(
                  colors: [Color(0xFF0F3628), Color(0xFF071C14)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                );
              }

              return Container(
                width: 220,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: cardGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            e.category.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        Icon(
                          AppColors.getCategoryIcon(e.category),
                          color: color,
                          size: 18,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      e.title,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.currency(e.amount),
                      style: AppTypography.amountSmall.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMemberAvatars(e.splits.map((s) => s.userName).toList()),
                        Text(
                          '1 of ${e.splits.length} paid',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberAvatars(List<String> names) {
    final count = names.length;
    final displayCount = count > 3 ? 3 : count;
    
    return SizedBox(
      width: 60,
      height: 24,
      child: Stack(
        children: [
          for (int index = 0; index < displayCount; index++)
            Positioned(
              left: index * 12.0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLight,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    AppFormatters.initials(names[index]),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          if (count > 3)
            Positioned(
              left: 3 * 12.0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceBright,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+${count - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedBillItem(ExpenseEntity e) {
    final color = AppColors.getCategoryColor(e.category);
    final isPaidByMe = e.paidBy == MockData.currentUser.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppColors.getCategoryIcon(e.category),
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.white24,
                      child: Text(
                        AppFormatters.initials(e.paidByName),
                        style: const TextStyle(fontSize: 6, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 10, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      isPaidByMe ? 'Squad' : 'You',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(e.amount),
                style: AppTypography.amountSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPaidByMe
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaidByMe ? 'All Paid' : 'You Owe',
                  style: AppTypography.caption.copyWith(
                    color: isPaidByMe ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmSettleDebt(BuildContext context, WidgetRef ref, BalanceEntry balance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.handshake_outlined, color: AppColors.success, size: 24),
            const SizedBox(width: 8),
            Text(
              'Confirm Settlement',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record payment of ${AppFormatters.currency(balance.amount)} from ${balance.fromUserName} to ${balance.toUserName}?',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'This will mark this shared debt as settled.',
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(expensesProvider(tripId).notifier).settleDebt(
                    fromUserId: balance.fromUserId,
                    fromUserName: balance.fromUserName,
                    toUserId: balance.toUserId,
                    toUserName: balance.toUserName,
                    amount: balance.amount,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Settlement of ${AppFormatters.currency(balance.amount)} recorded! 💸'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );
  }

  void _showAddExpense(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final taxCtrl = TextEditingController(text: '0');
    final serviceCtrl = TextEditingController(text: '0');
    final discountCtrl = TextEditingController(text: '0');
    
    String category = 'food';
    final categories = [
      'food',
      'transport',
      'stay',
      'activity',
      'shopping',
      'other',
    ];
    final trip = ref.read(tripByIdProvider(tripId));
    final members = trip?.members ?? [];

    final selectedMemberIds = List<String>.from(members.map((m) => m.userId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          double baseAmount = double.tryParse(amountCtrl.text) ?? 0;
          double tax = double.tryParse(taxCtrl.text) ?? 0;
          double service = double.tryParse(serviceCtrl.text) ?? 0;
          double discount = double.tryParse(discountCtrl.text) ?? 0;

          double taxAmount = baseAmount * (tax / 100);
          double serviceAmount = baseAmount * (service / 100);
          double grandTotal = baseAmount + taxAmount + serviceAmount - discount;
          if (grandTotal < 0) grandTotal = 0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Split Bill',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Bill Name',
                      hintText: 'e.g. Supermarket, Belanja Bulanan',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    style: AppTypography.amountMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) => setSheetState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Base Amount',
                      prefixText: '₹ ',
                      prefixStyle: AppTypography.amountMedium.copyWith(
                        color: AppColors.primaryCyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (val) => setSheetState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Tax (%)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: serviceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (val) => setSheetState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Service (%)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: discountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (val) => setSheetState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Discount',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: categories.map((c) {
                      final isSelected = category == c;
                      final cColor = AppColors.getCategoryColor(c);
                      return ChoiceChip(
                        label: Text(c[0].toUpperCase() + c.substring(1)),
                        selected: isSelected,
                        onSelected: (_) => setSheetState(() => category = c),
                        selectedColor: cColor.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? cColor : AppColors.textSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Split With',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final m = members[index];
                        final isSelected = selectedMemberIds.contains(m.userId);
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                if (selectedMemberIds.length > 1) {
                                  selectedMemberIds.remove(m.userId);
                                }
                              } else {
                                selectedMemberIds.add(m.userId);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: isSelected
                                          ? AppColors.primaryPurple
                                          : AppColors.surfaceBright,
                                      child: Text(
                                        AppFormatters.initials(m.user?.displayName ?? ''),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: CircleAvatar(
                                          radius: 6,
                                          backgroundColor: AppColors.success,
                                          child: Icon(Icons.check, size: 8, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (m.user?.displayName ?? '').split(' ').first,
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildBillSummaryRow('Sub Total', baseAmount),
                        _buildBillSummaryRow('Tax', taxAmount),
                        _buildBillSummaryRow('Service', serviceAmount),
                        _buildBillSummaryRow('Discount', -discount),
                        const Divider(color: Colors.white10),
                        _buildBillSummaryRow('Grand Total', grandTotal, isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Save Changes',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty || grandTotal <= 0) return;
                      final authUser = ref.read(currentUserProvider);
                      final currentUserId = authUser?.id ?? MockData.currentUser.id;
                      final currentUserName = authUser?.displayName ?? MockData.currentUser.displayName;
                      ref
                          .read(expensesProvider(tripId).notifier)
                          .addExpense(
                            title: titleCtrl.text.trim(),
                            amount: grandTotal,
                            category: category,
                            paidBy: currentUserId,
                            paidByName: currentUserName,
                            splitAmong: selectedMemberIds,
                          );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillSummaryRow(String label, double val, {bool isTotal = false}) {
    final style = isTotal
        ? AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)
        : AppTypography.bodySmall.copyWith(color: AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            AppFormatters.currency(val),
            style: style.copyWith(
              color: isTotal ? AppColors.primaryCyan : (val < 0 ? AppColors.accent : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// TAB: PACKING
// ═══════════════════════════════════════════════

class _PackingTab extends ConsumerWidget {
  final String tripId;
  const _PackingTab({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(packingProvider(tripId));

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.luggage_rounded,
        title: 'Packing list is empty',
        subtitle: 'Add items and assign them to team members!',
        actionLabel: 'Add Item',
        onAction: () => _showAddItem(context, ref),
      );
    }

    final packed = items.where((i) => i.isPacked).length;
    final progress = items.isEmpty ? 0.0 : packed / items.length;

    // Group by category
    final grouped = <String, List>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // Progress Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Packing Progress',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$packed/${items.length}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primaryCyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceBright,
                      color: progress == 1.0
                          ? AppColors.success
                          : AppColors.primaryCyan,
                      minHeight: 6,
                    ),
                  ),
                  if (progress == 1.0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'All packed! Ready to go! 🎉',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Items by category
            ...grouped.entries.map((entry) {
              final catItems = entry.value;
              final emoji = _categoryEmoji(entry.key);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Text(
                      '$emoji ${entry.key[0].toUpperCase()}${entry.key.substring(1)}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ...catItems.map((item) => _packingTile(item, ref)),
                ],
              );
            }),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 96,
          child: FloatingActionButton(
            heroTag: 'packing_fab',
            onPressed: () => _showAddItem(context, ref),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  Widget _packingTile(dynamic item, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: AppColors.surfaceLight,
        leading: Checkbox(
          value: item.isPacked,
          onChanged: (_) =>
              ref.read(packingProvider(tripId).notifier).togglePacked(item.id),
        ),
        title: Text(
          item.itemName,
          style: AppTypography.bodyMedium.copyWith(
            color: item.isPacked
                ? AppColors.textTertiary
                : AppColors.textPrimary,
            decoration: item.isPacked ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: item.assignedToName != null
            ? Text(
                'Assigned to ${item.assignedToName}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            size: 18,
            color: AppColors.textTertiary,
          ),
          onPressed: () =>
              ref.read(packingProvider(tripId).notifier).removeItem(item.id),
        ),
      ),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat) {
      case 'clothing':
        return '👕';
      case 'toiletries':
        return '🧴';
      case 'electronics':
        return '📱';
      case 'documents':
        return '📄';
      case 'medicine':
        return '💊';
      case 'food':
        return '🍫';
      default:
        return '📦';
    }
  }

  void _showAddItem(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String category = 'other';
    final categories = [
      'clothing',
      'toiletries',
      'electronics',
      'documents',
      'medicine',
      'food',
      'other',
    ];

    String? assignedTo;
    String? assignedToName;
    final trip = ref.read(tripByIdProvider(tripId));
    final members = trip?.members ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Packing Item',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g. Warm Jacket, Sunscreen',
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories
                      .map(
                        (c) => ChoiceChip(
                          label: Text(
                            '${_categoryEmoji(c)} ${c[0].toUpperCase()}${c.substring(1)}',
                          ),
                          selected: category == c,
                          onSelected: (_) => setSheetState(() => category = c),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Assign To (Optional)',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Shared / Anyone'),
                        selected: assignedTo == null,
                        onSelected: (_) => setSheetState(() {
                          assignedTo = null;
                          assignedToName = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      ...members.map((m) {
                        final isAssigned = assignedTo == m.userId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(m.user?.displayName ?? 'Member'),
                            selected: isAssigned,
                            onSelected: (_) => setSheetState(() {
                              assignedTo = m.userId;
                              assignedToName = m.user?.displayName;
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Add Item',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    ref
                        .read(packingProvider(tripId).notifier)
                        .addItem(
                          itemName: nameCtrl.text.trim(),
                          category: category,
                          assignedTo: assignedTo,
                          assignedToName: assignedToName,
                        );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// TAB: NOTES & POLLS
// ═══════════════════════════════════════════════

class _NotesAndPollsTab extends ConsumerStatefulWidget {
  final String tripId;
  const _NotesAndPollsTab({required this.tripId});

  @override
  ConsumerState<_NotesAndPollsTab> createState() => _NotesAndPollsTabState();
}

class _NotesAndPollsTabState extends ConsumerState<_NotesAndPollsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '📝 Notes'),
            Tab(text: '🗳️ Polls'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _NotesView(tripId: widget.tripId),
              _PollsView(tripId: widget.tripId),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesView extends ConsumerWidget {
  final String tripId;
  const _NotesView({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider(tripId));

    if (notes.isEmpty) {
      return EmptyState(
        icon: Icons.sticky_note_2_rounded,
        title: 'No notes yet',
        subtitle: 'Share important info with your group!',
        actionLabel: 'Add Note',
        onAction: () => _showAddNote(context, ref),
      );
    }

    final pinned = notes.where((n) => n.isPinned).toList();
    final unpinned = notes.where((n) => !n.isPinned).toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            if (pinned.isNotEmpty) ...[
              Text(
                '📌 Pinned',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...pinned.map((n) => _noteCard(n, ref, context)),
            ],
            if (unpinned.isNotEmpty) ...[
              if (pinned.isNotEmpty) const SizedBox(height: 16),
              Text(
                'All Notes',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...unpinned.map((n) => _noteCard(n, ref, context)),
            ],
          ],
        ),
        Positioned(
          right: 16,
          bottom: 96,
          child: FloatingActionButton(
            heroTag: 'notes_fab',
            onPressed: () => _showAddNote(context, ref),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  Widget _noteCard(dynamic note, WidgetRef ref, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: note.isPinned
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  note.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  size: 18,
                  color: note.isPinned
                      ? AppColors.warning
                      : AppColors.textTertiary,
                ),
                onPressed: () =>
                    ref.read(notesProvider(tripId).notifier).togglePin(note.id),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            note.content,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                note.addedByName,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                AppFormatters.timeAgo(note.updatedAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddNote(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Note',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Hotel Booking Details',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Write your note here...',
                ),
                maxLines: 5,
                minLines: 3,
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Add Note',
                icon: Icons.add_rounded,
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty ||
                      contentCtrl.text.trim().isEmpty) {
                    return;
                  }
                  ref
                      .read(notesProvider(tripId).notifier)
                      .addNote(
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PollsView extends ConsumerWidget {
  final String tripId;
  const _PollsView({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polls = ref.watch(votingProvider(tripId));

    if (polls.isEmpty) {
      return EmptyState(
        icon: Icons.how_to_vote_rounded,
        title: 'No polls yet',
        subtitle: 'Create a poll to help the group decide!',
        actionLabel: 'Create Poll',
        onAction: () => _showCreatePoll(context, ref),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          poll.question,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (poll.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${poll.createdByName} • ${poll.totalVotes} votes',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...poll.options.map((option) {
                    final percentage = option.votePercentage(poll.totalVotes);
                    final hasVoted = option.votes.any(
                      (v) => v.userId == MockData.currentUser.id,
                    );

                    return GestureDetector(
                      onTap: poll.isActive
                          ? () => ref
                                .read(votingProvider(tripId).notifier)
                                .vote(poll.id, option.id)
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Stack(
                          children: [
                            // Background bar
                            Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceBright,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: hasVoted
                                      ? AppColors.primaryCyan.withValues(
                                          alpha: 0.4,
                                        )
                                      : AppColors.glassBorder,
                                ),
                              ),
                            ),
                            // Fill bar
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: hasVoted
                                      ? AppColors.primaryCyan.withValues(
                                          alpha: 0.15,
                                        )
                                      : AppColors.primaryPurple.withValues(
                                          alpha: 0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            // Content
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  if (hasVoted) ...[
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: AppColors.primaryCyan,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Expanded(
                                    child: Text(
                                      option.optionText,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: hasVoted
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(percentage * 100).toInt()}%',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn();
          },
        ),
        Positioned(
          right: 16,
          bottom: 96,
          child: FloatingActionButton(
            heroTag: 'polls_fab',
            onPressed: () => _showCreatePoll(context, ref),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  void _showCreatePoll(BuildContext context, WidgetRef ref) {
    final questionCtrl = TextEditingController();
    final optionCtrls = [TextEditingController(), TextEditingController()];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Poll',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: questionCtrl,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    hintText: 'What should we do?',
                  ),
                ),
                const SizedBox(height: 12),
                ...optionCtrls.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: e.value,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Option ${e.key + 1}',
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setSheetState(
                    () => optionCtrls.add(TextEditingController()),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Option'),
                ),
                const SizedBox(height: 16),
                GradientButton(
                  text: 'Create Poll',
                  icon: Icons.how_to_vote_rounded,
                  onPressed: () {
                    if (questionCtrl.text.trim().isEmpty) return;
                    final options = optionCtrls
                        .map((c) => c.text.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();
                    if (options.length < 2) return;
                    ref
                        .read(votingProvider(tripId).notifier)
                        .createPoll(
                          question: questionCtrl.text.trim(),
                          options: options,
                        );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// TAB: CHAT
// ═══════════════════════════════════════════════

class _ChatTab extends ConsumerStatefulWidget {
  final String tripId;
  const _ChatTab({required this.tripId});

  @override
  ConsumerState<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<_ChatTab> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider(widget.tripId).notifier).sendMessage(text);
    _messageCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider(widget.tripId));

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? EmptyState(
                  icon: Icons.chat_bubble_rounded,
                  title: 'No messages yet',
                  subtitle: 'Start a conversation with your trip crew!',
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final currentUserId = ref.watch(currentUserProvider)?.id ?? MockData.currentUser.id;
                    final isMe = msg.userId == currentUserId;
                    final isSystem = msg.isSystem;

                    if (isSystem) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg.content,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primaryPurple,
                              child: Text(
                                AppFormatters.initials(msg.userName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColors.primaryPurple
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Text(
                                      msg.userName,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.primaryCyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  Text(
                                    msg.content,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: isMe
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppFormatters.timeAgo(msg.createdAt),
                                    style: AppTypography.caption.copyWith(
                                      color: isMe
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : AppColors.textTertiary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        // Message input
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            8,
            MediaQuery.of(context).padding.bottom + 88,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageCtrl,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: IconButton(
                  onPressed: _send,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
