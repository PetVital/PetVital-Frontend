import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../../../../data/api/common/api_constants.dart';

// Modelo User (sin cambios)
class UserData {
  final int userId;
  final String nombres;
  final String apellidos;
  final String email;
  final String fechaRegistro;

  UserData({
    required this.userId,
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.fechaRegistro,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      email: json['email'],
      fechaRegistro: json['fecha_registro'],
    );
  }
}

class RegisteredUserScreen extends StatefulWidget {
  const RegisteredUserScreen({super.key});

  @override
  State<RegisteredUserScreen> createState() => _RegisteredUserScreenState();
}

class _RegisteredUserScreenState extends State<RegisteredUserScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final String baseUrl = ApiConstants.baseUrl;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Variable para guardar la ruta del archivo descargado
  String? _lastDownloadedFilePath;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  // Método para obtener usuarios desde la API
  Future<List<UserData>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/list/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => UserData.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para crear el archivo Excel
  Future<void> _createExcelFile(List<UserData> users) async {
    try {
      // Crear un nuevo archivo Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Usuarios Registrados'];

      // Eliminar la hoja por defecto
      excel.delete('Sheet1');

      // Agregar encabezados
      sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('User ID');
      sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue('Nombres');
      sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue('Apellidos');
      sheetObject.cell(CellIndex.indexByString("D1")).value = TextCellValue('Email');
      sheetObject.cell(CellIndex.indexByString("E1")).value = TextCellValue('Fecha de Registro');

      // Estilo para encabezados
      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
      );

      // Aplicar estilo a encabezados
      for (int col = 0; col < 5; col++) {
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).cellStyle = headerStyle;
      }

      // Agregar datos de usuarios
      for (int i = 0; i < users.length; i++) {
        int row = i + 1;
        UserData user = users[i];

        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = IntCellValue(user.userId);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(user.nombres);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(user.apellidos);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(user.email);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = TextCellValue(user.fechaRegistro);
      }

      // Ajustar ancho de columnas
      sheetObject.setColumnWidth(0, 10);
      sheetObject.setColumnWidth(1, 20);
      sheetObject.setColumnWidth(2, 20);
      sheetObject.setColumnWidth(3, 25);
      sheetObject.setColumnWidth(4, 25);

      // Obtener directorio de descargas
      Directory? directory;
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          await Permission.manageExternalStorage.request();
        }
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        String fileName = 'usuarios_registrados_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        String filePath = '${directory.path}/$fileName';

        // Guardar el archivo
        List<int>? fileBytes = excel.save();
        if (fileBytes != null) {
          File file = File(filePath);
          await file.writeAsBytes(fileBytes);

          // Guardar la ruta del archivo para poder abrirlo después
          _lastDownloadedFilePath = filePath;

          if (mounted) {
            _showSuccessSnackBar('Registro guardado en Descargas');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al crear archivo Excel: $e');
      }
    }
  }

  // Método para abrir el archivo descargado
  Future<void> _openDownloadedFile() async {
    if (_lastDownloadedFilePath != null) {
      try {
        final result = await OpenFile.open(_lastDownloadedFilePath!);
        if (result.type != ResultType.done) {
          _showErrorSnackBar('No se pudo abrir el archivo');
        }
      } catch (e) {
        _showErrorSnackBar('Error al abrir el archivo: $e');
      }
    }
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: const Color(0xFF8158B7),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Verificación de Seguridad',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ingresa la contraseña para acceder a los datos de usuarios',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: const Color(0xFF8158B7),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _passwordController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8158B7), Color(0xFF35B4DD)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_passwordController.text == '123456') {
                        Navigator.of(context).pop();
                        await _downloadUserData();
                        _passwordController.clear();
                      } else {
                        _showErrorSnackBar('Contraseña incorrecta');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Verificar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _downloadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('✅ Contraseña correcta. Obteniendo datos de usuarios...');
      List<UserData> users = await getUsers();
      debugPrint('✅ ${users.length} usuarios obtenidos');
      await _createExcelFile(users);
      debugPrint('✅ Archivo Excel creado y guardado');
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        _showErrorSnackBar('Error al descargar datos: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade300,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'ABRIR',
          textColor: Colors.white,
          onPressed: () {
            _openDownloadedFile();
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade300,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Usuarios Registrados',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Color(0xFFECECEC),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _buildDownloadCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF8158B7),
                    ),
                  ),
                ),
                Icon(
                  Icons.cloud_download,
                  size: 35,
                  color: const Color(0xFF8158B7),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Descargando datos...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Obteniendo información de usuarios registrados',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.people_alt,
                size: 60,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Exportar Usuarios',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Descarga un archivo Excel con todos los usuarios registrados en el sistema',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8158B7), Color(0xFF35B4DD)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8158B7).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _showPasswordDialog,
                  icon: const Icon(Icons.download, size: 22, color: Colors.white),
                  label: const Text(
                    'Descargar Registro de Usuarios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acceso protegido con contraseña',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}