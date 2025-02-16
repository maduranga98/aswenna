import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/data/constants/converters/connectors.dart';
import 'package:aswenna/widgets/districtFilter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> paths;
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterBottomSheet({
    Key? key,
    required this.paths,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _currentFilter;
  String? selectedFilterMethod;
  String? selectedPaddyCode;
  String? selectedPaddyVariety;
  String? selectedPaddyColor;
  String? selectedPaddyType;
  double? selectedAcres;
  int? selectedKg;
  String? selectedDistrict;
  String? selectedDSO;
  // Paddy Data
  final paddyCodes = ['BG', 'BW', 'LD', 'AT'];
  final paddyColors = ['සුදු (White)', 'රතු (Red)'];
  final Map<String, List<String>> paddyTypes = {
    'සුදු (White)': [
      'නාඩු (Nadu)',
      'සම්බා (Samba)',
      'කීරි සම්බා (Kiri Samba)',
      'බාස්මතී (Basmathi)',
    ],
    'රතු (Red)': ['නාඩු (Nadu)', 'සම්බා (Samba)', 'කීරි සම්බා (Kiri Samba)'],
  };

  final Map<String, List<String>> paddyVarieties = {
    'BG': [
      'BG 3/5',
      'BG 38',
      'BG 94/1',
      'BG 250',
      'BG 251',
      'BG 252',
      'BG 253',
      'BG 300',
      'BG 304',
      'BG 305',
      'BG 310',
      'BG 313',
      'BG 350',
      'BG 352',
      'BG 357',
      'BG 358',
      'BG 359',
      'BG 360',
      'BG 366',
      'BG 369',
      'BG 370',
      'BG 374',
      'BG 375',
      'BG 377',
      'BG 379/2',
      'BG 403',
      'BG 406',
      'BG 407',
      'BG 409',
      'BG 450',
      'BG 454',
      'BG 455',
      'BG 745',
      'වෙනත් (Other)',
    ],
    'BW': [
      'BW 272/6B',
      'BW 367/3',
      'BW 351',
      'BW 357',
      'BW 361',
      'BW 363',
      'BW 364',
      'BW 367',
      'BW 372',
      'BW 372/6B',
      'වෙනත් (Other)',
    ],
    'LD': [
      'LD 253',
      'LD 356',
      'LD 365',
      'LD 368',
      'LD 371',
      'LD 408',
      'වෙනත් (Other)',
    ],
    'AT': [
      'AT 303',
      'AT 306',
      'AT 307',
      'AT 308',
      'AT 309',
      'AT 311',
      'AT 353',
      'AT 354',
      'AT 362',
      'AT 373',
      'AT 378',
      'AT 402',
      'AT 405',
      'වෙනත් (Other)',
    ],
  };

  // Variety mappings based on color and type
  final Map<String, Map<String, Map<String, List<String>>>> varietyMapping = {
    'සුදු (White)': {
      'නාඩු (Nadu)': {
        'BG': [
          'BG 94/1',
          'BG 250',
          'BG 251',
          'BG 300',
          'BG 304',
          'BG 305',
          'BG 310',
          'BG 352',
          'BG 357',
          'BG 359',
          'BG 366',
          'BG 369',
          'BG 374',
          'BG 379/2',
          'BG 403',
          'BG 407',
          'BG 409',
          'BG 454',
        ],
        'BW': ['BW 363'],
        'LD': ['LD 253'],
      },
      'සම්බා (Samba)': {
        'BG': ['BG 358', 'BG 370', 'BG 450'],
        'BW': ['BW 367/3'],
        'LD': ['LD 371'],
      },
      'කීරි සම්බා (Kiri Samba)': {
        'BG': ['BG 360'],
      },
    },
    'රතු (Red)': {
      'නාඩු (Nadu)': {
        'BG': ['BG 406', 'BG 455'],
        'BW': ['BW 372'],
        'LD': ['LD 408'],
        'AT': ['AT 303'],
      },
      'සම්බා (Samba)': {
        'BG': ['BG 252'],
        'BW': ['BW 272/6B', 'BW 351', 'BW 361', 'BW 372/6B'],
        'LD': ['LD 365', 'LD 368', 'LD 371'],
      },
    },
  };

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DistrictFilter(
                        onSelectionChanged: (district, dso) {
                          setState(() {
                            selectedDistrict = district;
                            selectedDSO = dso;
                          });
                        },
                      ),
                    ),

                    if (widget.paths.contains('lands')) ...[
                      _buildAcresFilter(),
                    ],
                    if (widget.paths.contains('paddy')) ...[_buildKgFilter()],
                    if (widget.paths.contains('paddy') &&
                        widget.paths.contains('improved')) ...[
                      _buildFilterMethodSelection(),
                      if (selectedFilterMethod != null) ...[
                        _buildPaddyFilters(),
                      ],
                    ],
                    _buildSortingOptions(context),
                    _buildApplyButton(context),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Filter By'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMethodChip('byCode', 'වර්ගය අනුව (By Code)', Icons.code),
            _buildMethodChip(
              'byColor',
              'වර්ණය සහ වර්ගය අනුව (By Color & Type)',
              Icons.color_lens,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodChip(String value, String label, IconData icon) {
    final isSelected = selectedFilterMethod == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.accent : AppColors.textLight,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilterMethod = selected ? value : null;
          // Reset all other selections
          selectedPaddyCode = null;
          selectedPaddyVariety = null;
          selectedPaddyColor = null;
          selectedPaddyType = null;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.accent.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accent : AppColors.textLight,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color:
            isSelected
                ? AppColors.accent
                : AppColors.secondary.withOpacity(0.3),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildPaddyFilters() {
    if (selectedFilterMethod == 'byCode') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSectionTitle('වර්ගය (Paddy Code)'),
          _buildPaddyCodeSelection(),
          if (selectedPaddyCode != null) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('වර්ගය (Variety)'),
            _buildPaddyVarietyByCodeSelection(),
          ],
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSectionTitle('වර්ණය (Color)'),
          _buildPaddyColorSelection(),
          if (selectedPaddyColor != null) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('වර්ගය (Type)'),
            _buildPaddyTypeSelection(),
          ],
          if (selectedPaddyType != null) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('ලබාගත හැකි වර්ග (Available Varieties)'),
            _buildPaddyVarietyByColorSelection(),
          ],
        ],
      );
    }
  }

  Widget _buildPaddyCodeSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          paddyCodes.map((code) {
            final isSelected = selectedPaddyCode == code;
            return FilterChip(
              label: Text(code),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedPaddyCode = selected ? code : null;
                  selectedPaddyVariety = null;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.accent.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected
                        ? AppColors.accent
                        : AppColors.secondary.withOpacity(0.3),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
    );
  }

  Widget _buildPaddyColorSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          paddyColors.map((color) {
            final isSelected = selectedPaddyColor == color;
            return FilterChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedPaddyColor = selected ? color : null;
                  selectedPaddyType = null;
                  selectedPaddyVariety = null;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.accent.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected
                        ? AppColors.accent
                        : AppColors.secondary.withOpacity(0.3),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
    );
  }

  Widget _buildPaddyTypeSelection() {
    if (selectedPaddyColor == null) return const SizedBox.shrink();

    final types = paddyTypes[selectedPaddyColor] ?? [];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          types.map((type) {
            final isSelected = selectedPaddyType == type;
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedPaddyType = selected ? type : null;
                  selectedPaddyVariety = null;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.accent.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected
                        ? AppColors.accent
                        : AppColors.secondary.withOpacity(0.3),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
    );
  }

  Widget _buildPaddyVarietyByCodeSelection() {
    if (selectedPaddyCode == null) return const SizedBox.shrink();

    final varieties = paddyVarieties[selectedPaddyCode] ?? [];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          varieties.map((variety) {
            final isSelected = selectedPaddyVariety == variety;
            return FilterChip(
              label: Text(variety),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedPaddyVariety = selected ? variety : null;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.accent.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected
                        ? AppColors.accent
                        : AppColors.secondary.withOpacity(0.3),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
    );
  }

  Widget _buildPaddyVarietyByColorSelection() {
    if (selectedPaddyColor == null || selectedPaddyType == null) {
      return const SizedBox.shrink();
    }

    final varietiesByCode =
        varietyMapping[selectedPaddyColor]?[selectedPaddyType] ?? {};
    if (varietiesByCode.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'ලබාගත හැකි වර්ග නොමැත (No varieties available)',
          style: TextStyle(color: AppColors.textLight, fontSize: 14),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          varietiesByCode.entries.map((entry) {
            final code = entry.key;
            final varieties = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    code,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      varieties.map((variety) {
                        final isSelected = selectedPaddyVariety == variety;
                        return FilterChip(
                          label: Text(variety),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedPaddyVariety = selected ? variety : null;
                              selectedPaddyCode = selected ? code : null;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.accent.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color:
                                isSelected
                                    ? AppColors.accent
                                    : AppColors.textLight,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColors.accent
                                    : AppColors.secondary.withOpacity(0.3),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildSortingOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionTitle('වර්ග කිරීම අනුව (Sort By)'),
        _buildFilterOption('all', 'සියල්ල (All)', Icons.all_inclusive),
        _buildFilterOption(
          'price_low',
          'මිල: අඩුවේ සිට (Price: Low to High)',
          Icons.arrow_downward,
        ),
        _buildFilterOption(
          'price_high',
          'මිල: වැඩිවේ සිට (Price: High to Low)',
          Icons.arrow_upward,
        ),
        _buildFilterOption('newest', 'නවතම (Newest First)', Icons.new_releases),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: ElevatedButton(
        onPressed: () {
          final filterData = {
            'sortBy': _currentFilter,
            if (selectedDistrict != null) 'district': selectedDistrict,
            if (selectedDSO != null) 'dso': selectedDSO,
            if (selectedAcres != null) 'acres': selectedAcres,
            if (selectedKg != null) 'kg': selectedKg,
            if (selectedFilterMethod != null)
              'filterMethod': selectedFilterMethod,
            if (selectedPaddyCode != null) 'paddyCode': selectedPaddyCode,
            if (selectedPaddyVariety != null)
              'paddyVariety': selectedPaddyVariety,
            if (selectedPaddyColor != null) 'paddyColor': selectedPaddyColor,
            if (selectedPaddyType != null) 'paddyType': selectedPaddyType,
          };
          widget.onFilterChanged(filterData.toString());
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.text,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'යොදන්න (Apply)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.filter,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textLight),
                splashRadius: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPath(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.acres,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.paths.join(' > '),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcresFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acres',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: selectedAcres ?? 1.0,
          min: 0.0,
          max: 10.0,
          divisions: 20,
          label: '${selectedAcres?.toStringAsFixed(1) ?? "1.0"} acres',
          onChanged: (value) {
            setState(() {
              selectedAcres = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildKgFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity (KG)',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: selectedKg?.toDouble() ?? 50,
          min: 0,
          max: 1000,
          divisions: 20,
          label: '${selectedKg ?? 50} KG',
          onChanged: (value) {
            setState(() {
              selectedKg = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    final isSelected = _currentFilter == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentFilter = value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:
                isSelected
                    ? AppColors.accent.withOpacity(0.1)
                    : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.accent : AppColors.textLight,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? AppColors.text : AppColors.textLight,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle, color: AppColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get variety list based on color and type
  List<String> _getVarietiesByColorAndType(
    String color,
    String type,
    String code,
  ) {
    if (color == 'White') {
      switch (type) {
        case 'Nadu':
          switch (code) {
            case 'BG':
              return [
                'BG 94/1',
                'BG 250',
                'BG 251',
                'BG 300',
                'BG 304',
                'BG 305',
                'BG 310',
                'BG 352',
                'BG 357',
                'BG 359',
                'BG 366',
                'BG 369',
                'BG 374',
                'BG 379/2',
                'BG 403',
                'BG 407',
                'BG 409',
                'BG 454',
              ];
            case 'BW':
              return ['BW 363'];
            case 'LD':
              return ['LD 253'];
            default:
              return [];
          }
        case 'Samba':
          switch (code) {
            case 'BG':
              return ['BG 358', 'BG 370', 'BG 450'];
            case 'BW':
              return ['BW 367/3'];
            case 'LD':
              return ['LD 371'];
            default:
              return [];
          }
        case 'Kiri Samba':
          if (code == 'BG') return ['BG 360'];
          return [];
        case 'Basmathi':
          return [];
      }
    } else if (color == 'Red') {
      switch (type) {
        case 'Nadu':
          switch (code) {
            case 'BG':
              return ['BG 406', 'BG 455'];
            case 'BW':
              return ['BW 372'];
            case 'LD':
              return ['LD 408'];
            case 'AT':
              return ['AT 303'];
            default:
              return [];
          }
        case 'Samba':
          switch (code) {
            case 'BG':
              return ['BG 252'];
            case 'BW':
              return ['BW 272/6B', 'BW 351', 'BW 361', 'BW 372/6B'];
            case 'LD':
              return ['LD 365', 'LD 368', 'LD 371'];
            default:
              return [];
          }
        case 'Kiri Samba':
          return [];
      }
    }
    return [];
  }

  // Helper method to build a section title

  // Helper method to build chip groups
  Widget _buildChipGroup({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options.map((option) {
                final isSelected = selectedValue == option;
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected:
                      (selected) => onSelected(selected ? option : null),
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.accent.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.accent : AppColors.textLight,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color:
                        isSelected
                            ? AppColors.accent
                            : AppColors.secondary.withOpacity(0.3),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
        ),
      ],
    );
  }
}
