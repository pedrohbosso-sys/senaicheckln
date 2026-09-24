import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/registro_controller.dart';
import '../widgets/foto_registro.dart';
import 'cadastro_page.dart';
import 'detalhes_page.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _controller = RegistroController();
  bool _abrindo = false;

  static const Color ouro = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_atualizar);
    _controller.carregarRegistros();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recuperarFoto());
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_atualizar);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _recuperarFoto() async {
    if (!Platform.isAndroid) return;
    try {
      final resposta = await ImagePicker().retrieveLostData();
      if (!mounted) return;
      if (resposta.files != null && resposta.files!.isNotEmpty) {
        _controller.setFotoRecuperada(resposta.files!.first);
        _abrirCadastro();
      }
    } catch (_) {}
  }

  Future<void> _abrirCadastro() async {
    setState(() => _abrindo = true);
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CadastroPage(controller: _controller),
      ),
    );
    if (!mounted) return;
    setState(() => _abrindo = false);
    if (salvou == true) _controller.carregarRegistros();
  }

  @override
  Widget build(BuildContext context) {
    final registros = _controller.registros;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, color: ouro, size: 22),
            SizedBox(width: 8),
            Text('SENAI CheckIn'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _controller.carregarRegistros,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrindo ? null : _abrirCadastro,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Novo Registro',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _controller.carregando
          ? const Center(child: CircularProgressIndicator(color: ouro))
          : registros.isEmpty
              ? _buildVazio()
              : _buildLista(registros),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: ouro),
            const SizedBox(height: 24),
            const Text(
              'Nenhum Registro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque no botão abaixo para criar um registro.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _abrirCadastro,
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeiro Registro'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(List registros) {
    return RefreshIndicator(
      color: ouro,
      onRefresh: () => _controller.carregarRegistros(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: registros.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final reg = registros[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: FotoRegistro(caminho: reg.caminhoDaFoto, largura: 60, altura: 60),
              title: Text(reg.dataFormatada,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                reg.observacao.isEmpty ? 'Sem observação' : reg.observacao,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: reg.observacao.isEmpty ? Colors.white38 : Colors.white70,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: ouro),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetalhesPage(registro: reg)),
              ),
            ),
          );
        },
      ),
    );
  }
}
