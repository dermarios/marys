import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:msb_just/screens/liquid_player_screen.dart';
import 'package:msb_just/services/audio_service.dart';

/// Envolve qualquer tela e coloca o player flutuante no rodapé.
///
///   PlayerShell(audioService: s, child: LibraryScreen(audioService: s))
class PlayerShell extends StatelessWidget {
  final AudioService audioService;
  final Widget child;
  const PlayerShell({super.key, required this.audioService, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        audioService.currentTrackNotifier,
        audioService.playerExpandedNotifier,
      ]),
      builder: (context, _) {
        return Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).padding.bottom + 8,
              child: MiniPlayer(audioService: audioService),
            ),
          ],
        );
      },
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
  const MiniPlayer({super.key, required this.audioService});

  AudioPlayer get _p => audioService.player;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          audioService.currentTrackNotifier,
          audioService.currentAlbumNotifier,
          audioService.playerExpandedNotifier,
        ]),
        builder: (context, _) {
          final track = audioService.currentTrack;
          if (track == null) {
            return const SizedBox.shrink();
          }
          if (audioService.playerExpandedNotifier.value) {
            return const SizedBox.shrink();
          }
          return StreamBuilder<PlayerState>(
            stream: _p.playerStateStream,
            builder: (context, snap) {
              final tocando = snap.data?.playing ?? false;
              final faixas = audioService.currentAlbumNotifier.value?.tracks ??
                  audioService.tracks;
              final i = faixas.indexOf(track).clamp(0, 999);
              final paleta = kPaletas[i % kPaletas.length];

          return GestureDetector(
            onTap: () => Navigator.of(context).push(rotaPlayerExpandido(audioService)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Glass(
                  radius: 22,
                  child: SizedBox(
                    height: 64,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
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
                                Text('Mary\'s Secret Box',
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
                ),
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: BotaoExpandir(
                      onTap: () => Navigator.of(context).push(rotaPlayerExpandido(audioService)),
                    ),
                  ),
                ),
              ],
            ),
            );
            },
          );
        },
      ),
    );
  }
}

/// Pílula de vidro discreta (36×20) com seta que "respira" 1,5 px.
class BotaoExpandir extends StatefulWidget {
  final VoidCallback onTap;
  const BotaoExpandir({super.key, required this.onTap});

  @override
  State<BotaoExpandir> createState() => _BotaoExpandirState();
}

class _BotaoExpandirState extends State<BotaoExpandir> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Expandir player',
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 36,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF14121E).withOpacity(0.72),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, -1.5 * Curves.easeInOut.transform(_c.value)),
                    child: child,
                  ),
                  child: const Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
