import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:msb_just/services/audio_service.dart';
import 'package:msb_just/models/album.dart';
import 'liquid_player_screen.dart';
import 'library_screen.dart';

/// Tela "Artista" — evolução da SideScreen: a foto sangra na tela inteira e os
/// blobs líquidos entram POR CIMA dela em blend soft-light / screen, então a
/// cor se funde à imagem em vez de ficar atrás.
class ArtistScreen extends StatefulWidget {
  final AudioService audioService;
  const ArtistScreen({super.key, required this.audioService});

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _blobs;
  final GlassMode _mode = GlassMode.fosco;
  bool _curtido = false;
  bool _carregandoAlbum = false;

  static const _foto = 'assets/33898823_1876726852378352_5577473749248114688_n.jpg';

  /// Mais tocadas — valores de exemplo. Se o título existir em tracks.json,
  /// o toque toca a faixa local.
  static const _top = [
    (titulo: 'Máscara', plays: '2,4 mi', dur: '4:03'),
    (titulo: 'Equalize', plays: '1,9 mi', dur: '4:44'),
    (titulo: 'Teto de Vidro', plays: '1,3 mi', dur: '3:52'),
    (titulo: 'Na Sua Estante', plays: '980 mil', dur: '4:12'),
    (titulo: 'Memórias', plays: '720 mil', dur: '3:41'),
  ];

  @override
  void initState() {
    super.initState();
    _blobs = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    widget.audioService.loadTracks().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _blobs.dispose();
    super.dispose();
  }

  void _abrirPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiquidPlayerScreen(audioService: widget.audioService, expandido: false),
      ),
    );
  }

  void _carregarAlbum(Album album) {
    if (_carregandoAlbum) {
      print('[ArtistScreen] Já carregando um álbum, ignorando novo toque');
      return;
    }

    _carregandoAlbum = true;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    widget.audioService.playAlbum(album).then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Erro ao carregar álbum: $e')),
        );
      }
      print('[ArtistScreen] ERRO ao carregar álbum: $e');
    }).whenComplete(() {
      _carregandoAlbum = false;
    });

    _abrirPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1 · foto sangrada
          Positioned.fill(
            child: Image.asset(
              _foto,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF14121C)),
            ),
          ),
          // 2 · base escura (mantém a leitura da foto)
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),
          // 3 · blobs mesclados COM a imagem
          _blobsMesclados(BlendMode.softLight, 0.95, 54),
          _blobsMesclados(BlendMode.screen, 0.34, 70),
          // 4 · degradê de contraste
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF08070C).withOpacity(0.72),
                    const Color(0xFF08070C).withOpacity(0.12),
                    const Color(0xFF08070C).withOpacity(0.60),
                    const Color(0xFF08070C).withOpacity(0.95),
                  ],
                  stops: const [0, 0.26, 0.62, 1],
                ),
              ),
            ),
          ),
          // 5 · conteúdo
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              // o conteúdo rola por cima da foto fixa; 120 px para o player flutuante
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Glass(
                          mode: _mode,
                          radius: 19,
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(Icons.chevron_left_rounded,
                                size: 22, color: Colors.white.withOpacity(0.9)),
                          ),
                        ),
                      ),
                      Glass(
                        mode: _mode,
                        radius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                            const SizedBox(width: 7),
                            Text('AO VIVO EM BREVE',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.4,
                                    color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 300),
                  Text('LANÇAMENTO',
                      style: TextStyle(
                          fontSize: 9, letterSpacing: 3, color: Colors.white.withOpacity(0.7))),
                  const SizedBox(height: 10),
                  const Text(
                    'Beyond Smoke',
                    style: TextStyle(
                      fontSize: 62,
                      height: 0.92,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 40, offset: Offset(0, 8))],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 300,
                    child: Text(
                      'Mary\'s Secret Box - Beyond Smoke (single) Jul. de 2018',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w300,
                          height: 1.55,
                          color: Colors.white.withOpacity(0.78)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final currentAlbum = widget.audioService.currentAlbum ?? kAlbums.first;
                            widget.audioService.playAlbum(currentAlbum);
                            _abrirPlayer();
                          },
                          child: Glass(
                            mode: _mode,
                            radius: 26,
                            child: SizedBox(
                              height: 52,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text('Tocar',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _botaoVidro(Icons.shuffle_rounded, () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => LibraryScreen(audioService: widget.audioService),
                        ));
                      }),
                      const SizedBox(width: 10),
                      _botaoVidro(
                        _curtido ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        () => setState(() => _curtido = !_curtido),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _cabecalho('Discografia', '${kAlbums.length} LANÇAMENTOS'),
                  const SizedBox(height: 11),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: kAlbums.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final album = kAlbums[i];
                        return GestureDetector(
                          onTap: _carregandoAlbum ? null : () {
                            _carregarAlbum(album);
                          },
                          child: Opacity(
                            opacity: _carregandoAlbum ? 0.5 : 1.0,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: AssetImage(album.coverAsset),
                                    fit: BoxFit.cover,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 140,
                                child: Text(
                                  album.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _cabecalho('Mais tocadas', 'ESTE MÊS'),
                  const SizedBox(height: 11),
                  Glass(
                    mode: _mode,
                    radius: 24,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        for (var i = 0; i < _top.length; i++) _linhaTop(i),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho(String titulo, String meta) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white)),
          Text(meta,
              style: TextStyle(
                  fontSize: 10, letterSpacing: 1.6, color: Colors.white.withOpacity(0.62))),
        ],
      );

  void _tocarPorTitulo(String titulo, {bool album = false}) {
    final s = widget.audioService;
    final alvo = s.tracks.where((t) => t.title.toLowerCase() == titulo.toLowerCase());
    if (alvo.isEmpty) return;

    s.play(alvo.first).then((_) {
      if (mounted) setState(() {});
    }).catchError((e) {
      print('Erro ao tocar $titulo: $e');
    });

    if (album) _abrirPlayer();
  }

  Widget _linhaTop(int i) {
    final t = _top[i];
    final atual = widget.audioService.currentTrack?.title.toLowerCase() == t.titulo.toLowerCase();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _tocarPorTitulo(t.titulo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: atual ? Colors.white.withOpacity(0.12) : Colors.transparent,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 19,
              child: Text('${i + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(atual ? 1 : 0.55))),
            ),
            const SizedBox(width: 11),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: kPaletas[i % kPaletas.length].take(2).toList(),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                  Text('${t.plays} reproduções',
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.62))),
                ],
              ),
            ),
            Text(t.dur,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.58))),
          ],
        ),
      ),
    );
  }

  Widget _botaoVidro(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Glass(
          mode: _mode,
          radius: 26,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(icon, size: 19, color: Colors.white),
          ),
        ),
      );

  /// Camada de blobs desfocados aplicada SOBRE a foto com blend mode.
  Widget _blobsMesclados(BlendMode blend, double opacity, double sigma) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: BlendMask(
            blendMode: blend,
            child: AnimatedBuilder(
              animation: _blobs,
              builder: (context, _) {
                final t = _blobs.value * 2 * math.pi;
                final c = kPaletas[0];
                return ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: Stack(
                    children: [
                      _blob(c[0], -0.7 + 0.12 * math.sin(t), -0.6 + 0.1 * math.cos(t),
                          1 + 0.12 * math.sin(t)),
                      _blob(c[1], 0.8 + 0.1 * math.cos(t * 0.8), 0.0 + 0.12 * math.sin(t * 0.8),
                          1.05 + 0.1 * math.cos(t)),
                      _blob(c[2], -0.6 + 0.1 * math.cos(t * 1.2), 0.8 + 0.1 * math.sin(t * 1.2),
                          1 + 0.14 * math.sin(t * 1.4)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _blob(Color color, double x, double y, double scale) => Align(
        alignment: Alignment(x, y),
        child: Transform.scale(
          scale: scale,
          child: FractionallySizedBox(
            widthFactor: 0.85,
            heightFactor: 0.55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
              ),
            ),
          ),
        ),
      );
}

/// Aplica um BlendMode entre o filho e tudo que já foi pintado atrás dele.
class BlendMask extends SingleChildRenderObjectWidget {
  final BlendMode blendMode;
  const BlendMask({super.key, required this.blendMode, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBlendMask(blendMode) as RenderObject;

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderBlendMask).blendMode = blendMode;
  }
}

class _RenderBlendMask extends RenderProxyBox {
  BlendMode blendMode;
  _RenderBlendMask(this.blendMode);

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.saveLayer(offset & size, Paint()..blendMode = blendMode);
    super.paint(context, offset);
    context.canvas.restore();
  }
}
