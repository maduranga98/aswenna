import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/data/constants/list_data.dart';
import 'package:aswenna/data/constants/converters/connectors.dart';

class LocalizedDistrictFilter extends StatefulWidget {
  final void Function(
    String? districtEn,
    String? districtLocalized,
    String? dsoEn,
    String? dsoLocalized,
  )
  onSelectionChanged;

  const LocalizedDistrictFilter({super.key, required this.onSelectionChanged});

  @override
  State<LocalizedDistrictFilter> createState() =>
      _LocalizedDistrictFilterState();
}

class _LocalizedDistrictFilterState extends State<LocalizedDistrictFilter> {
  // Selected values
  String? districtEn;
  String? districtLocalized;
  String? dsoEn;
  String? dsoLocalized;
  Map<String, String> dsoMap = {};

  // Maps to keep track of English keys and localized values
  Map<String, String> districtLocalizedToEnMap = {};
  Map<String, String> districtEnToLocalizedMap = {};

  @override
  void initState() {
    super.initState();
    // Initialize maps in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMaps();
    });
  }

  void _initializeMaps() {
    final localizations = AppLocalizations.of(context)!;

    // Get the districts mapping
    final districts = districtsSet(localizations);

    // Create bidirectional maps for districts
    // In your case, the key is the English value, and the value is the localized value
    for (var entry in districts.entries) {
      // Here keys are English and values are localized
      districtEnToLocalizedMap[entry.key] = entry.value;
      // Reverse mapping for localized to English
      districtLocalizedToEnMap[entry.value] = entry.key;
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(
              hintText,
              style: const TextStyle(fontSize: 14, color: AppColors.textLight),
              overflow: TextOverflow.ellipsis,
            ),
            items: items,
            value: value,
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.secondary,
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              offset: const Offset(0, -4),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(6),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
                thumbColor: MaterialStateProperty.all<Color>(
                  AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            dropdownSearchData: DropdownSearchData<String>(
              searchMatchFn: (item, searchValue) {
                return (item.value?.toString().toLowerCase() ?? '').contains(
                  searchValue.toLowerCase(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Get the district items map
    final districtsMap = districtsSet(localizations);

    // For district dropdown, we show localized values
    List<DropdownMenuItem<String>> districtItems =
        districtsMap.entries
            .map(
              (e) => DropdownMenuItem<String>(
                value: e.value, // Display and select the localized value
                child: Text(
                  e.value,
                  style: const TextStyle(fontSize: 14, color: AppColors.text),
                ),
              ),
            )
            .toList();

    // For DSO dropdown, use the same pattern as your existing code
    List<DropdownMenuItem<String>> dsoItems =
        dsoMap.entries
            .map(
              (e) => DropdownMenuItem<String>(
                value: e.value, // Display and select the localized value
                child: Text(
                  e.value,
                  style: const TextStyle(fontSize: 14, color: AppColors.text),
                ),
              ),
            )
            .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // District Dropdown
          _buildDropdown(
            label: localizations.district,
            value: districtLocalized,
            items: districtItems,
            onChanged: (String? newLocalizedValue) {
              if (newLocalizedValue != null) {
                // Find the English key for this localized value
                final newEnValue = districtLocalizedToEnMap[newLocalizedValue];

                setState(() {
                  districtLocalized = newLocalizedValue;
                  districtEn = newEnValue;
                  dsoEn = null;
                  dsoLocalized = null;
                  // Get DSO mapping for this district
                  dsoMap =
                      newEnValue != null
                          ? districtToDSOConnector(localizations, newEnValue)
                          : {};
                });

                // Notify parent with both English and localized values
                widget.onSelectionChanged(
                  districtEn,
                  districtLocalized,
                  dsoEn,
                  dsoLocalized,
                );
              }
            },
            hintText: localizations.select,
          ),
          const SizedBox(height: 16),

          // DSO Dropdown
          _buildDropdown(
            label: localizations.dso,
            value: dsoLocalized,
            items: dsoItems,
            onChanged: (String? newLocalizedValue) {
              if (newLocalizedValue != null) {
                // For DSOs, the items map is used differently
                // In your structure, keys are the English codes, values are localized names
                // Find the English key for this localized value by searching
                String? newEnValue;

                // Find the English key (code) that matches this localized value
                for (var entry in dsoMap.entries) {
                  if (entry.value == newLocalizedValue) {
                    newEnValue = entry.key;
                    break;
                  }
                }

                setState(() {
                  dsoLocalized = newLocalizedValue;
                  dsoEn = newEnValue;
                });

                // Notify parent with both English and localized values
                widget.onSelectionChanged(
                  districtEn,
                  districtLocalized,
                  dsoEn,
                  dsoLocalized,
                );
              }
            },
            hintText: localizations.select,
          ),
        ],
      ),
    );
  }
}
