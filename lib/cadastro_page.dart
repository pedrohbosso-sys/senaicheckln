import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'hardware_service.dart';
import 'registro_dbhelper.dart';
import 'registro_model.dart';
import 'registro_page.dart';

class CadastroPage extends StatefulWidget {
  final XFile? fotoRecuperada;
  const CadastroPage({super.key, this.fotoRecuperada});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _observacaoController = TextEditingController();
  final _hardware = HardwareService();
  final _audio = AudioPlayer();

  XFile? _foto;
  Position? _posicao;
  DateTime? _dataHoraGps;
  bool _carregando = false;
  String _etapaAtual = '';

  static const Color ouro = Color(0xFFD4AF37);
  static const Color ouroClaro = Color(0xFFFFE082);

  @override
  void initState() {
    super.initState();
    _foto = widget.fotoRecuperada;
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    _audio.dispose();
    super.dispose();
  }

  /// Executa operações assíncronas com feedback de progresso e tratamento de exceções
  Future<void> _executarAcao(String etapa, Future<void> Function() acao) async {
    setState(() {
      _carregando = true;
      _etapaAtual = etapa;
    });

    try {
      await acao();
    } on RecursoException catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.mensagem),
          action: erro.abrirConfiguracoes
              ? SnackBarAction(
                  label: 'Configurações',
                  onPressed: openAppSettings,
                )
              : erro.ativarGps
              ? SnackBarAction(
                  label: 'Ativar GPS',
                  onPressed: Geolocator.openLocationSettings,
                )
              : null,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro inesperado ao acessar o recurso.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Aciona a câmera para tirar foto
  Future<void> _capturarFoto() => _executarAcao('Abrindo câmera...', () async {
    final foto = await _hardware.fotografar();
    if (mounted && foto != null) {
      setState(() => _foto = foto);
    }
  });

  /// Obtém a geolocalização do GPS
  Future<void> _obterLocalizacao() => _executarAcao('Buscando sinal GPS...', () async {
    final pos = await _hardware.localizar();
    if (mounted) {
      setState(() {
        _posicao = pos;
        _dataHoraGps = DateTime.now();
      });
    }
  });

  /// Salva o registro completo (Foto + GPS + Observação) no SQLite com feedback sonoro
  Future<void> _salvarRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    if (_foto == null || _posicao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto e localização GPS são obrigatórias para o registro.'),
        ),
      );
      return;
    }

    await _executarAcao('Salvando registro...', () async {
      // Caso a posição tenha mais de 2 minutos, atualiza para garantir precisão
      if (_dataHoraGps != null &&
          DateTime.now().difference(_dataHoraGps!) > const Duration(minutes: 2)) {
        final posAtual = await _hardware.localizar();
        if (!mounted) return;
        setState(() {
          _posicao = posAtual;
          _dataHoraGps = DateTime.now();
        });
      }

      final agora = DateTime.now();
      final pastaApp = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'imagens'),
      );
      await pastaApp.create(recursive: true);

      final arquivoDestino = File(
        p.join(
          pastaApp.path,
          'registro_${agora.millisecondsSinceEpoch}${p.extension(_foto!.path)}',
        ),
      );

      try {
        // Copia o arquivo da foto para o diretório permanente do app
        await _foto!.saveTo(arquivoDestino.path);

        //  Insere os dados no banco SQLite
        await RegistroDbhelper.instance.inserir(
          Registro(
            dataHora: agora,
            latitude: _posicao!.latitude,
            longitude: _posicao!.longitude,
            precisao: _posicao!.accuracy,
            observacao: _observacaoController.text.trim(),
            caminhoDaFoto: arquivoDestino.path,
          ),
        );
      } catch (_) {
        // Limpa a foto se falhou no banco
        if (await arquivoDestino.exists()) {
          await arquivoDestino.delete();
        }
        rethrow;
      }

      // Feedback Sonoro da gravação
      try {
        await _audio.play(AssetSource('sounds/confirmacao.wav'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      } catch (_) {}

      // Feedback Visual e retorno
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de presença salvo com sucesso!'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_carregando,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Novo Registro'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Banner informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ouro.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: ouro, size: 28),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Capture a foto no local e confirme o GPS para validar seu ponto.',
                              style: TextStyle(fontSize: 13.5, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    //  Foto
                    const Text(
                      '1. FOTO DA ATIVIDADE / LOCAL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ouro,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_foto != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: fotoRegistro(_foto!.path, altura: 220),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _carregando ? null : _capturarFoto,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Tirar Outra Foto'),
                      ),
                    ] else ...[
                      InkWell(
                        onTap: _carregando ? null : _capturarFoto,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0xFF161620),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ouro.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 44, color: ouro),
                              SizedBox(height: 8),
                              Text(
                                'Toque para Abrir a Câmera',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Foto obrigatória',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Localização GPS
                    const Text(
                      '2. GEOLOCALIZAÇÃO (GPS)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ouro,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_posicao != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: ouro, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'GPS Capturado com Sucesso',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ouroClaro,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, color: Color(0x33D4AF37)),
                              Text(
                                'Latitude: ${_posicao!.latitude.toStringAsFixed(6)}',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                              Text(
                                'Longitude: ${_posicao!.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Precisão: ${_posicao!.accuracy.toStringAsFixed(1)} metros',
                                style: const TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _carregando ? null : _obterLocalizacao,
                                icon: const Icon(Icons.my_location),
                                label: const Text('Atualizar GPS'),
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  const Icon(Icons.location_off_outlined, color: Colors.white54, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Localização não capturada',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _carregando ? null : _obterLocalizacao,
                                icon: const Icon(Icons.my_location),
                                label: const Text('Obter Localização GPS'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    //  Observação
                    const Text(
                      '3. OBSERVAÇÕES E NOTAS (OPCIONAL)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ouro,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _observacaoController,
                      enabled: !_carregando,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Descreva os detalhes da visita técnica ou ponto...',
                      ),
                      validator: (valor) => (valor != null && valor.trim().length > 500)
                          ? 'Limite máximo de 500 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Botão Salvar
                    FilledButton.icon(
                      onPressed: _carregando ? null : _salvarRegistro,
                      icon: const Icon(Icons.check_circle_outline, color: Colors.black),
                      label: const Text('Salvar Registro no Banco'),
                    ),

                    // Indicador de Carregamento
                    if (_carregando) ...[
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          const LinearProgressIndicator(color: ouro),
                          const SizedBox(height: 8),
                          Text(
                            _etapaAtual,
                            style: const TextStyle(color: ouroClaro, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
