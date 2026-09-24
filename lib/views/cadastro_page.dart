import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/registro_controller.dart';
import '../widgets/foto_registro.dart';

class CadastroPage extends StatefulWidget {
  final RegistroController controller;
  const CadastroPage({super.key, required this.controller});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  bool _salvando = false;

  static const Color ouro = Color(0xFFD4AF37);

  RegistroController get ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    ctrl.addListener(_atualizar);
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ctrl.removeListener(_atualizar);
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    final erro = await ctrl.capturarFoto();
    if (erro != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  Future<void> _obterGps() async {
    final erro = await ctrl.obterLocalizacao();
    if (erro != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final erro = await ctrl.salvarRegistro();
    if (!mounted) return;
    setState(() => _salvando = false);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo com sucesso!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_salvando,
      child: Scaffold(
        appBar: AppBar(title: const Text('Novo Registro')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // === FOTO ===
              _secaoTitulo('1. FOTO'),
              const SizedBox(height: 8),
              if (ctrl.foto != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FotoRegistro(caminho: ctrl.foto!.path, altura: 220),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _salvando ? null : _tirarFoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Tirar Outra'),
                ),
              ] else
                _botaoFoto(),
              const SizedBox(height: 20),

              // === GPS ===
              _secaoTitulo('2. LOCALIZAÇÃO GPS'),
              const SizedBox(height: 8),
              _cardGps(),
              const SizedBox(height: 20),

              // === OBSERVAÇÃO ===
              _secaoTitulo('3. OBSERVAÇÃO (OPCIONAL)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: ctrl.observacaoController,
                enabled: !_salvando,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Descreva os detalhes...',
                ),
                validator: (v) => (v != null && v.trim().length > 500)
                    ? 'Máximo 500 caracteres.'
                    : null,
              ),
              const SizedBox(height: 24),

              // === SALVAR ===
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: const Icon(Icons.check_circle_outline, color: Colors.black),
                label: const Text('Salvar Registro'),
              ),

              if (_salvando) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(color: ouro),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _secaoTitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: ouro,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _botaoFoto() {
    return InkWell(
      onTap: _salvando ? null : _tirarFoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF161620),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ouro.withValues(alpha: 0.5)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 40, color: ouro),
            SizedBox(height: 8),
            Text('Toque para Abrir a Câmera',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _cardGps() {
    final pos = ctrl.posicao;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pos != null) ...[
              Row(children: [
                const Icon(Icons.check_circle, color: ouro, size: 20),
                const SizedBox(width: 8),
                const Text('GPS Capturado',
                    style: TextStyle(fontWeight: FontWeight.bold, color: ouro)),
              ]),
              const Divider(height: 20, color: Color(0x33D4AF37)),
              Text('Lat: ${pos.latitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontFamily: 'monospace')),
              Text('Lng: ${pos.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontFamily: 'monospace')),
              Text('Precisão: ${pos.accuracy.toStringAsFixed(1)}m',
                  style: const TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _salvando ? null : _obterGps,
                icon: const Icon(Icons.my_location),
                label: const Text('Atualizar GPS'),
              ),
            ] else ...[
              const Text('Localização não capturada',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _salvando ? null : _obterGps,
                icon: const Icon(Icons.my_location),
                label: const Text('Obter GPS'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
