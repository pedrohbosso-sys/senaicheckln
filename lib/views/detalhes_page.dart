import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/registro.dart';
import '../widgets/foto_registro.dart';

class DetalhesPage extends StatelessWidget {
  final Registro registro;
  const DetalhesPage({super.key, required this.registro});

  static const Color ouro = Color(0xFFD4AF37);

  Future<void> _abrirMapa(BuildContext context) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${registro.latitude},${registro.longitude}',
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o mapa.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro #${registro.id ?? "—"}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: FotoRegistro(caminho: registro.caminhoDaFoto, altura: 280),
          ),
          const SizedBox(height: 20),

          // Data
          _card(
            icone: Icons.calendar_today,
            titulo: 'Data e Horário',
            conteudo: Text(registro.dataFormatada,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),

          // GPS
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconTitulo(Icons.location_on_outlined, 'Localização GPS'),
                  const Divider(height: 24, color: Color(0x33D4AF37)),
                  _linha('Latitude', registro.latitude.toStringAsFixed(6)),
                  _linha('Longitude', registro.longitude.toStringAsFixed(6)),
                  _linha('Precisão', '${registro.precisao.toStringAsFixed(1)}m'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _abrirMapa(context),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Abrir no Google Maps'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Observação
          _card(
            icone: Icons.notes,
            titulo: 'Observação',
            conteudo: Text(
              registro.observacao.isEmpty ? 'Nenhuma observação.' : registro.observacao,
              style: TextStyle(
                color: registro.observacao.isEmpty ? Colors.white38 : Colors.white,
                fontStyle: registro.observacao.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required IconData icone, required String titulo, required Widget conteudo}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconTitulo(icone, titulo),
            const Divider(height: 24, color: Color(0x33D4AF37)),
            conteudo,
          ],
        ),
      ),
    );
  }

  Widget _iconTitulo(IconData icone, String titulo) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF382F16),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icone, color: ouro, size: 22),
      ),
      const SizedBox(width: 14),
      Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _linha(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(color: Colors.white70)),
          Text(valor, style: const TextStyle(color: ouro, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
