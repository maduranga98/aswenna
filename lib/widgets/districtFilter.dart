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
    required Function(String?) onChanged,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            hint: Text(
              hintText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            items: items,
            value: value,
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              offset: const Offset(0, -4),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(6),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
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

    return Column(
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
                        style: TextStyle(fontSize: 14, color: Colors.white),
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
                        style: TextStyle(fontSize: 14, color: Colors.white),
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
    );
  }
}
