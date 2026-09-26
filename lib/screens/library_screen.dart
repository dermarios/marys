import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:msb_just/models/track.dart';
import 'package:msb_just/services/audio_service.dart';
import 'liquid_player_screen.dart';

/// Tela "Biblioteca" — mesma linguagem Liquid Glass do player.
/// Uso: LibraryScreen(audioService: audioService)
class LibraryScreen extends StatefulWidget {
  final AudioService audioService;
  const LibraryScreen({super.key, required this.audioService});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _blobs;
  final GlassMode _mode = GlassMode.fosco;
  final Set<String> _liked = {};
  String _chip = 'Todas';

  static const _chips = ['Todas', 'Curtidas', 'Álbuns', 'Recentes'];

  @override
  void initState() {
    super.initState();
    _blobs = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    _load();
  }

  Future<void> _load() async {
    await widget.audioService.loadTracks();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _blobs.dispose();
    super.dispose();
  }

  AudioPlayer get _player => widget.audioService.player;

  List<Color> get _paleta {
    final t = widget.audioService.currentTrack;
    final i = t == null ? 0 : widget.audioService.tracks.indexOf(t);
    return kPaletas[(i < 0 ? 0 : i) % kPaletas.length];
  }

  List<Track> get _lista {
    final all = widget.audioService.tracks;
    if (_chip == 'Curtidas') return all.where((t) => _liked.contains(t.path)).toList();
    if (_chip == 'Recentes') return all.take(5).toList();
    return all;
  }

  String _fmt(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  void _abrirPlayer([Track? t]) {
    if (t != null) widget.audioService.play(t);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LiquidPlayerScreen(audioService: widget.audioService),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.audioService;
    return ListenableBuilder(
      listenable:
          Listenable.merge([s.currentTrackNotifier, s.currentAlbumNotifier]),
      builder: (context, _) {
        return _buildLibrary();
      },
    );
  }

  Widget _buildLibrary() {
    final atual = widget.audioService.currentTrack;
    final lista = _lista;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0910),
      body: Stack(
        children: [
          FundoLiquido(animation: _blobs, paleta: _paleta),
          const VeuFundo(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SUA COLEÇÃO',
                                style: TextStyle(
                                    fontSize: 9,
                                    letterSpacing: 2,
                                    color: Colors.white.withOpacity(0.5))),
                            const SizedBox(height: 4),
                            const Text('Biblioteca',
                                style: TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.8,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                      Glass(
                        mode: _mode,
                        radius: 20,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.sort_rounded,
                              size: 18, color: Colors.white.withOpacity(0.85)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // busca
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Glass(
                    mode: _mode,
                    radius: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 17, color: Colors.white.withOpacity(0.6)),
                          const SizedBox(width: 11),
                          Text('Buscar faixa ou álbum',
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.62))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // chips
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _chips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final c = _chips[i];
                      final ativo = c == _chip;
                      return GestureDetector(
                        onTap: () => setState(() => _chip = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white.withOpacity(ativo ? 0.16 : 0.045),
                            border: Border.all(color: Colors.white.withOpacity(ativo ? 0.4 : 0.1)),
                          ),
                          child: Text(c,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(ativo ? 1 : 0.65))),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // card tocando agora
                if (atual != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () => _abrirPlayer(),
                      child: Glass(
                        mode: _mode,
                        radius: 20,
                        padding: const EdgeInsets.all(11),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _paleta.take(2).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOCANDO AGORA',
                                      style: TextStyle(
                                          fontSize: 8.5,
                                          letterSpacing: 2,
                                          color: Colors.white.withOpacity(0.5))),
                                  const SizedBox(height: 4),
                                  Text(atual.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                  Text('Pitty',
                                      style: TextStyle(
                                          fontSize: 11.5, color: Colors.white.withOpacity(0.6))),
                                ],
                              ),
                            ),
                            StreamBuilder<bool>(
                              stream: _player.playingStream,
                              builder: (_, snap) => _Equalizador(tocando: snap.data ?? false),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_chip == 'Curtidas' ? 'Faixas curtidas' : 'Todas as faixas',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('${lista.length} FAIXAS',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.6,
                              color: Colors.white.withOpacity(0.58))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    itemCount: lista.length,
                    itemBuilder: (_, i) {
                      final t = lista[i];
                      final ehAtual = t == atual;
                      final curtida = _liked.contains(t.path);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _abrirPlayer(t),
                        onLongPress: () => setState(() {
                          curtida ? _liked.remove(t.path) : _liked.add(t.path);
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            color: ehAtual ? Colors.white.withOpacity(0.11) : Colors.transparent,
                            border: Border.all(
                                color: Colors.white.withOpacity(ehAtual ? 0.16 : 0)),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                child: Text((i + 1).toString().padLeft(2, '0'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(ehAtual ? 1 : 0.55))),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: kPaletas[i % kPaletas.length].take(2).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(ehAtual ? 1 : 0.88))),
                                    Text('Pitty',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 11.5,
                                            color: Colors.white.withOpacity(0.62))),
                                  ],
                                ),
                              ),
                              Text(t.duration == Duration.zero ? '' : _fmt(t.duration),
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.56))),
                              const SizedBox(width: 8),
                              Opacity(
                                opacity: curtida ? 0.9 : 0,
                                child: const Icon(Icons.favorite_rounded, size: 13, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // mini player
                if (atual != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: Glass(
                      mode: _mode,
                      radius: 26,
                      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _abrirPlayer(),
                                child: Text('Voltar para ${atual.title}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.75))),
                              ),
                            ),
                            StreamBuilder<bool>(
                              stream: _player.playingStream,
                              builder: (_, snap) {
                                final tocando = snap.data ?? false;
                                return GestureDetector(
                                  onTap: () {
                                    tocando
                                        ? widget.audioService.pause()
                                        : widget.audioService.resume();
                                  },
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.14),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Icon(
                                        tocando ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        size: 18,
                                        color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Equalizador de 3 barras.
class _Equalizador extends StatefulWidget {
  final bool tocando;
  const _Equalizador({required this.tocando});

  @override
  State<_Equalizador> createState() => _EqualizadorState();
}

class _EqualizadorState extends State<_Equalizador> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.tocando ? 1 : 0.25,
      child: SizedBox(
        height: 20,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            double h(double fase) {
              final v = (0.5 + 0.5 * -1 * (widget.tocando ? 1 : 0) * 0) +
                  (widget.tocando
                      ? (0.5 + 0.5 * (1 - 2 * ((_c.value + fase) % 1 - 0.5).abs() * 2).abs())
                      : 0.4);
              return 6 + 13 * v.clamp(0, 1);
            }

            Widget barra(double fase) => Container(
                  width: 3,
                  height: h(fase),
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [barra(0), barra(0.33), barra(0.66)],
            );
          },
        ),
      ),
    );
  }
}
