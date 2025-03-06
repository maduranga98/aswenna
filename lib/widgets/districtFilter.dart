import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/data/constants/converters/connectors.dart';
import 'package:aswenna/data/constants/list_data.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DistrictFilter extends StatefulWidget {
  final void Function(String?, String?) onSelectionChanged;

  const DistrictFilter({super.key, required this.onSelectionChanged});

  @override
  State<DistrictFilter> createState() => _DistrictFilterState();
}

class _DistrictFilterState extends State<DistrictFilter> {
  String? district;
  String? dso;
  Map<String, String> dsoMap = {};

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
            // Explicitly specify String type
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
              // Explicitly specify String type
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
    final districtSet = districtsSet(localizations);
    final itemsMap = Map.fromIterables(districtSet.values, districtSet.keys);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildDropdown(
            label: localizations.district,
            value: district,
            items:
                itemsMap.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.value,
                        child: Text(
                          e.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (String? newValue) {
              setState(() {
                district = newValue;
                dso = null;
                dsoMap =
                    newValue != null
                        ? districtToDSOConnector(localizations, newValue)
                        : {};
                widget.onSelectionChanged(district, dso);
              });
            },
            hintText: localizations.select,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: localizations.dso,
            value: dso,
            items:
                dsoMap.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(
                          e.value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (String? value) {
              setState(() {
                dso = value;
                widget.onSelectionChanged(district, dso);
              });
            },
            hintText: localizations.select,
          ),
        ],
      ),
    );
  }
}
