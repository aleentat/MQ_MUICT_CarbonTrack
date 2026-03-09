import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/eating_diary_entry.dart';
import '../models/shopping_diary_entry.dart';
import '../models/travel_diary_entry.dart';
import '../models/waste_diary_entry.dart';

class CarbonDiaryPage extends StatefulWidget {
  @override
  _CarbonDiaryPageState createState() => _CarbonDiaryPageState();
}

enum DiaryViewMode { today, week, month }

// future extend
enum StickerSource { emoji, file, asset }

class DiarySticker {
  final String value;
  final StickerSource source;

  const DiarySticker._({required this.value, required this.source});

  factory DiarySticker.asset(String path) {
    return DiarySticker._(value: path, source: StickerSource.asset);
  }
}

class UnifiedDiaryEntry {
  final DateTime timestamp;
  final dynamic entry;
  final String type;

  UnifiedDiaryEntry({
    required this.timestamp,
    required this.entry,
    required this.type,
  });
}

class _CarbonDiaryPageState extends State<CarbonDiaryPage> {
  List<UnifiedDiaryEntry> _combinedEntries = [];
  DateTime _selectedDay = DateTime.now();
  DiaryViewMode _viewMode = DiaryViewMode.today;
  String _monthFilter = 'all';

  final Map<String, DiarySticker> _stickersByDay = {};
  final Map<String, String> _notesByDay = {};

  static const double _weekDayCellAspectRatio = 1;
  static const double _monthDayCellAspectRatio = 1;
  static const EdgeInsets _monthContainerMargin = EdgeInsets.symmetric(horizontal: 2, vertical: 2);
  static const double _monthContainerPadding = 4;
  static const double _categoryCardSpacing = 2;

  static const List<String> _stickerImageOptions = [
    'assets/images/stickers/catsticker1.png',
    'assets/images/stickers/catsticker2.png',
    'assets/images/stickers/catsticker3.png',
    'assets/images/stickers/catsticker4.png',
    'assets/images/stickers/catsticker5.png',
    'assets/images/stickers/catsticker6.png',
    'assets/images/stickers/catsticker7.png',
    'assets/images/stickers/catsticker8.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final waste = await DBHelper.instance.getAllWasteDiaryEntries();
    final travel = await DBHelper.instance.getAllTravelDiaryEntries();
    final eating = await DBHelper.instance.getAllEatingDiaryEntries();
    final shopping = await DBHelper.instance.getAllShoppingDiaryEntries();

    final combined = <UnifiedDiaryEntry>[
      ...waste.map(
        (e) =>
            UnifiedDiaryEntry(timestamp: e.timestamp, entry: e, type: 'waste'),
      ),
      ...travel.map(
        (e) =>
            UnifiedDiaryEntry(timestamp: e.timestamp, entry: e, type: 'travel'),
      ),
      ...eating.map(
        (e) =>
            UnifiedDiaryEntry(timestamp: e.timestamp, entry: e, type: 'eating'),
      ),
      ...shopping.map(
        (e) => UnifiedDiaryEntry(
          timestamp: e.timestamp,
          entry: e,
          type: 'shopping',
        ),
      ),
    ];

    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() => _combinedEntries = combined);
  }

  String _dayKey(DateTime day) => DateFormat('y-MM-dd').format(day);

  List<UnifiedDiaryEntry> _entriesForDay(DateTime day, {String? filter}) {
    final target = _dayKey(day);
    return _combinedEntries.where((entry) {
      final isSameDay = _dayKey(entry.timestamp) == target;
      final matchesFilter =
          filter == null || filter == 'all' || entry.type == filter;
      return isSameDay && matchesFilter;
    }).toList();
  }

  List<DateTime> _daysForCurrentMode() {
    final dateOnly = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    if (_viewMode == DiaryViewMode.today) return [dateOnly];

    if (_viewMode == DiaryViewMode.week) {
      final weekStart = dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
      return List.generate(7, (i) => weekStart.add(Duration(days: i)));
    }

    final monthStart = DateTime(dateOnly.year, dateOnly.month, 1);
    final monthEnd = DateTime(dateOnly.year, dateOnly.month + 1, 0);
    final leading = monthStart.weekday % 7;
    final daysInMonth = monthEnd.day;

    return [
      ...List.generate(
        leading,
        (i) => monthStart.subtract(Duration(days: leading - i)),
      ),
      ...List.generate(
        daysInMonth,
        (i) => DateTime(dateOnly.year, dateOnly.month, i + 1),
      ),
    ];
  }

  Color _categoryColor(String type) {
    if (type == 'waste') return const Color(0xFFD9F3DD);
    if (type == 'travel') return const Color(0xFFD9EFFF);
    if (type == 'eating') return const Color.fromARGB(255, 233, 226, 210);
    return const Color(0xFFFDE7D4);
  }

  IconData _categoryIcon(String type) {
    if (type == 'waste') return Icons.recycling;
    if (type == 'travel') return Icons.directions_car;
    if (type == 'eating') return Icons.restaurant_menu;
    return Icons.shopping_bag;
  }

  double _stickerSizeForView() {
    if (_viewMode == DiaryViewMode.today) return 170;
    if (_viewMode == DiaryViewMode.week) return 50;
    return 26;
  }

  double _entryTextSizeForView() {
    if (_viewMode == DiaryViewMode.today) return 15;
    if (_viewMode == DiaryViewMode.week) return 11;
    return 9;
  }

  int _entryLimitForView() {
    if (_viewMode == DiaryViewMode.today) return 5; // X
    if (_viewMode == DiaryViewMode.week) return 3;
    return 2; // X
  }

  Future<void> _showStickerSelector(DateTime day) async {
    if (_viewMode == DiaryViewMode.month) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._stickerImageOptions.map(
                  (assetPath) => InkWell(
                    onTap: () {
                      setState(() {
                        _stickersByDay[_dayKey(day)] = DiarySticker.asset(
                          assetPath,
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(assetPath, fit: BoxFit.contain),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _stickersByDay.remove(_dayKey(day)));
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.blueGrey,
                  ),
                  label: const Text(
                    'Remove sticker',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showNoteEditor() async {
    final key = _dayKey(_selectedDay);
    final initialNote = _notesByDay[key] ?? '';
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        var draftNote = initialNote;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Additional note',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: initialNote,
                minLines: 3,
                maxLines: 6,
                onChanged: (value) => draftNote = value,
                decoration: const InputDecoration(
                  hintText: 'Write your note for today...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, draftNote.trim());
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {
      if (result == null || result.isEmpty) {
        _notesByDay.remove(key);
      } else {
        _notesByDay[key] = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 155, 255, 242),
            Color.fromARGB(255, 183, 255, 236),
            Color.fromARGB(255, 230, 252, 252),
            Color(0xFFFDFDFD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Carbon Diary',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
          actions: [
            IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: 'Export DB',
              onPressed: () async {
                await DBHelper.instance.exportDatabase();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database exported')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildViewChoice(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTodayHeader(),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPeriodHeader(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDiaryGrid(),
              ),
            ),
            if (_viewMode == DiaryViewMode.today) _buildTodayNoteSection(),
            const SizedBox(height: 25),
            if (_viewMode == DiaryViewMode.month) ...[
              _buildMonthFilterChips(),
              const SizedBox(height: 8),
              Expanded(child: _buildMonthSelectedDateCards()),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHeader() {
    final now = DateTime.now();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Today: ${DateFormat('EEE, d MMM y').format(now)}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildViewChoice() {
    const selectedColor = Color.fromARGB(255, 41, 132, 127);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _viewModeButton('Today', DiaryViewMode.today, selectedColor),
          _viewModeButton('Week', DiaryViewMode.week, selectedColor),
          _viewModeButton('Month', DiaryViewMode.month, selectedColor),
        ],
      ),
    );
  }

  Widget _viewModeButton(String text, DiaryViewMode mode, Color selectedColor) {
    final isSelected = _viewMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodHeader() {
    String title;
    final d = _selectedDay;
    if (_viewMode == DiaryViewMode.today) {
      title = DateFormat('EEE, d MMM y').format(d);
    } else if (_viewMode == DiaryViewMode.week) {
      final start = d.subtract(Duration(days: d.weekday - 1));
      final end = start.add(const Duration(days: 6));
      title =
          '${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(end)}';
    } else {
      title = DateFormat('MMMM y').format(d);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (_viewMode == DiaryViewMode.today) {
                    _selectedDay = _selectedDay.subtract(
                      const Duration(days: 1),
                    );
                  } else if (_viewMode == DiaryViewMode.week) {
                    _selectedDay = _selectedDay.subtract(
                      const Duration(days: 7),
                    );
                  } else {
                    _selectedDay = DateTime(
                      _selectedDay.year,
                      _selectedDay.month - 1,
                      1,
                    );
                  }
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_viewMode == DiaryViewMode.today) {
                    _selectedDay = _selectedDay.add(const Duration(days: 1));
                  } else if (_viewMode == DiaryViewMode.week) {
                    _selectedDay = _selectedDay.add(const Duration(days: 7));
                  } else {
                    _selectedDay = DateTime(
                      _selectedDay.year,
                      _selectedDay.month + 1,
                      1,
                    );
                  }
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiaryGrid() {
    if (_viewMode == DiaryViewMode.today) {
      return _buildTodayDiaryList(_selectedDay);
    }

    final days = _daysForCurrentMode();
    final columns = _viewMode == DiaryViewMode.week ? 2 : 7;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          if (_viewMode == DiaryViewMode.month)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
              child: Row(
                children:
                    const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map(
                          (d) => Expanded(
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              itemCount: days.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio:
                    _viewMode == DiaryViewMode.month
                        ? _monthDayCellAspectRatio
                        : _weekDayCellAspectRatio,
              ),
              itemBuilder: (context, index) => _buildDayCell(days[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayDiaryList(DateTime day) {
    final entries = _entriesForDay(day);
    final sticker = _stickersByDay[_dayKey(day)];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${day.day} ${DateFormat('EEE').format(day)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => _showStickerSelector(day),
                child: Icon(
                  Icons.emoji_emotions_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (sticker != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: ClipRRect(
                child: Image.asset(
                  sticker.value,
                  width: _stickerSizeForView(),
                  height: _stickerSizeForView(),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(Icons.broken_image_outlined);
                  },
                ),
              ),
            ),
          const SizedBox(height: 6),
          if (entries.isEmpty)
            const Text('No entries for this day')
          else
            ...entries.map(
              (e) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _categoryColor(e.type),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_categoryIcon(e.type), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _entryPreview(e),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      DateFormat.Hm().format(e.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Month
  Widget _buildDayCell(DateTime day) {
    final entries = _entriesForDay(day);
    final isSelected = _dayKey(day) == _dayKey(_selectedDay);
    final isInCurrentMonth = day.month == _selectedDay.month;
    final isToday = _dayKey(day) == _dayKey(DateTime.now());
    final sticker = _stickersByDay[_dayKey(day)];
    final textSize = _entryTextSizeForView();
    final stickerSize = _stickerSizeForView();
    final entryLimit = _entryLimitForView();

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = day),
      onLongPress:
          _viewMode == DiaryViewMode.month
              ? null
              : () => _showStickerSelector(day),
      child: Container(
        margin:
            _viewMode == DiaryViewMode.month
                ? _monthContainerMargin
                : const EdgeInsets.all(2),
        padding: EdgeInsets.all(_viewMode == DiaryViewMode.month ? _monthContainerPadding : 6),
        decoration: BoxDecoration(
          color:
              (_viewMode != DiaryViewMode.today && isToday)
                  ? const Color.fromARGB(255, 220, 248, 255)
                  : isSelected
                  ? const Color(0xFFE9F4EA)
                  : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _viewMode == DiaryViewMode.month
                      ? '${day.day}'
                      : '${day.day} ${DateFormat('EEE').format(day)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: _viewMode == DiaryViewMode.month ? 10 : 11,
                    color: isInCurrentMonth ? Colors.black : Colors.grey,
                  ),
                ),
                if (_viewMode != DiaryViewMode.month)
                  GestureDetector(
                    onTap: () => _showStickerSelector(day),
                    child: Icon(
                      Icons.emoji_emotions_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            if (_viewMode != DiaryViewMode.month && sticker != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    sticker.value,
                    width: stickerSize,
                    height: stickerSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(Icons.broken_image_outlined);
                    },
                  ),
                ),
              ),
            SizedBox(height: _viewMode == DiaryViewMode.month ? 2 : 4),
            if (_viewMode == DiaryViewMode.month)
              if (entries.isNotEmpty)
                Text(
                  '+${entries.length} more',
                  style: TextStyle(
                    fontSize: textSize,
                    color: Colors.grey.shade600,
                  ),
                )
              else
                const SizedBox.shrink()
            else ...[
              ...entries
                  .take(entryLimit)
                  .map(
                    (e) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _categoryColor(e.type),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(_categoryIcon(e.type), size: textSize + 1),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              _entryPreview(e),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: textSize),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (entries.length > entryLimit)
                Text(
                  '+${entries.length - entryLimit} more',
                  style: TextStyle(
                    fontSize: textSize,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTodayNoteSection() {
    final note = _notesByDay[_dayKey(_selectedDay)] ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today note',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _showNoteEditor,
                icon: const Icon(Icons.edit_note, color: Colors.blueGrey),
                label: const Text(
                  'Add/Edit',
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
          Text(
            note.isEmpty ? 'No additional note yet.' : note,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Travel', 'travel'),
          _buildFilterChip('Waste', 'waste'),
          _buildFilterChip('Shop', 'shopping'),
          _buildFilterChip('Eat', 'eating'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: _monthFilter == value,
      selectedColor: const Color.fromARGB(255, 41, 132, 127),
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: _monthFilter == value ? Colors.white : Colors.black,
      ),
      onSelected: (_) => setState(() => _monthFilter = value),
    );
  }

  Widget _buildMonthSelectedDateCards() {
    final logs = _entriesForDay(_selectedDay, filter: _monthFilter);

    if (logs.isEmpty) {
      return const Center(child: Text('No entries for selected day'));
    }

    return ListView(
      children:
          logs.map((log) {
            if (log.type == 'waste') {
              return _buildWasteCard(log.entry as WasteDiaryEntry);
            }
            if (log.type == 'travel') {
              return _buildTravelCard(log.entry as TravelDiaryEntry);
            }
            if (log.type == 'shopping') {
              return _buildShoppingCard(log.entry as ShoppingDiaryEntry);
            }
            return _buildEatingCard(log.entry as EatingDiaryEntry);
          }).toList(),
    );
  }

  Widget _buildShoppingCard(ShoppingDiaryEntry log) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: _categoryCardSpacing),
      child: Card(
        color: const Color(0xFFFFF3E0),
        child: ListTile(
          leading: const Icon(
            Icons.shopping_bag,
            color: Color.fromARGB(255, 255, 176, 57),
          ),
          title: Text(log.name, style: TextStyle(fontSize: 15)),
          subtitle: Text(
            'Category: ${log.category} • ${log.carbon.toStringAsFixed(4)} kgCO₂',
            style: TextStyle(fontSize: 13),
          ),
          trailing: Text(DateFormat.Hm().format(log.timestamp)),
        ),
      ),
    );
  }

  Widget _buildWasteCard(WasteDiaryEntry log) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: _categoryCardSpacing),
      child: Card(
        color: const Color(0xFFE8F5E9),
        child: ListTile(
          leading:
              log.imagePath != null &&
                      log.imagePath!.isNotEmpty &&
                      File(log.imagePath!).existsSync()
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: Image.file(
                        File(log.imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  : const Icon(Icons.recycling, color: Color(0xFF4C6A4F)),
          title: Text(log.name, style: TextStyle(fontSize: 15)),
          subtitle: Text(
            'Qty: ${log.quantity ?? '-'} • ${log.carbon.toStringAsFixed(4)} kgCO₂',
            style: TextStyle(fontSize: 13),
          ),
          trailing: Text(DateFormat.Hm().format(log.timestamp)),
        ),
      ),
    );
  }

  Widget _buildEatingCard(EatingDiaryEntry log) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: _categoryCardSpacing),
      child: Card(
        color: const Color.fromARGB(255, 222, 219, 206),
        child: ListTile(
          leading: const Icon(
            Icons.restaurant_menu,
            color: Color.fromARGB(255, 110, 97, 39),
          ),
          title: Text(
            '${log.name} ${log.variant != null ? '(${log.variant})' : ''}',
            style: TextStyle(fontSize: 15),
          ),
          subtitle: Text(
            '${log.carbon.toStringAsFixed(4)} kgCO₂',
            style: TextStyle(fontSize: 13),
          ),
          trailing: Text(DateFormat.Hm().format(log.timestamp)),
        ),
      ),
    );
  }

  Widget _buildTravelCard(TravelDiaryEntry log) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: _categoryCardSpacing),
      child: Card(
        color: const Color(0xFFE3F2FD),
        child: ListTile(
          leading: const Icon(
            Icons.directions_car_filled,
            color: Color(0xFF1976D2),
          ),
          title: Text(
            '${log.startLocation} → ${log.endLocation}',
            maxLines: 2,
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            '${log.mode} • ${log.distance.toStringAsFixed(1)} km • ${log.carbon.toStringAsFixed(2)} kgCO₂',
            style: TextStyle(fontSize: 12),
          ),
          trailing: Text(DateFormat.Hm().format(log.timestamp)),
        ),
      ),
    );
  }

  String _entryPreview(UnifiedDiaryEntry e) {
    if (e.type == 'waste') return (e.entry as WasteDiaryEntry).name;
    if (e.type == 'travel') {
      final t = e.entry as TravelDiaryEntry;
      return '${t.mode} ${t.distance.toStringAsFixed(0)}km';
    }
    if (e.type == 'shopping') return (e.entry as ShoppingDiaryEntry).name;
    return (e.entry as EatingDiaryEntry).name;
  }
}
