import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../providers/diet_provider.dart';
import '../widgets/food_entry_tile.dart';
import '../widgets/summary_card.dart';
import 'add_entry_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? AppStrings.todayRecord : AppStrings.history,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppStrings.settings,
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildTodayView() : const HistoryScreen(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _openAddEntry(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: AppStrings.today,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: AppStrings.history,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    return Consumer<DietProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final record = provider.todayRecord;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                SummaryCard(
                  totalCalories: record.totalCalories,
                  totalProtein: record.totalProtein,
                  entryCount: record.entryCount,
                  calorieGoal: provider.calorieGoal,
                ),
                Expanded(
                  child: record.entries.isEmpty
                      ? Center(
                          child: Text(
                            AppStrings.noEntries,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: record.entries.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final entry = record.entries[index];
                            return FoodEntryTile(
                              entry: entry,
                              onDelete: () =>
                                  provider.deleteEntry(entry.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAddEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEntryScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}
