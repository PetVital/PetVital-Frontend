import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Fecha de inicio (junio 2025)
  final DateTime startDate = DateTime(2025, 6, 23);

  List<Map<String, dynamic>> _generateSubscriptions() {
    List<Map<String, dynamic>> subscriptions = [];
    DateTime currentDate = DateTime.now();
    DateTime iterationDate = DateTime(startDate.year, startDate.month, startDate.day);

    // Generar suscripciones desde junio 2025 hasta la fecha actual
    while (iterationDate.isBefore(currentDate) ||
        (iterationDate.year == currentDate.year && iterationDate.month == currentDate.month)) {
      subscriptions.add({
        'date': DateTime(iterationDate.year, iterationDate.month, iterationDate.day),
        'title': 'PetVital Mensual',
        'subtitle': 'Suscripción',
        'price': 'S/.9.90',
        'icon': Icons.pets,
      });

      // Avanzar al siguiente mes
      if (iterationDate.month == 12) {
        iterationDate = DateTime(iterationDate.year + 1, 1, iterationDate.day);
      } else {
        iterationDate = DateTime(iterationDate.year, iterationDate.month + 1, iterationDate.day);
      }
    }

    // Ordenar por fecha descendente (más reciente primero)
    subscriptions.sort((a, b) => b['date'].compareTo(a['date']));

    return subscriptions;
  }

  List<Map<String, dynamic>> _getFilteredSubscriptions() {
    List<Map<String, dynamic>> subscriptions = _generateSubscriptions();

    if (_searchQuery.isEmpty) {
      return subscriptions;
    }

    return subscriptions.where((subscription) {
      return subscription['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          subscription['subtitle'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _formatDate(DateTime date) {
    const List<String> monthNames = [
      '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SET', 'OCT', 'NOV', 'DIC'
    ];

    return '${date.day} ${monthNames[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubscriptions = _getFilteredSubscriptions();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Historial de pagos',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),

          // Lista de suscripciones
          Expanded(
            child: filteredSubscriptions.isEmpty
                ? const Center(
              child: Text(
                'No hay suscripciones disponibles',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredSubscriptions.length,
              itemBuilder: (context, index) {
                final subscription = filteredSubscriptions[index];
                final date = subscription['date'] as DateTime;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.0, top: index == 0 ? 0 : 24.0),
                      child: Text(
                        _formatDate(date),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    // Tarjeta de suscripción
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Fila principal con ícono, texto y precio
                            Row(
                              children: [
                                // Ícono
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF8158B7),
                                        Color(0xFF35B4DD),
                                        Color(0xFF40D1B6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    subscription['icon'],
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Texto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subscription['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        subscription['subtitle'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Precio
                                Text(
                                  subscription['price'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),

                            // Línea divisoria
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              height: 1,
                              color: Colors.grey[300],
                            ),

                            // Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  subscription['price'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}