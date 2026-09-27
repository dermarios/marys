import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/liquid_player_screen.dart';
import '../services/audio_service.dart';

/// Envolve qualquer tela e coloca o player flutuante no rodapé.
///
///   PlayerShell(audioService: s, child: LibraryScreen(audioService: s))
///
/// Pistas de que o mini player expande:
///  1. alça no topo (padrão de sheet do iOS)
///  2. arrastar para cima: o player expandido acompanha o dedo
///  3. dica de primeira vez: o mini "espia" para cima + balão
///     (mostrada até [PlayerShell.vezesDica] vezes; depois de o usuário
///      expandir uma vez, não aparece mais)
class PlayerShell extends StatefulWidget {
  final AudioService audioService;
  final Widget child;
  static const vezesDica = 3;
  const PlayerShell({super.key, required this.audioService, required this.child});

  @override
  State<PlayerShell> createState() => _PlayerShellState();
}

class _PlayerShellState extends State<PlayerShell> with TickerProviderStateMixin {
  static const _kVistas = 'mini_hint_vistas';
  static const _kExpandiu = 'mini_hint_expandiu';

  late final AnimationController _peek =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  bool _mostrarBalao = false;
  double _arrasto = 0; // px (negativo = para cima)

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), _talvezMostrarDica);
  }

  @override
  void dispose() {
    _peek.dispose();
    super.dispose();
  }

  Future<void> _talvezMostrarDica() async {
    if (!mounted || widget.audioService.currentTrack == null) return;
    final p = await SharedPreferences.getInstance();
    if (p.getBool(_kExpandiu) == true) return;
    final vistas = p.getInt(_kVistas) ?? 0;
    if (vistas >= PlayerShell.vezesDica) return;
    await p.setInt(_kVistas, vistas + 1);
    if (!mounted) return;
    setState(() => _mostrarBalao = true);
    _peek.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 3400), () {
      if (mounted) setState(() => _mostrarBalao = false);
    });
  }

  Future<void> _expandir() async {
    setState(() {
      _mostrarBalao = false;
      _arrasto = 0;
    });
    (await SharedPreferences.getInstance()).setBool(_kExpandiu, true);
    if (!mounted) return;
    Navigator.of(context).push(rotaPlayerExpandido(widget.audioService));
  }

  /// Quique do "peek": sobe 12 px, volta, sobe 5 px, volta.
  double get _peekY {
    final t = _peek.value;
    if (t == 0 || t == 1) return 0;
    const pts = [0.0, -12.0, 0.0, -5.0, 0.0];
    final seg = (t * 4).clamp(0, 3.999);
    final i = seg.floor();
    final f = Curves.easeOut.transform((seg - i).toDouble());
    return pts[i] + (pts[i + 1] - pts[i]) * f;
  }

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context).padding.bottom + 8;
    final h = MediaQuery.of(context).size.height;
    final progresso = (-_arrasto / 220).clamp(0.0, 1.0);

    return Stack(
      children: [
        Positioned.fill(child: widget.child),

        // prévia do player expandido acompanhando o dedo
        if (_arrasto < 0)
          Positioned(
            left: 0,
            right: 0,
            top: h + _arrasto,
            height: h,
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                child: LiquidPlayerScreen(audioService: widget.audioService, expandido: true),
              ),
            ),
          ),

        // balão de dica
        Positioned(
          left: 0,
          right: 0,
          bottom: base + 70 + 14,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _mostrarBalao ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 500),
                curve: const Cubic(.32, .72, 0, 1),
                offset: _mostrarBalao ? Offset.zero : const Offset(0, 0.3),
                child: const Center(child: _BalaoDica()),
              ),
            ),
          ),
        ),

        // mini player arrastável
        Positioned(
          left: 10,
          right: 10,
          bottom: base,
          child: AnimatedBuilder(
            animation: _peek,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _peekY + _arrasto * 0.3),
              child: Opacity(opacity: 1 - progresso, child: child),
            ),
            child: GestureDetector(
              onTap: _expandir,
              onVerticalDragStart: (_) => setState(() => _mostrarBalao = false),
              onVerticalDragUpdate: (d) =>
                  setState(() => _arrasto = (_arrasto + d.delta.dy).clamp(-h, 0.0)),
              onVerticalDragEnd: (d) {
                final rapido = (d.primaryVelocity ?? 0) < -600;
                if (_arrasto < -90 || rapido) {
                  _expandir();
                } else {
                  setState(() => _arrasto = 0);
                }
              },
              child: MiniPlayer(audioService: widget.audioService, peek: _peek),
            ),
          ),
        ),
      ],
    );
  }
}

class _BalaoDica extends StatelessWidget {
  const _BalaoDica();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF14121E).withOpacity(0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.white),
              SizedBox(width: 8),
              Text('Deslize para ver letra, clipe e mais',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rota do player expandido: sobe de baixo, estilo Spotify.
Route<void> rotaPlayerExpandido(AudioService s) => PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 520),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => LiquidPlayerScreen(audioService: s, expandido: true),
      transitionsBuilder: (_, a, __, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: const Cubic(.32, .72, 0, 1))),
        child: child,
      ),
    );

class MiniPlayer extends StatelessWidget {
  final AudioService audioService;

  /// Animação de "peek" do PlayerShell — acende a alça junto com o quique.
  final Animation<double>? peek;
  const MiniPlayer({super.key, required this.audioService, this.peek});

  AudioPlayer get _p => audioService.player;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: StreamBuilder<PlayerState>(
        stream: _p.playerStateStream,
        builder: (context, snap) {
          final track = audioService.currentTrack;
          if (track == null) return const SizedBox.shrink();
          final tocando = snap.data?.playing ?? false;
          final i = audioService.tracks.indexOf(track).clamp(0, 999);
          final paleta = kPaletas[i % kPaletas.length];

          return Glass(
              radius: 22,
              child: SizedBox(
                height: 70,
                child: Stack(
                  children: [
                    // alça
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: peek ?? kAlwaysDismissedAnimation,
                          builder: (_, __) {
                            final v = peek == null
                                ? 0.0
                                : Curves.easeInOut.transform(1 - (peek!.value * 2 - 1).abs());
                            return Container(
                              width: 36 + 12 * v,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5 + 0.5 * v),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 8, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: paleta.take(2).toList(),
                              ),
                              image: track.imageAsset == null
                                  ? null
                                  : DecorationImage(
                                      image: AssetImage(track.imageAsset!), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(track.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                Text('Pitty',
                                    style: TextStyle(
                                        fontSize: 11.5, color: Colors.white.withOpacity(0.65))),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                tocando ? audioService.pause() : audioService.resume(),
                            icon: Icon(tocando ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white, size: 26),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 0,
                      child: StreamBuilder<Duration>(
                        stream: _p.positionStream,
                        builder: (_, pos) {
                          final total = _p.duration?.inMilliseconds ?? 0;
                          final f = total == 0
                              ? 0.0
                              : ((pos.data?.inMilliseconds ?? 0) / total).clamp(0.0, 1.0);
                          return Container(
                            height: 2,
                            color: Colors.white.withOpacity(0.16),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: f,
                              child: Container(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          );
        },
      ),
    );
  }
}

