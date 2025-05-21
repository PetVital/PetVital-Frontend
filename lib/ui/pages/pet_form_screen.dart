import 'package:flutter/material.dart';
import 'widgets/raza_selector.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class PetFormScreen extends StatefulWidget {
  final bool isFirstTime;

  const PetFormScreen({
    super.key,
    this.isFirstTime = false,
  });

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedPetType = 'Perro';
  String? _selectedBreed;
  String? _selectedSex;
  String? _selectedAge;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isFirstTime ? null : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Título dinámico según isFirstTime
              Text(
                widget.isFirstTime ? 'Agrega tu primera mascota' : 'Agrega una mascota',
                style: const TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              const Text(
                'Cuéntanos sobre tu compañero peludo',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // Área para seleccionar foto
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Aquí iría la lógica para seleccionar una foto
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Campo nombre de mascota
              const Text(
                'Nombre de tu mascota',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ej: Rocky',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tipo de mascota - selectores de Perro o Gato
              const Text(
                'Tipo de mascota',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Botón Perro
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPetType = 'Perro';
                          _selectedBreed = null;
                        });
                      },
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedPetType == 'Perro'
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: _selectedPetType == 'Perro' ? 2 : 1,
                          ),
                          color: _selectedPetType == 'Perro'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              color: _selectedPetType == 'Perro'
                                  ? Colors.blue
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Perro',
                              style: TextStyle(
                                color: _selectedPetType == 'Perro'
                                    ? Colors.blue
                                    : Colors.black87,
                                fontWeight: _selectedPetType == 'Perro'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Botón Gato
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPetType = 'Gato';
                          _selectedBreed = null;
                        });
                      },
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedPetType == 'Gato'
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: _selectedPetType == 'Gato' ? 2 : 1,
                          ),
                          color: _selectedPetType == 'Gato'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -2),
                              child: Icon(
                                Icons.pets,
                                color: _selectedPetType == 'Gato'
                                    ? Colors.blue
                                    : Colors.grey,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gato',
                              style: TextStyle(
                                color: _selectedPetType == 'Gato'
                                    ? Colors.blue
                                    : Colors.black87,
                                fontWeight: _selectedPetType == 'Gato'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Selector de raza
              const Text(
                'Raza',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              RazaSelector(
                selectedPetType: _selectedPetType,
                selectedBreed: _selectedBreed,
                onChanged: (value) {
                  setState(() {
                    _selectedBreed = value;
                  });
                },
              ),


              const SizedBox(height: 16),

              // Fila con Selectores de Sexo y Edad
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo Sexo (ocupa fila completa)
                  const Text(
                    'Sexo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: const Text(
                        'Selecciona sexo',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      items: ['Macho', 'Hembra']
                          .map((sexo) => DropdownMenuItem(
                        value: sexo,
                        child: Text(
                          sexo,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ))
                          .toList(),
                      value: _selectedSex,
                      onChanged: (value) {
                        setState(() {
                          _selectedSex = value;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Color(0xFFF5F5F5)),
                          color: Colors.grey[100],
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo Edad (número + unidad en una fila)
                  const Text(
                    'Edad',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Ej: 3',
                            hintStyle: const TextStyle(color: Colors.grey),
                            fillColor: Colors.grey[100],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: const Text(
                              'Años',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            items: ['Años', 'Meses']
                                .map((unidad) => DropdownMenuItem(
                              value: unidad,
                              child: Text(
                                unidad,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ))
                                .toList(),
                            value: _selectedAge,
                            onChanged: (value) {
                              setState(() {
                                _selectedAge = value;
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Color(0xFFF5F5F5)),
                                color: Colors.grey[100],
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            iconStyleData: const IconStyleData(
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Campo peso
              const Text(
                'Peso (kg)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ej: 15',
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón Continuar
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8C52FF), Color(0xFF00A3FF)], // Degradado púrpura a azul
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Para que el botón no sobreescriba el gradiente
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white, // Texto en blanco para contraste
                      ),
                    ),
                  ),
                ),
              ),

              // Mostrar "Omitir por ahora" solo si es primera vez
              if (widget.isFirstTime) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Implementar lógica para omitir
                    },
                    child: const Text(
                      'Omitir por ahora',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}