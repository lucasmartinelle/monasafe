import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:monasafe/src/core/theme/app_colors.dart';
import 'package:monasafe/src/core/theme/app_text_styles.dart';
import 'package:monasafe/src/core/utils/icon_mapper.dart';

class _IconEntry {
  const _IconEntry({
    required this.name,
    required this.labelFr,
    this.tags = const [],
  });

  final String name;
  final String labelFr;
  final List<String> tags;

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    if (name.contains(q)) return true;
    if (labelFr.toLowerCase().contains(q)) return true;
    return tags.any((k) => k.toLowerCase().contains(q));
  }
}

class IconPicker extends StatefulWidget {
  const IconPicker({
    required this.selectedIconKey,
    required this.onIconSelected,
    required this.selectedColor,
    super.key,
  });

  final String selectedIconKey;
  final ValueChanged<String> onIconSelected;
  final int selectedColor;

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  List<_IconEntry> _allIcons = [];
  List<_IconEntry> _filtered = [];
  final _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIcons() async {
    final raw = await rootBundle.loadString('assets/icons.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    final icons = list.map((e) => _IconEntry(
      name: e['name'] as String,
      labelFr: e['fr'] as String,
      tags: (e['tags'] as List? ?? []).cast<String>(),
    )).toList();

    if (mounted) {
      setState(() {
        _allIcons = icons;
        _filtered = icons;
        _loading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = _allIcons.where((e) => e.matches(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final color = Color(widget.selectedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Icône', style: AppTextStyles.labelMedium(color: textColor)),
        ),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher (ex: voiture, sport…)',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
          ),
          onChanged: _onSearch,
        ),
        const SizedBox(height: 10),
        if (_loading)
          const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ))
        else if (_filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Aucune icône trouvée',
                style: AppTextStyles.bodyMedium(color: textColor),
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final entry = _filtered[index];
                final isSelected = entry.name == widget.selectedIconKey;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onIconSelected(entry.name);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: color, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Tooltip(
                        message: entry.labelFr,
                        child: Icon(
                          lucideIconFromKey(entry.name),
                          size: 22,
                          color: isSelected
                              ? color
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
