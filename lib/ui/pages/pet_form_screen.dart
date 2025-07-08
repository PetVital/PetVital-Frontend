
import 'dart:io';
import 'package:flutter/material.dart';
import 'widgets/raza_selector.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../data/repositories/local_storage_service.dart';
import '../../data/service/cloudinary_service.dart';
import '../../domain/entities/pet.dart';
import '../../../core/routes/app_routes.dart';
import '../../../application/add_pet_use_case.dart';
import '../../../main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

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

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final localStorageService = LocalStorageService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = false;

  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _downloadURL;


  String _selectedPetType = 'Perro';
  String? _selectedBreed;
  String? _selectedSex;
  String? _selectedTime;

  // Variables para manejar errores de dropdowns
  String? _breedError;
  String? _sexError;
  String? _ageUnitError;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Puedes ajustar la calidad de la imagen
    );

    if (image != null) {
      // Filtrar por formato válido
      final validFormats = ['jpg', 'jpeg', 'png'];
      final String fileExtension = path.extension(image.path).toLowerCase().replaceAll('.', '');

      if (!validFormats.contains(fileExtension)) {
        // Mostrar SnackBar si el formato no es válido
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Formato de imagen no válido. Seleccione una imagen JPG o PNG.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red, // Snack rojo para error
          ),
        );
      } else {
        // Si la imagen tiene un formato válido
        setState(() {
          _image = image;
        });
      }
    }
  }


  Future _uploadImage() async {
    if (_image == null) {
      print("⚠️ No hay imagen seleccionada para subir.");
      return false;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = await localStorageService.getCurrentUserId();
      print("👤 ID de usuario obtenido: $userId");

      final imageName = 'pet_${_nameController.text.trim()}_${userId}';
      print("📤 Subiendo imagen con nombre: $imageName");

      String? imageUrl = await _cloudinaryService.uploadImage(
        File(_image!.path),
        imageName,
      );

      print("📥 Respuesta de Cloudinary: $imageUrl");

      if (imageUrl != null) {
        setState(() {
          _downloadURL = imageUrl;
          _isUploading = false;
        });

        print("✅ Imagen subida exitosamente: $_downloadURL");
        return true;
      } else {
        print("❌ Cloudinary devolvió null");
        setState(() {
          _isUploading = false;
          _downloadURL = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al subir la imagen'),
              backgroundColor: Colors.red,
            ),
          );
        }

        return false;
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _downloadURL = null;
      });

      print('🔥 Excepción al subir imagen: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    }
  }


  void _submitForm() async {
    print("🟡 Iniciando _submitForm...");

    // Validar formulario y dropdowns
    bool isFormValid = _formKey.currentState!.validate();
    print("📋 ¿Formulario válido?: $isFormValid");

    setState(() {
      _breedError = _selectedBreed == null ? 'Selecciona una raza' : null;
      _sexError = _selectedSex == null ? 'Selecciona el sexo' : null;
      _ageUnitError = _selectedTime == null ? 'Selecciona la unidad de edad' : null;
    });

    bool areDropdownsValid = _breedError == null && _sexError == null && _ageUnitError == null;
    print("📋 ¿Dropdowns válidos?: $areDropdownsValid");

    if (!isFormValid || !areDropdownsValid) {
      print("❌ Validación fallida. Cancelando...");
      _showError('Por favor completa todos los campos correctamente.');
      return;
    }

    final userId = await localStorageService.getCurrentUserId();

    bool isNameRepeated = await localStorageService.isPetNameRepeated(_nameController.text.trim(), userId, 0);

    if (isNameRepeated) {
      _showError('El nombre de la mascota ya está registrado. Por favor, ingresa un nombre único.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = "";

      // Si hay una imagen seleccionada, intenta subirla primero a Cloudinary
      if (_image != null) {
        print("📸 Imagen seleccionada. Subiendo...");
        bool uploadSuccess = await _uploadImage();
        print("📤 Resultado de subida: $uploadSuccess");

        if (uploadSuccess && _downloadURL != null) {
          imageUrl = _downloadURL!;
          print("✅ URL de imagen obtenida: $imageUrl");
        } else {
          print("⚠️ La imagen no se subió correctamente o _downloadURL es null.");
        }
      } else {
        print("📸 No hay imagen seleccionada. Se usará imageUrl vacío.");
      }

      final pet = Pet(
        id: 0,
        name: _nameController.text.trim(),
        type: _selectedPetType,
        breed: _selectedBreed!,
        gender: _selectedSex!,
        age: int.parse(_ageController.text.trim()),
        timeUnit: _selectedTime!,
        weight: double.parse(_weightController.text.trim()),
        userId: userId,
        isSterilized: false,
        imageUrl: imageUrl ?? '',
      );

      print("📦 Pet listo para enviar:");
      print(pet.toJson());
      print("🔗 URL asignada al pet: ${pet.imageUrl}");

      final addPetUseCase = getIt<AddPetUseCase>();
      final petResponse = await addPetUseCase.addPet(pet);

      if (petResponse != null) {
        print("✅ Pet registrado correctamente en el backend: ${petResponse.toJson()}");

        await localStorageService.insertPet(petResponse);
        print("📥 Pet guardado en SQLite correctamente.");

        _showSuccess("Mascota registrada exitosamente");

        if (widget.isFirstTime) {
          print("🧭 Navegando a pantalla principal.");
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
                (route) => false,
          );
        } else {
          print("🔙 Navegando hacia atrás con la mascota creada.");
          Navigator.pop(context, petResponse);
        }
      } else {
        print("❌ No se recibió respuesta del backend al registrar la mascota.");
        _showError('No se pudo registrar la mascota. Intenta nuevamente.');
      }

    } catch (e) {
      print("🔥 Excepción durante el guardado: $e");
      _showError('Error al guardar la mascota: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("🔚 Finalizando _submitForm");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white), // Letras blancas
        ),
        backgroundColor: Colors.green, // Fondo verde
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _downloadURL = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Text(
          widget.isFirstTime ? 'Agrega tu primera mascota' : 'Agrega una mascota',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            if(widget.isFirstTime){
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                    (route) => false, // Esto elimina todas las rutas anteriores
              );
            }else{
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                GestureDetector(
                  onTap: _pickImage,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: (_image == null && (_downloadURL == null || _downloadURL!.isEmpty))
                                    ? Colors.grey[200] // Fondo en escala de grises
                                    : const Color(0xffF0EFFE), // Fondo normal (por si acaso)
                                backgroundImage: _image != null
                                    ? FileImage(File(_image!.path)) as ImageProvider
                                    : (_downloadURL != null && _downloadURL!.isNotEmpty
                                    ? NetworkImage(_downloadURL!)
                                    : null),
                                child: (_image == null && (_downloadURL == null || _downloadURL!.isEmpty))
                                    ? Icon(
                                  Icons.camera_alt_outlined,
                                  size: 60,
                                  color: Colors.grey, // Ícono en escala de grises
                                )
                                    : null,
                              ),
                            ),

                            // Mostrar botón de eliminar si hay una imagen
                            if (_image != null || (_downloadURL != null && _downloadURL!.isNotEmpty))
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          (_image != null || (_downloadURL != null && _downloadURL!.isNotEmpty))
                              ? 'Toca la imagen para cambiarla'
                              : 'Elegir foto',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 24),

                // Campo nombre de mascota con validación
                const Text(
                  'Nombre de tu mascota',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el nombre de tu mascota';
                    } else if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    } else if (!RegExp(r"^[a-zA-ZÀ-ÿ\s]+$").hasMatch(value.trim())) {
                      return 'El nombre solo puede contener letras y espacios';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Ej: Rocky',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
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
                            _breedError = null; // Reset breed error
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
                            _breedError = null; // Reset breed error
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

                // Selector de raza con validación
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Raza',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: _breedError != null
                            ? Border.all(color: Colors.red, width: 1)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RazaSelector(
                        selectedPetType: _selectedPetType,
                        selectedBreed: _selectedBreed,
                        onChanged: (value) {
                          setState(() {
                            _selectedBreed = value;
                            _breedError = null; // Clear error when selection is made
                          });
                        },
                      ),
                    ),
                    if (_breedError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          _breedError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Campo Sexo con validación
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            _sexError = null; // Clear error when selection is made
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _sexError != null
                                    ? Colors.red
                                    : const Color(0xFFF5F5F5)
                            ),
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
                    if (_sexError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          _sexError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Campo Edad con validación
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa la edad';
                              }
                              final age = double.tryParse(value.trim());
                              if (age == null || age <= 0) {
                                return 'Edad inválida';
                              }
                              if (age > 50) {
                                return 'Edad muy alta';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Ej: 3',
                              hintStyle: const TextStyle(color: Colors.grey),
                              fillColor: Colors.grey[100],
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Colors.red, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Colors.red, width: 1),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const Text(
                                    'Años',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  items: ['Años', 'Meses', 'Días']
                                      .map((unidad) => DropdownMenuItem(
                                    value: unidad,
                                    child: Text(
                                      unidad,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                                      .toList(),
                                  value: _selectedTime,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTime = value;
                                      _ageUnitError = null; // Clear error when selection is made
                                    });
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: _ageUnitError != null
                                              ? Colors.red
                                              : const Color(0xFFF5F5F5)
                                      ),
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
                              if (_ageUnitError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 12),
                                  child: Text(
                                    _ageUnitError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Campo peso con validación
                const Text(
                  'Peso (kg)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el peso de tu mascota';
                    }
                    final weight = double.tryParse(value.trim());
                    if (weight == null || weight <= 0) {
                      return 'Por favor ingresa un peso válido';
                    }
                    if (weight > 200) {
                      return 'El peso parece demasiado alto';
                    }
                    if (weight < 0.1) {
                      return 'El peso parece demasiado bajo';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Ej: 15',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botón Continuar con estado de carga
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isLoading
                            ? [Colors.grey[400]!, Colors.grey[400]!]
                            : [const Color(0xFF8C52FF), const Color(0xFF00A3FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
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
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.main,
                              (route) => false, // Esto elimina todas las rutas anteriores
                        );
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
      ),
    );
  }
}