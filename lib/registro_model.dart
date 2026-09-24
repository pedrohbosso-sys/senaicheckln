/// Modelo de dados que representa um registro de ponto / diário de campo.
class Registro {
  final int? id;
  final DateTime dataHora;
  final double latitude;
  final double longitude;
  final double precisao;
  final String observacao;
  final String caminhoDaFoto;

  const Registro({
    this.id,
    required this.dataHora,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.observacao,
    required this.caminhoDaFoto,
  });

  /// Converte o objeto Registro em Map para salvar no SQLite
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'data_hora': dataHora.toUtc().toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'precisao': precisao,
    'observacao': observacao,
    'caminho_da_foto': caminhoDaFoto,
  };

  /// Cria um objeto Registro a partir de um Map retornado pelo SQLite
  factory Registro.fromMap(Map<String, Object?> map) => Registro(
    id: map['id'] as int?,
    dataHora: DateTime.parse(map['data_hora'] as String).toLocal(),
    latitude: (map['latitude'] as num).toDouble(),
    longitude: (map['longitude'] as num).toDouble(),
    precisao: (map['precisao'] as num).toDouble(),
    observacao: map['observacao'] as String,
    caminhoDaFoto: map['caminho_da_foto'] as String,
  );

  /// Retorna a data e hora formatada em padrão legível (ex: 17/09/2026 às 10:30)
  String get dataFormatada {
    final d = dataHora.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.day)}/${pad(d.month)}/${d.year} às ${pad(d.hour)}:${pad(d.minute)}';
  }

  /// Retorna as coordenadas formatadas
  String get coordenadas =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
