import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/audio_service.dart';
import 'liquid_player_screen.dart';

/// Créditos do app: Versão, Reprodutor de áudio, Phonolite e Tecnologia.
///
/// O mini player vem do PlayerShell:
///   PlayerShell(audioService: s, child: CreditsScreen(audioService: s))
///
/// Valores de EXEMPLO — confirme no pubspec.yaml.
class AppInfo {
  static const nome = "Mary's Secret Box";
  static const empresa = 'Phonolite';
  static const versao = '1.0.0';
  static const build = '1';
  static const canal = 'Produção';
  static const plataforma = 'iOS';
}

const kAudioInfo = <(String, String)>[
  ('Motor', 'just_audio'),
  ('Versão', '0.9.x'),
  ('Formatos', 'MP3'),
  ('Reprodução', 'Offline · arquivos locais'),
  ('Sessão de áudio', 'Segundo plano'),
];

class PhonoliteInfo {
  static const descricao =
      'Texto de exemplo sobre a Phonolite e seu papel no app — substitua pela descrição oficial.';
  static const url = 'https://example.com';
  static const linhas = <(String, String)>[
    ('Papel', 'A definir'),
    ('Versão', '—'),
  ];
}

const kTecnologias = <(String nome, String papel, String versao, String marca)>[
  ('Flutter', 'Framework de interface', '3.x', 'F'),
  ('Dart', 'Linguagem', '3.x', 'D'),
  ('just_audio', 'Reprodução de áudio', '0.9.x', 'ja'),
  ('url_launcher', 'Links para Spotify, Apple Music e Deezer', '6.x', 'ul'),
  ('shared_preferences', 'Preferências locais', '2.x', 'sp'),
  ('Liquid Glass', 'BackdropFilter + blend modes', '—', 'LG'),
];

class CreditsScreen extends StatefulWidget {
  final AudioService audioService;
  const CreditsScreen({super.key, required this.audioService});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

enum _Atualizacao { parado, verificando, ok }

class _CreditsScreenState extends State<CreditsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _blobs;
  final GlassMode _mode = GlassMode.fosco;
  _Atualizacao _upd = _Atualizacao.parado;

  @override
  void initState() {
    super.initState();
    _blobs = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
  }

  @override
  void dispose() {
    _blobs.dispose();
    super.dispose();
  }

  /// Troque pela checagem real (App Store / backend).
  Future<void> _verificarAtualizacao() async {
    if (_upd == _Atualizacao.verificando) return;
    setState(() => _upd = _Atualizacao.verificando);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _upd = _Atualizacao.ok);
  }

  @override
  Widget build(BuildContext context) {
    final paleta = kPaletas[0];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0910),
      body: Stack(
        children: [
          FundoLiquido(animation: _blobs, paleta: paleta),
          const VeuFundo(),
          SafeArea(
            bottom: false,
            child: ListView(
              // 120 px no fim para o mini player
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SOBRE O APP',
                          style: TextStyle(
                              fontSize: 9, letterSpacing: 2, color: Colors.white.withOpacity(0.55))),
                      const SizedBox(height: 4),
                      const Text('Créditos',
                          style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.8,
                              color: Colors.white)),
                    ],
                  ),
                ),
                _hero(paleta),
                const SizedBox(height: 12),
                _card(
                  icone: Icons.timer_outlined,
                  titulo: 'Versão',
                  filhos: [
                    _linhas(const [
                      ('Versão', AppInfo.versao),
                      ('Build', AppInfo.build),
                      ('Canal', AppInfo.canal),
                      ('Plataforma', AppInfo.plataforma),
                    ]),
                    const SizedBox(height: 8),
                    _botao(
                      switch (_upd) {
                        _Atualizacao.verificando => 'Verificando…',
                        _Atualizacao.ok => 'Você está na versão mais recente',
                        _Atualizacao.parado => 'Verificar atualizações',
                      },
                      _verificarAtualizacao,
                      destaque: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _card(
                  icone: Icons.graphic_eq_rounded,
                  titulo: 'Reprodutor de áudio',
                  filhos: [_linhas(kAudioInfo)],
                ),
                const SizedBox(height: 12),
                _card(
                  icone: Icons.album_outlined,
                  titulo: 'Phonolite',
                  filhos: [
                    const SizedBox(height: 12),
                    Text(PhonoliteInfo.descricao,
                        style: TextStyle(
                            fontSize: 13, height: 1.55, color: Colors.white.withOpacity(0.78))),
                    _linhas(PhonoliteInfo.linhas),
                    const SizedBox(height: 8),
                    _botao('Conhecer a Phonolite', () {
                      launchUrl(Uri.parse(PhonoliteInfo.url), mode: LaunchMode.externalApplication);
                    }, icone: Icons.north_east_rounded),
                  ],
                ),
                const SizedBox(height: 12),
                _card(
                  icone: Icons.code_rounded,
                  titulo: 'Tecnologia',
                  filhos: [
                    const SizedBox(height: 12),
                    for (var i = 0; i < kTecnologias.length; i++) ...[
                      _tech(kTecnologias[i], kPaletas[i % kPaletas.length]),
                      if (i < kTecnologias.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '© 2026 ${AppInfo.empresa} · Todos os direitos reservados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, height: 1.6, color: Colors.white.withOpacity(0.55)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(List<Color> paleta) {
    return Glass(
      mode: _mode,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 34,
                      offset: const Offset(0, 14)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset('assets/app-icon.jpeg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 14),
            const Text(AppInfo.nome,
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: Colors.white)),
            const SizedBox(height: 3),
            Text('por ${AppInfo.empresa}',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4ADE80),
                      boxShadow: [BoxShadow(color: Color(0xFF4ADE80), blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('v${AppInfo.versao} · atualizado',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required IconData icone, required String titulo, required List<Widget> filhos}) {
    return Glass(
      mode: _mode,
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.16)),
                ),
                child: Icon(icone, size: 17, color: Colors.white),
              ),
              const SizedBox(width: 11),
              Text(titulo.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                      color: Colors.white)),
            ],
          ),
          ...filhos,
        ],
      ),
    );
  }

  Widget _linhas(List<(String, String)> pares) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          for (var i = 0; i < pares.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pares[i].$1,
                      style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.64))),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(pares[i].$2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()])),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _botao(String rotulo, VoidCallback onTap, {bool destaque = false, IconData? icone}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          color: Colors.white.withOpacity(destaque ? 0.14 : 0.08),
          border: Border.all(color: Colors.white.withOpacity(destaque ? 0.3 : 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rotulo,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white)),
            if (icone != null) ...[
              const SizedBox(width: 8),
              Icon(icone, size: 13, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tech((String, String, String, String) t, List<Color> cores) {
    final (nome, papel, versao, _) = t;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(papel,
                    style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.62))),
              ],
            ),
          ),
          Text(versao,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.6))),
        ],
      ),
    );
  }
}
