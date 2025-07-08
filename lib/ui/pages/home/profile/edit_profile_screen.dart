import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../../main.dart';
import '../../../../domain/entities/user.dart';
import '../../../../data/repositories/local_storage_service.dart';
import '../../../../data/service/cloudinary_service.dart';
import '../../../../application/edit_profile_use_case.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final LocalStorageService _storageService = LocalStorageService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final editProfileUseCase = getIt<EditProfileUseCase>();

  // Variables para el sistema de fotos
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _downloadURL;

  bool _isLoading = false;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _storageService.getCurrentUser();
      setState(() {
        currentUser = user;
        if (user != null) {
          _firstNameController.text = user.firstName ?? '';
          _lastNameController.text = user.lastName ?? '';
          _downloadURL = user.imageUrl ?? ''; // Cargar URL de imagen existente
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar los datos del usuario'),
            backgroundColor: Color(0xFFE53E3E),
          ),
        );
      }
    }
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
      final userId = await _storageService.getCurrentUserId();

      String? imageUrl = await _cloudinaryService.uploadImage(
          File(_image!.path),
          'profile_$userId'
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
      });

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

  void _removeImage() {
    setState(() {
      _image = null;
      _downloadURL = '';
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Sección de foto de perfil
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: (_image == null && (_downloadURL == null || _downloadURL!.isEmpty))
                            ? Colors.grey[200]
                            : Colors.transparent,
                        backgroundImage: _image != null
                            ? FileImage(File(_image!.path)) as ImageProvider
                            : (_downloadURL != null && _downloadURL!.isNotEmpty
                            ? NetworkImage(_downloadURL!)
                            : null),
                        child: (_image == null && (_downloadURL == null || _downloadURL!.isEmpty))
                            ? Stack(
                          children: [
                            Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
              ),

              const SizedBox(height: 10),

              // Texto indicativo
              Center(
                child: Text(
                  (_image != null || (_downloadURL != null && _downloadURL!.isNotEmpty))
                      ? 'Toca la imagen para cambiarla'
                      : 'Toca para agregar foto de perfil',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Email (solo lectura)
              const Text(
                'Correo electrónico',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  currentUser?.email ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Nombre
              const Text(
                'Nombre',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  } else if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  } else if (!RegExp(r"^[a-zA-ZÀ-ÿ\s]+$").hasMatch(value)) {
                    return 'El nombre solo puede contener letras';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Tu nombre',
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
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de apellidos
              const Text(
                'Apellidos',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese sus apellidos';
                  } else if (value.trim().length < 2) {
                    return 'Los apellidos deben tener al menos 2 caracteres';
                  } else if (!RegExp(r"^[a-zA-ZÀ-ÿ\s]+$").hasMatch(value)) {
                    return 'Los apellidos solo pueden contener letras';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Tus apellidos',
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
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: (_isLoading || _isUploading)
                        ? null
                        : const LinearGradient(
                      colors: [Color(0xFF8C52FF), Color(0xFF00A3FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: (_isLoading || _isUploading) ? const Color(0xFFE5E5E5) : null,
                  ),
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isUploading) ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: Colors.transparent,
                    ),
                    child: (_isLoading || _isUploading)
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Guardar cambios',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && currentUser != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String imageUrl = _downloadURL ?? '';

        // Si hay una imagen nueva seleccionada, subirla primero
        if (_image != null) {
          bool uploadSuccess = await _uploadImage();
          if (uploadSuccess && _downloadURL != null) {
            imageUrl = _downloadURL!;
          }
        }

        // Crear usuario actualizado
        final updatedUser = User(
          id: currentUser!.id,
          email: currentUser!.email,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          imageUrl: imageUrl, // Incluir la URL de la imagen
        );

        final success = await editProfileUseCase.editProfile(updatedUser);

        if (mounted) {
          if (success) {
            await _storageService.saveUser(updatedUser);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado correctamente'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al actualizar el perfil'),
                backgroundColor: Color(0xFFE53E3E),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: const Color(0xFFE53E3E),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}