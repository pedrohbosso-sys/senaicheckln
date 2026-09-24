import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'cadastro_page.dart';
import 'detalhes_page.dart';
import 'registro_dbhelper.dart';
import 'registro_model.dart';

/// Widget reutilizável para exibir a foto de um registro
Widget fotoRegistro(String caminho, {double? largura, double altura = 200}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF14141B),
      border: Border.all(color: const Color(0x33D4AF37), width: 1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Image.file(
        File(caminho),
        width: largura,
        height: altura,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SizedBox(
          width: largura,
          height: altura,
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Color(0xFFD4AF37),
              size: 32,
            ),
          ),
        ),
      ),
    ),
  );
}

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  late Future<List<Registro>> _registros;
  bool _abrindo = false;

  @override
  void initState() {
    super.initState();
    _carregar();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recuperarFotoAposReinicio());
  }

  void _carregar() {
    setState(() {
      _registros = RegistroDbhelper.instance.listar();
    });
  }

  /// Recupera fotos tiradas pela câmera caso o sistema Android tenha reciclado o app
  Future<void> _recuperarFotoAposReinicio() async {
    if (!Platform.isAndroid) return;
    try {
      final resposta = await ImagePicker().retrieveLostData();
      if (!mounted) return;
      if (resposta.files != null && resposta.files!.isNotEmpty) {
        _abrirCadastro(fotoInicial: resposta.files!.first);
      }
    } catch (_) {}
  }

  Future<void> _abrirCadastro({XFile? fotoInicial}) async {
    setState(() => _abrindo = true);
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CadastroPage(fotoRecuperada: fotoInicial),
      ),
    );
    if (!mounted) return;
    setState(() => _abrindo = false);

    if (salvou == true) {
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color ouro = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_outlined, color: ouro, size: 22),
            const SizedBox(width: 8),
            const Text('SENAI CheckIn'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrindo ? null : () => _abrirCadastro(),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text(
          'Novo Registro',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Registro>>(
          future: _registros,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: ouro),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Erro ao carregar os registros locais.',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _carregar,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final registros = snapshot.data ?? [];

            if (registros.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E1E2A),
                          border: Border.all(color: ouro.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: ouro,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Nenhum Registro Salvo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Toque no botão abaixo para fazer um novo registro com foto, GPS e observação.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.white60, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _abrirCadastro(),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Primeiro Registro'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: ouro,
              backgroundColor: const Color(0xFF1E1E2A),
              onRefresh: () async => _carregar(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: registros.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final reg = registros[index];

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetalhesPage(registro: reg),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Miniatura da foto com borda dourada
                            fotoRegistro(
                              reg.caminhoDaFoto,
                              largura: 70,
                              altura: 70,
                            ),
                            const SizedBox(width: 14),
                            // Informações do registro
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: ouro),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          reg.dataFormatada,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reg.observacao.isEmpty ? 'Sem observação' : reg.observacao,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: reg.observacao.isEmpty ? Colors.white38 : Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 13, color: ouro),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          reg.coordenadas,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: ouro,
                                            fontFamily: 'monospace',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: ouro),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
