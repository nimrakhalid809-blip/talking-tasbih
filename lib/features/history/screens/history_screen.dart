import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(historyProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exportHistory() async {
    try {
      final csv = ref.read(historyProvider.notifier).exportCsv();
      await Share.share(
        csv,
        subject: 'Tasbih History Export',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export history')),
      );
    }
  }

  void _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(historyProvider.notifier).clearAllHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final filteredHistory = _searchQuery.isEmpty
        ? historyAsync
        : historyAsync.where((h) => h.zikrName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final settings = ref.watch(settingsProvider);

    return Semantics(
      label: 'Tasbih History screen',
      container: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasbih History'),
          actions: [
            Semantics(
              label: 'Export history as CSV',
              hint: 'Double tap to export history',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.download),
                onPressed: filteredHistory.isEmpty ? null : _exportHistory,
                tooltip: 'Export History',
              ),
            ),
            Semantics(
              label: 'Clear all history',
              hint: 'Double tap to clear all history',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: filteredHistory.isEmpty ? null : _confirmClearHistory,
                tooltip: 'Clear History',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(filteredHistory, settings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search History',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (v) {
          setState(() {
            _searchQuery = v;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Semantics(
      label: 'No history found',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Tasbih History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed tasbih sessions will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryModel> history, SettingsModel settings) {
    return Semantics(
      label: 'List of ${history.length} history items',
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: history.length,
        itemBuilder: (ctx, index) {
          final item = history[index];
          return _buildHistoryItem(item, settings);
        },
      ),
    );
  }

  Widget _buildHistoryItem(HistoryModel item, SettingsModel settings) {
    return Semantics(
      label: '${item.zikrName}, ${item.count} counts, ${item.targetCompleted ? 'Target completed' : ''}, ${item.target > 0 ? 'Target: ${item.target}' : ''}',
      button: false,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: InkWell(
            onLongPress: () => _confirmDeleteItem(item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.count.toString(),
                          style: TextStyle(
                            fontSize: settings.extraLargeText ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (item.target > 0)
                          Text(
                            '/${item.target}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.zikrName,
                          style: TextStyle(
                            fontSize: settings.extraLargeText ? 18 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(settings, item.completedAt),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            if (item.targetCompleted) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Target Complete',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      item.getFormattedDuration(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(SettingsModel settings, DateTime dateTime) {
    final language = settings.language;
    final dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    switch (language) {
      case AppLanguage.english:
        return '$dateStr $timeStr';
      case AppLanguage.urdu:
      case AppLanguage.arabic:
        return '$dateStr $timeStr';
    }
  }

  void _confirmDeleteItem(HistoryModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text(
          'Delete ${item.zikrName} (${item.count} counts)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(historyProvider.notifier).deleteHistory(item.id);
    }
  }
}
