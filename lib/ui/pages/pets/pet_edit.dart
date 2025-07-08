import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/raza_selector.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../data/service/cloudinary_service.dart';
import '../../../domain/entities/pet.dart';
import '../../../core/routes/app_routes.dart';
import '../../../application/update_pet_use_case.dart';
import '../../../application/delete_pet_use_case.dart';
import '../../../main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class PetEdit extends StatefulWidget {
  final Pet pet;

  const PetEdit({
    super.key,
    required this.pet,
  });

  @override
  State<PetEdit> createState() => _PetEditState();
}

class _PetEditState extends State<PetEdit> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final localStorageService = LocalStorageService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isLoading = false;

  // Variables para imagen
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
  void initState() {
    super.initState();
    _loadPetData();
  }

  void _loadPetData() {
    _nameController.text = widget.pet.name;
    _ageController.text = widget.pet.age.toString();
    _weightController.text = widget.pet.weight.toString();
    _selectedPetType = widget.pet.type;
    _selectedBreed = widget.pet.breed;
    _selectedSex = widget.pet.gender;
    _selectedTime = widget.pet.timeUnit;
    // Cargar la imagen existente
    _downloadURL = widget.pet.imageUrl.isNotEmpty ? widget.pet.imageUrl : null;
  }

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
      imageQuality: 85,
    );

    if (image != null) {
      // Filtrar por formato válido
      final validFormats = ['jpg', 'jpeg', 'png'];
      final String fileExtension = path.extension(image.path).toLowerCase().replaceAll('.', '');

      if (!validFormats.contains(fileExtension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Formato de imagen no válido. Seleccione una imagen JPG o PNG.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          _image = image;
          _downloadURL = null; // Reset la URL anterior cuando se selecciona nueva imagen
        });
      }
    }
  }

  Future<bool> _uploadImage() async {
    if (_image == null) return false;

    setState(() {
      _isUploading = true;
    });

    try {
      final userId = await localStorageService.getCurrentUserId();

      // Subir imagen a Cloudinary
      String? imageUrl = await _cloudinaryService.uploadImage(
          File(_image!.path),
          'pet_${_nameController.text.trim()}_${userId}'
      );

      if (imageUrl != null) {
        setState(() {
          _downloadURL = imageUrl;
          _isUploading = false;
        });
        return true;
      } else {
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

      print('Error al subir imagen: $e');

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

  void _updatePet() async {
    // Validar formulario y dropdowns
    bool isFormValid = _formKey.currentState!.validate();

    setState(() {
      _breedError = _selectedBreed == null ? 'Selecciona una raza' : null;
      _sexError = _selectedSex == null ? 'Selecciona el sexo' : null;
      _ageUnitError = _selectedTime == null ? 'Selecciona la unidad de edad' : null;
    });

    bool areDropdownsValid = _breedError == null && _sexError == null && _ageUnitError == null;

    if (!isFormValid || !areDropdownsValid) {
      _showError('Por favor completa todos los campos correctamente.');
      return;
    }

    bool isNameRepeated = await localStorageService.isPetNameRepeated(_nameController.text.trim(), widget.pet.userId, widget.pet.id);

    if (isNameRepeated) {
      _showError('El nombre de la mascota ya está registrado. Por favor, ingresa un nombre único.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = widget.pet.imageUrl; // Mantener la imagen existente por defecto

      // Si hay una nueva imagen seleccionada, intenta subirla
      if (_image != null) {
        bool uploadSuccess = await _uploadImage();
        if (uploadSuccess && _downloadURL != null) {
          imageUrl = _downloadURL!;
        }
      }
      // Si se eliminó la imagen (downloadURL está vacío), actualizar a cadena vacía
      else if (_downloadURL != null && _downloadURL!.isEmpty) {
        imageUrl = '';
      }

      final updatedPet = Pet(
        id: widget.pet.id,
        name: _nameController.text.trim(),
        type: _selectedPetType,
        breed: _selectedBreed!,
        gender: _selectedSex!,
        age: int.parse(_ageController.text.trim()),
        timeUnit: _selectedTime!,
        weight: double.parse(_weightController.text.trim()),
        userId: widget.pet.userId,
        isSterilized: widget.pet.isSterilized,
        imageUrl: imageUrl,
      );

      final updatePetUseCase = getIt<UpdatePetUseCase>();
      final success = await updatePetUseCase.updatePet(updatedPet);

      if (success) {
        await localStorageService.updatePet(updatedPet);
        _showSuccess("Mascota actualizada exitosamente");
        Navigator.pop(context, true);
      } else {
        _showError('No se pudo actualizar la mascota. Intenta nuevamente.');
      }

    } catch (e) {
      _showError('Error al actualizar la mascota: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deletePet() async {
    // Mostrar diálogo de confirmación
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Eliminar mascota'),
          content: Text('¿Estás seguro de que quieres eliminar a ${widget.pet.name}? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final deletePetUseCase = getIt<DeletePetUseCase>();
      final success = await deletePetUseCase.deletePet(widget.pet.id);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        await localStorageService.deletePet(widget.pet.id);
        _showSuccess("Mascota eliminada exitosamente");
        Navigator.pop(context, true);
      } else {
        _showError('No se pudo eliminar la mascota. Intenta nuevamente.');
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error al eliminar la mascota: ${e.toString()}');
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
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
          'Editar mascota',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context, false),
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
                  'Actualiza la información de tu mascota',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                // Sección de imagen
                GestureDetector(
                  onTap: _pickImage,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: (_image == null && (_downloadURL == null || _downloadURL!.isEmpty))
                                  ? Colors.grey[200]
                                  : const Color(0xffF0EFFE),
                              backgroundImage: _image != null
                                  ? FileImage(File(_image!.path)) as ImageProvider
                                  : (_downloadURL != null && _downloadURL!.isNotEmpty
                                  ? NetworkImage(_downloadURL!)
                                  : null),
                              child: (_image == null && (_downloadURL == null || _downloadURL!.isEmpty))
                                  ? Icon(
                                Icons.camera_alt_outlined,
                                size: 60,
                                color: Colors.grey,
                              )
                                  : null,
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

                            if (_isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                            _breedError = null;
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
                            _breedError = null;
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
                            _breedError = null;
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
                            _sexError = null;
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
                                      _ageUnitError = null;
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

                // Botones Eliminar y Actualizar
                Row(
                  children: [
                    // Botón Eliminar
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _deletePet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          )
                              : const Text(
                            'Eliminar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Botón Actualizar
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8C52FF), Color(0xFF00A3FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updatePet,
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
                            'Actualizar',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}