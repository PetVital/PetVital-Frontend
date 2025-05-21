import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RazaSelector extends StatelessWidget {
  final String selectedPetType;
  final String? selectedBreed;
  final ValueChanged<String?> onChanged;

  const RazaSelector({
    super.key,
    required this.selectedPetType,
    required this.selectedBreed,
    required this.onChanged,
  });

  static const Map<String, List<String>> breeds = {
    'Perro': ['Labrador', 'Golden', 'Bulldog', 'Pastor Alemán', 'Otro'],
    'Gato': ['Persa', 'Siamés', 'Angora', 'Maine Coon', 'Otro'],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: const Text(
              'Selecciona una raza',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            items: (breeds[selectedPetType] ?? [])
                .map((raza) => DropdownMenuItem(
              value: raza,
              child: Text(
                raza,
                style: const TextStyle(fontSize: 14),
              ),
            ))
                .toList(),
            value: selectedBreed,
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Color(0xFFF5F5F5)),
                color: Colors.grey[100], // Fondo del input
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: Colors.white, // Fondo de la lista desplegable
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
            ),
          ),
        )
      ],
    );
  }
}

