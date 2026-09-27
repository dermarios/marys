import 'package:flutter/material.dart';

import '../models/track.dart';
import '../models/album.dart';
import '../services/audio_service.dart';
import '../widgets/mini_player.dart';
import 'liquid_player_screen.dart';

/// Biblioteca — Discografia em grade com capas grandes, filtrada por tipo.
///
/// O mini player vem do PlayerShell (envolva esta tela com ele):
///   PlayerShell(audioService: s, child: LibraryScreen(audioService: s))
class LibraryScreen extends StatefulWidget {
  final AudioService audioService;
  const LibraryScreen({super.key, required this.audioService});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

enum TipoLancamento { album, singleEp, compilacao }

class Lancamento {
  final String titulo;
  final String ano;
  final String tipo; // rótulo exibido: Álbum, Single, EP, Ao vivo, Coletânea…
  final TipoLancamento categoria;
  final String? capa; // asset da capa; null = degradê
  const Lancamento(this.titulo, this.ano, this.tipo, this.categoria, {this.capa});
}

/// Discografia — Álbuns reais disponíveis no app
const kDiscografia = <Lancamento>[
  Lancamento('Beyond Smoke', '2020', 'Álbum', TipoLancamento.album),
  Lancamento('Escravos do Tempo\nContinuo e Lento', '2021', 'Álbum', TipoLancamento.album),
  Lancamento('Just', '2024', 'Álbum', TipoLancamento.album),
];

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _blobs;
  final GlassMode _mode = GlassMode.fosco;
  TipoLancamento _filtro = TipoLancamento.album;

  static const _chips = <(TipoLancamento, String)>[
    (TipoLancamento.album, 'Álbuns'),
    (TipoLancamento.singleEp, 'Singles e EPs'),
    (TipoLancamento.compilacao, 'Compilações'),
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

  List<Color> get _paleta {
    final t = widget.audioService.currentTrack;
    final i = t == null ? 0 : widget.audioService.tracks.indexOf(t);
    return kPaletas[(i < 0 ? 0 : i) % kPaletas.length];
  }

  /// Procura uma faixa local com o mesmo título do lançamento.
  Track? _faixaDe(Lancamento l) {
    final alvo = l.titulo.toLowerCase();
    for (final t in widget.audioService.tracks) {
      if (t.title.toLowerCase() == alvo) return t;
    }
    return null;
  }

  Future<void> _abrir(Lancamento l) async {
    final t = _faixaDe(l);
    if (t == null) return;
    await widget.audioService.play(t);
    if (!mounted) return;
    setState(() {});
    Navigator.of(context).push(rotaPlayerExpandido(widget.audioService));
  }

  @override
  Widget build(BuildContext context) {
    final lista = kDiscografia.where((l) => l.categoria == _filtro).toList();
    final atual = widget.audioService.currentTrack?.title.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0910),
      body: Stack(
        children: [
          FundoLiquido(animation: _blobs, paleta: _paleta),
          const VeuFundo(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _cabecalho(),
                        const SizedBox(height: 14),
                        _busca(),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),
                SliverToBoxAdapter(child: _filtros()),
                const SliverToBoxAdapter(child: SizedBox(height: 22)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 0, 12),
                    child: Text('Destaque',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: kAlbums.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final album = kAlbums[i];
                        return GestureDetector(
                          onTap: () async {
                            await widget.audioService.playAlbum(album);
                            if (!mounted) return;
                            setState(() {});
                            Navigator.of(context).push(rotaPlayerExpandido(widget.audioService));
                          },
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
                                child: RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: album.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          height: 1.3,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' - ${album.year}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white.withOpacity(0.65),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Discografia',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text('${lista.length} LANÇAMENTOS',
                            style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.6,
                                color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  // 120 px no fim para o mini player flutuante
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.74,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _capaCard(lista[i], i, atual == lista[i].titulo.toLowerCase()),
                      childCount: lista.length,
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

  Widget _cabecalho() => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SUA COLEÇÃO',
                    style: TextStyle(
                        fontSize: 9, letterSpacing: 2, color: Colors.white.withOpacity(0.55))),
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
              child: Icon(Icons.sort_rounded, size: 18, color: Colors.white.withOpacity(0.85)),
            ),
          ),
        ],
      );

  Widget _busca() => Glass(
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
      );

  Widget _filtros() => SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final (tipo, rotulo) = _chips[i];
            final ativo = tipo == _filtro;
            return GestureDetector(
              onTap: () => setState(() => _filtro = tipo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(ativo ? 0.16 : 0.045),
                  border: Border.all(color: Colors.white.withOpacity(ativo ? 0.4 : 0.1)),
                ),
                child: Text(rotulo,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(ativo ? 1 : 0.65))),
              ),
            );
          },
        ),
      );

  Widget _capaCard(Lancamento l, int i, bool tocando) {
    final cores = kPaletas[i % kPaletas.length];
    return GestureDetector(
      onTap: () => _abrir(l),
      child: Stack(
        children: [
          Glass(
            mode: _mode,
            radius: 22,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: cores,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 26,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (l.capa != null)
                            Image.asset(l.capa!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox()),
                          // brilho especular
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.22),
                                  Colors.white.withOpacity(0),
                                ],
                                stops: const [0, 0.4],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('${l.ano} · ${l.tipo}',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.62))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (tocando)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
