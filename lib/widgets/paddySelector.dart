import 'package:aswenna/core/utils/color_utils.dart';
import 'package:flutter/material.dart';

class PaddySelector extends StatefulWidget {
  final Function(String code, String color, String type, String variety)
  onSelectionComplete;

  const PaddySelector({Key? key, required this.onSelectionComplete})
    : super(key: key);

  @override
  State<PaddySelector> createState() => _PaddySelectorState();
}

class _PaddySelectorState extends State<PaddySelector> {
  String? selectedCode;
  String? selectedColor;
  String? selectedType;
  String? selectedVariety;

  // Data structures
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

  // Get available varieties based on current selections
  List<String> getAvailableVarieties() {
    if (selectedCode == null || selectedColor == null || selectedType == null) {
      return [];
    }

    try {
      return varietyMapping[selectedColor]?[selectedType]?[selectedCode] ?? [];
    } catch (e) {
      return [];
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String hint = 'Select an option',
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isEnabled
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.textLight.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              hint,
              style: TextStyle(color: AppColors.textLight, fontSize: 15),
            ),
            items:
                items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(color: AppColors.text, fontSize: 15),
                    ),
                  );
                }).toList(),
            onChanged: isEnabled ? onChanged : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEnabled ? Colors.white : AppColors.background,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableVarieties = getAvailableVarieties();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Paddy Code',
          value: selectedCode,
          items: paddyCodes,
          onChanged: (value) {
            setState(() {
              selectedCode = value;
              selectedVariety = null; // Reset dependent selections
            });
          },
        ),
        _buildDropdown(
          label: 'Paddy Color',
          value: selectedColor,
          items: paddyColors,
          onChanged: (value) {
            setState(() {
              selectedColor = value;
              selectedType = null; // Reset dependent selections
              selectedVariety = null;
            });
          },
          isEnabled: selectedCode != null,
        ),
        _buildDropdown(
          label: 'Paddy Type',
          value: selectedType,
          items: selectedColor != null ? paddyTypes[selectedColor]! : [],
          onChanged: (value) {
            setState(() {
              selectedType = value;
              selectedVariety = null;
            });
          },
          isEnabled: selectedColor != null,
        ),
        _buildDropdown(
          label: 'Variety',
          value: selectedVariety,
          items: availableVarieties,
          onChanged: (value) {
            setState(() {
              selectedVariety = value;
              if (value != null &&
                  selectedCode != null &&
                  selectedColor != null &&
                  selectedType != null) {
                widget.onSelectionComplete(
                  selectedCode!,
                  selectedColor!,
                  selectedType!,
                  value,
                );
              }
            });
          },
          isEnabled: selectedType != null && availableVarieties.isNotEmpty,
        ),
      ],
    );
  }
}
