import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/registro.dart';
import '../services/database_service.dart';
import '../services/hardware_service.dart';

class RegistroController extends ChangeNotifier {
  final _db = DatabaseService.instance;
  final _hardware = HardwareService();
  final _audio = AudioPlayer();

  List<Registro> registros = [];
  bool carregando = false;
  String etapaAtual = '';

  // Estado do formulário de cadastro
  XFile? foto;
  Position? posicao;
  DateTime? _dataHoraGps;
  final observacaoController = TextEditingController();

  /// Carrega todos os registros do banco
  Future<void> carregarRegistros() async {
    carregando = true;
    etapaAtual = 'Carregando registros...';
    notifyListeners();

    try {
      registros = await _db.listar();
    } catch (_) {
      registros = [];
    }

    carregando = false;
    notifyListeners();
  }

  /// Captura foto pela câmera
  Future<String?> capturarFoto() async {
    try {
      final novaFoto = await _hardware.fotografar();
      if (novaFoto != null) {
        foto = novaFoto;
        notifyListeners();
      }
      return null; // sem erro
    } on RecursoException catch (e) {
      return e.mensagem;
    } catch (_) {
      return 'Erro ao acessar a câmera.';
    }
  }

  /// Obtém localização GPS
  Future<String?> obterLocalizacao() async {
    try {
      posicao = await _hardware.localizar();
      _dataHoraGps = DateTime.now();
      notifyListeners();
      return null; // sem erro
    } on RecursoException catch (e) {
      return e.mensagem;
    } catch (_) {
      return 'Erro ao obter localização.';
    }
  }

  /// Salva o registro no banco de dados
  Future<String?> salvarRegistro() async {
    if (foto == null || posicao == null) {
      return 'Foto e localização GPS são obrigatórias.';
    }

    carregando = true;
    etapaAtual = 'Salvando registro...';
    notifyListeners();

    try {
      // Atualiza GPS se tiver mais de 2 min
      if (_dataHoraGps != null &&
          DateTime.now().difference(_dataHoraGps!) > const Duration(minutes: 2)) {
        posicao = await _hardware.localizar();
        _dataHoraGps = DateTime.now();
      }

      final agora = DateTime.now();
      final pasta = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'imagens'),
      );
      await pasta.create(recursive: true);

      final destino = File(
        p.join(pasta.path, 'reg_${agora.millisecondsSinceEpoch}${p.extension(foto!.path)}'),
      );

      await foto!.saveTo(destino.path);

      try {
        await _db.inserir(
          Registro(
            dataHora: agora,
            latitude: posicao!.latitude,
            longitude: posicao!.longitude,
            precisao: posicao!.accuracy,
            observacao: observacaoController.text.trim(),
            caminhoDaFoto: destino.path,
          ),
        );
      } catch (_) {
        if (await destino.exists()) await destino.delete();
        rethrow;
      }

      // Som de confirmação
      try {
        await _audio.play(AssetSource('sounds/confirmacao.wav'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      } catch (_) {}

      // Limpa o formulário
      limparFormulario();
      await carregarRegistros();

      carregando = false;
      notifyListeners();
      return null; // sucesso
    } catch (_) {
      carregando = false;
      notifyListeners();
      return 'Erro ao salvar o registro.';
    }
  }

  /// Limpa os campos do formulário
  void limparFormulario() {
    foto = null;
    posicao = null;
    _dataHoraGps = null;
    observacaoController.clear();
  }

  /// Define foto recuperada (caso Android tenha reciclado o app)
  void setFotoRecuperada(XFile? fotoRecuperada) {
    if (fotoRecuperada != null) {
      foto = fotoRecuperada;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    observacaoController.dispose();
    _audio.dispose();
    super.dispose();
  }
}
