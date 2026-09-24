import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'registro_model.dart';
import 'registro_page.dart';

class DetalhesPage extends StatelessWidget {
  final Registro registro;
  const DetalhesPage({super.key, required this.registro});

  static const Color ouro = Color(0xFFD4AF37);
  static const Color ouroClaro = Color(0xFFFFE082);

  /// Abre as coordenadas diretamente no aplicativo de mapas (Google Maps)
  Future<void> _abrirNoMapa(BuildContext context) async {
    try {
      final uri = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '${registro.latitude},${registro.longitude}',
      });

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Não foi possível abrir o mapa.');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o mapa externo.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro #${registro.id ?? "—"}'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Foto do Registro
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: fotoRegistro(registro.caminhoDaFoto, altura: 280),
                ),
                const SizedBox(height: 20),

                // Card de Data e Hora
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF382F16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_today, color: ouro, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data e Horário',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                registro.dataFormatada,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card de Localização GPS
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF382F16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_on_outlined, color: ouro, size: 22),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Localização GPS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: Color(0x33D4AF37)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Latitude:', style: TextStyle(color: Colors.white70)),
                            SelectableText(
                              registro.latitude.toStringAsFixed(6),
                              style: const TextStyle(color: ouro, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Longitude:', style: TextStyle(color: Colors.white70)),
                            SelectableText(
                              registro.longitude.toStringAsFixed(6),
                              style: const TextStyle(color: ouro, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Precisão:', style: TextStyle(color: Colors.white70)),
                            Text(
                              '${registro.precisao.toStringAsFixed(1)} metros',
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _abrirNoMapa(context),
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Abrir no Google Maps'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card de Observação
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF382F16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.notes, color: ouro, size: 22),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Observação / Diário',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: Color(0x33D4AF37)),
                        Text(
                          registro.observacao.isEmpty
                              ? 'Nenhuma observação informada.'
                              : registro.observacao,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: registro.observacao.isEmpty ? Colors.white38 : Colors.white,
                            fontStyle: registro.observacao.isEmpty ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
