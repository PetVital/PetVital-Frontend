import 'package:flutter/material.dart';
import '../../../application/get_pet_checkups_use_case.dart';
import '../../../application/delete_checkup_use_case.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../domain/entities/checkup.dart';
import '../../../domain/entities/pet.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../main.dart';
import 'checkup_form_screen.dart';
import 'checkup_details_screen.dart';

class PetHistory extends StatefulWidget {
  final int petId;

  const PetHistory({
    super.key,
    required this.petId,
  });

  @override
  State<PetHistory> createState() => _PetHistoryState();
}

class _PetHistoryState extends State<PetHistory> {
  bool isLoading = true;
  String? errorMessage;
  List<Checkup> checkups = [];
  String selectedSterilizationStatus = 'Sin esterilizar';
  Pet? currentPet; // Cambiado de Pet currentPet = null; a Pet? currentPet;

  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Obtener la mascota una sola vez y guardarla en currentPet
      currentPet = await _storageService.getPetById(widget.petId);

      // Usar currentPet para obtener el estado de esterilización
      final isSterilized = currentPet?.isSterilized ?? false;

      setState(() {
        selectedSterilizationStatus = isSterilized
            ? 'Esterilizado'
            : 'Sin esterilizar';
      });

      final checkupsUseCase = getIt<GetPetCheckupsUseCase>();
      final allCheckups = await checkupsUseCase.getPetCheckups(widget.petId);

      if (allCheckups != null) {
        // Ordenar de más reciente a más antigua (descendente)
        final sortedCheckups = _sortCheckupsByDate(allCheckups);

        setState(() {
          checkups = sortedCheckups;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No se pudieron cargar los checkups';
        });
      }
    } catch (e) {
      print('Error loading checkups: $e');
      setState(() {
        errorMessage = 'Error al cargar el historial: $e';
        isLoading = false;
      });
    }
  }

  List<Checkup> _sortCheckupsByDate(List<Checkup> allCheckups) {
    final sortedCheckups = List<Checkup>.from(allCheckups);

    sortedCheckups.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.date);
        final dateB = DateTime.parse(b.date);
        return dateB.compareTo(dateA); // Orden descendente (más reciente primero)
      } catch (e) {
        return 0;
      }
    });

    return sortedCheckups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Historial Médico',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 25
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPetInfoSection(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckupFormScreen( petId:widget.petId, isEditMode: false),
            ),
          );

          // Si el resultado fue exitoso, recargar los datos
          if (result == true) {
            _loadData();
          }
        },
      ),
    );
  }

  Widget _buildPetInfoSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pet name and info on the left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentPet?.name ?? 'Nombre desconocido', // Usar currentPet en lugar de hardcoded
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentPet?.breed ?? 'Raza desconocida'} - ${currentPet?.age ?? 0} años', // Usar currentPet
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Sterilization dropdown on the right
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSterilizationStatus,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                dropdownColor: Colors.white,
                items: ['Sin esterilizar', 'Esterilizado'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    changeSterilize(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeSterilize(String value) {
    setState(() {
      selectedSterilizationStatus = value;
    });

    final isSterilized = value == 'Esterilizado';
    _storageService.setPetSterilized(widget.petId, isSterilized);

    print("VALOR DE: $isSterilized");

    // Actualizar el valor del currentPet
    if (currentPet != null) {
      currentPet = Pet(
        id: currentPet!.id,
        name: currentPet!.name,
        breed: currentPet!.breed,
        age: currentPet!.age,
        weight: currentPet!.weight,
        isSterilized: isSterilized,
        type: currentPet!.type,
        gender: currentPet!.gender,
        timeUnit: currentPet!.timeUnit,
        userId: currentPet!.userId,    // Actualizar el estado de esterilización
        // Agregar otros campos que tenga tu clase Pet
      );
    }

    // Debug opcional
    print('🔁 Cambio de esterilización: $value');
  }

  Widget _buildHistoryList() {
    if (isLoading) {
      return _buildHistoryLoadingList();
    }

    if (errorMessage != null) {
      return _buildErrorWidget(errorMessage!);
    }

    if (checkups.isEmpty) {
      return _buildNoHistoryWidget();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: checkups.length,
        itemBuilder: (context, index) {
          final checkup = checkups[index];
          final isLast = index == checkups.length - 1;
          return _buildTimelineItem(
            checkup: checkup,
            isLast: isLast,
            petId: checkup.petId,
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem({
    required Checkup checkup,
    required bool isLast,
    required int petId, // Agregado el petId como parámetro requerido
  }) {
    final formattedDate = _formatDate(checkup.date);
    final backgroundColor = _getBackgroundColorForType(checkup.title);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              // Circle dot
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
              ),
              // Vertical line (if not last item)
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content - Wrapped with GestureDetector to make it tappable
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckupDetailsScreen(
                      checkup: checkup,
                      petId: petId,
                    ),
                  ),
                );

                // Si el resultado fue exitoso, recargar los datos
                if (result == true) {
                  _loadData();
                }
              },
              child: Container(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 50),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and date row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            checkup.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      checkup.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLoadingList() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(4, (index) {
          final isLast = index == 3;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline column
                Column(
                  children: [
                    // Circle dot with loading
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    // Vertical line (if not last item)
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cargando historial...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Por favor espera',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNoHistoryWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_edu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Sin historial médico',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no hay registros médicos\npara esta mascota',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el historial',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${date.day.toString().padLeft(2, '0')}/${months[date.month - 1]}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getBackgroundColorForType(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('vacun')) {
      return Colors.blue;
    } else if (titleLower.contains('revisión') || titleLower.contains('general')) {
      return Colors.purple;
    } else if (titleLower.contains('desparasit')) {
      return Colors.teal;
    } else {
      return Colors.redAccent;
    }
  }
}