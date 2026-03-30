import 'package:flutter/material.dart';
import '../../features/areas/data/models/area_model.dart';

class AppAreaSelector extends StatelessWidget {
  final List<AreaModel> areas;
  final AreaModel? selectedArea;
  final ValueChanged<AreaModel?> onChanged;
  final bool isLoading;

  const AppAreaSelector({
    super.key,
    required this.areas,
    required this.selectedArea,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Area', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AreaModel>(
              isExpanded: true,
              value: selectedArea,
              hint: Text(isLoading ? 'Memuat data area...' : 'Pilih dari daftar'),
              items: areas.map((area) {
                return DropdownMenuItem<AreaModel>(
                  value: area,
                  child: Text('${area.code} - ${area.name}'),
                );
              }).toList(),
              onChanged: isLoading ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
