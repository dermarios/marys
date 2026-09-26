import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:msb_just/data/track_content.dart';
import 'package:msb_just/services/audio_service.dart';
import 'package:msb_just/widgets/player_cards.dart';
import 'liquid_player_screen.dart';

/// Letra em tela cheia com mini controle da faixa atual.
class LyricsFullscreen extends StatefulWidget {
  final AudioService audioService;
  const LyricsFullscreen({super.key, required this.audioService});

  static Route<void> rota(AudioService s) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) => LyricsFullscreen(audioService: s),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: const Cubic(.32, .72, 0, 1))),
          child: child,
        ),
      );

  @override
  State<LyricsFullscreen> createState() => _LyricsFullscreenState();
}

class _LyricsFullscreenState extends State<LyricsFullscreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blobs;
  static const _alturaLinha = 76.0;

  AudioService get _s => widget.audioService;
  AudioPlayer get _p => _s.player;

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

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final t = _s.currentTrack;
    final i = t == null ? 0 : _s.tracks.indexOf(t).clamp(0, 999);
    final letra = conteudoDe(t).letra;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0910),
      body: Stack(
        children: [
          FundoLiquido(animation: _blobs, paleta: kPaletas[i % kPaletas.length]),
          const VeuFundo(),
          SafeArea(
            child: Column(
              children: [
                // topo
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Glass(
                          radius: 19,
                          child: const SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(Icons.keyboard_arrow_down_rounded,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LETRA',
                                style: TextStyle(
                                    fontSize: 9,
                                    letterSpacing: 1.8,
                                    color: Colors.white.withOpacity(0.6))),
                            const SizedBox(height: 3),
                            Text('${t?.title ?? ''} · Pitty',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // letra
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: _p.positionStream,
                    builder: (_, snap) {
                      final ativa = linhaAtiva(_s, snap.data, letra.length);
                      return ShaderMask(
                        shaderCallback: (r) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                          stops: [0, 0.18, 0.72, 1],
                        ).createShader(r),
                        blendMode: BlendMode.dstIn,
                        child: LayoutBuilder(
                          builder: (_, c) => ClipRect(
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeInOutCubic,
                                  left: 26,
                                  right: 26,
                                  top: c.maxHeight * 0.38 - ativa * _alturaLinha - _alturaLinha / 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (var k = 0; k < letra.length; k++)
                                        _linha(letra[k], (k - ativa).abs()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // mini controle
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: _miniControle(t?.title ?? '', kPaletas[i % kPaletas.length]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linha(String texto, int distancia) {
    final opacidade = distancia == 0 ? 1.0 : (distancia == 1 ? 0.5 : 0.28);
    return SizedBox(
      height: _alturaLinha,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 450),
          scale: distancia == 0 ? 1 : 0.94,
          alignment: Alignment.centerLeft,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 450),
            opacity: opacidade,
            child: Text(
              texto,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 27,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.8,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniControle(String titulo, List<Color> paleta) {
    return Glass(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(colors: paleta.take(2).toList()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                    StreamBuilder<Duration>(
                      stream: _p.positionStream,
                      builder: (_, s) => Text(
                        '${_fmt(s.data ?? Duration.zero)} / ${_fmt(_p.duration ?? Duration.zero)}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.65)),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _s.previous();
                  if (mounted) setState(() {});
                },
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
              ),
              StreamBuilder<bool>(
                stream: _p.playingStream,
                builder: (_, s) {
                  final tocando = s.data ?? false;
                  return GestureDetector(
                    onTap: () => tocando ? _s.pause() : _s.resume(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.16),
                        border: Border.all(color: Colors.white.withOpacity(0.34)),
                      ),
                      child: Icon(tocando ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  _s.next();
                  if (mounted) setState(() {});
                },
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
              ),
            ],
          ),
          StreamBuilder<Duration>(
            stream: _p.positionStream,
            builder: (_, s) {
              final total = (_p.duration?.inMilliseconds ?? 0).toDouble();
              final v = (s.data?.inMilliseconds ?? 0).toDouble().clamp(0.0, total == 0 ? 1.0 : total);
              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.16),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  min: 0,
                  max: total == 0 ? 1 : total,
                  value: v,
                  onChanged: (x) => _s.seekTo(Duration(milliseconds: x.round())),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
