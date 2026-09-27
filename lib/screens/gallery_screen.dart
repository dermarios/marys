import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../models/album.dart';
import 'liquid_player_screen.dart';

/// Galeria em formato de feed: um card de vidro por foto, com cabeçalho,
/// foto 4:5, ações (curtir, comentar, compartilhar, salvar), curtidas,
/// título, descrição e data.
///
/// O mini player vem do PlayerShell:
///   PlayerShell(audioService: s, child: GalleryScreen(audioService: s))
class GalleryScreen extends StatefulWidget {
  final AudioService audioService;
  const GalleryScreen({super.key, required this.audioService});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class Post {
  final String id;
  final String foto; // asset
  final String titulo;
  final String descricao;
  final String local;
  final String data;
  final String tag; // Palco | Bastidores | Estúdio
  final int curtidas;
  const Post({
    required this.id,
    required this.foto,
    required this.titulo,
    required this.descricao,
    required this.local,
    required this.data,
    required this.tag,
    required this.curtidas,
  });
}

const _f1 = 'assets/775416812_18620508076026296_1192558196502584496_n.jpg';
const _f2 = 'assets/Jorge-Daux-@jorgedaux.webp';
const _f3 = 'assets/IMAGEM_NOTICIA_original.jpg';

/// Posts — textos de EXEMPLO. Troque pelas fotos e legendas reais.
const kPosts = <Post>[
  Post(id: 'gal-1', foto: _f1, tag: 'Palco', curtidas: 18420,
      titulo: 'Concha Acústica lotada', local: 'Concha Acústica · Salvador', data: '12 set 2024',
      descricao: 'Voltar pra casa e ver a Concha cantando cada verso junto. Obrigada, Salvador.'),
  Post(id: 'gal-2', foto: _f2, tag: 'Bastidores', curtidas: 6210,
      titulo: 'Antes da passagem de som', local: 'Bastidores', data: '11 set 2024',
      descricao: 'Os vinte minutos de silêncio antes de tudo começar.'),
  Post(id: 'gal-3', foto: _f3, tag: 'Estúdio', curtidas: 4980,
      titulo: 'O pedal board novo', local: 'Estúdio Casa Amarela', data: '3 mar 2023',
      descricao: 'Três pedais a mais, zero arrependimentos. Vem coisa nova por aí.'),
  Post(id: 'gal-4', foto: _f2, tag: 'Palco', curtidas: 9340,
      titulo: 'Segunda voz', local: 'Audio · São Paulo', data: '19 set 2024',
      descricao: 'Quando a plateia assume o refrão e a gente só acompanha.'),
  Post(id: 'gal-5', foto: _f3, tag: 'Estúdio', curtidas: 3720,
      titulo: 'Take 14', local: 'Estúdio Casa Amarela', data: '8 mar 2023',
      descricao: 'Foi o décimo quarto. Valeu cada um dos treze anteriores.'),
  Post(id: 'gal-6', foto: _f1, tag: 'Bastidores', curtidas: 5150,
      titulo: 'Camarim', local: 'Bastidores · Belo Horizonte', data: '4 out 2025',
      descricao: 'Setlist na parede, café na mão e a banda inteira contando piada.'),
  Post(id: 'gal-7', foto: _f3, tag: 'Palco', curtidas: 22760,
      titulo: 'Encerramento da turnê', local: 'São Paulo', data: '18 out 2025',
      descricao: 'Último show da turnê. Saio dessa com a voz rouca e o coração cheio.'),
  Post(id: 'gal-8', foto: _f2, tag: 'Estúdio', curtidas: 2890,
      titulo: 'Mesa de corte', local: 'Estúdio', data: '15 mar 2023',
      descricao: 'Onde a música vira disco. Horas de ajuste fino com a Helena.'),
  Post(id: 'gal-9', foto: _f1, tag: 'Bastidores', curtidas: 4410,
      titulo: 'Soundcheck', local: 'Bastidores · Porto Alegre', data: '17 out 2025',
      descricao: 'Teste, teste, um, dois. O ritual que nunca perde a graça.'),
];

class _GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _blobs;
  final GlassMode _mode = GlassMode.fosco;
  String _tab = 'Todas';
  final Set<String> _curtidos = {};
  final Set<String> _salvos = {};
  String? _coracao; // post que está mostrando o coração do toque duplo

  static const _tabs = ['Todas', 'Palco', 'Bastidores', 'Estúdio'];

  List<Post> _gerarPosts() {
    final album = widget.audioService.currentAlbum;
    if (album == null || album.fotos.isEmpty) return kPosts;

    return List.generate(
      album.fotos.length,
      (i) => Post(
        id: 'gal-${album.id}-$i',
        foto: album.fotos[i],
        titulo: '${album.title} - Foto ${i + 1}',
        descricao: 'Galeria do álbum ${album.title}',
        local: album.title,
        data: '${album.year}',
        tag: 'Palco',
        curtidas: (i + 1) * 1000,
      ),
    );
  }

  List<Post> get _lista {
    final posts = _gerarPosts();
    return _tab == 'Todas' ? posts : posts.where((p) => p.tag == _tab).toList();
  }

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

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }

  void _curtir(Post p, {bool soLigar = false}) {
    setState(() {
      if (soLigar) {
        _curtidos.add(p.id);
        _coracao = p.id;
      } else {
        _curtidos.contains(p.id) ? _curtidos.remove(p.id) : _curtidos.add(p.id);
      }
    });
    if (soLigar) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _coracao == p.id) setState(() => _coracao = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = _lista;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0910),
      body: Stack(
        children: [
          FundoLiquido(animation: _blobs, paleta: kPaletas[0]),
          const VeuFundo(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PITTY',
                                  style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 2,
                                      color: Colors.white.withOpacity(0.55))),
                              const SizedBox(height: 4),
                              const Text('Galeria',
                                  style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.8,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${lista.length} FOTOS',
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.6,
                                  color: Colors.white.withOpacity(0.6))),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _filtros()),
                SliverPadding(
                  // 120 px no fim para o mini player
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 120),
                  sliver: SliverList.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _post(lista[i], i),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtros() => SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = _tabs[i];
            final ativo = c == _tab;
            return GestureDetector(
              onTap: () => setState(() => _tab = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
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
      );

  Widget _post(Post p, int i) {
    final curtido = _curtidos.contains(p.id);
    final salvo = _salvos.contains(p.id);
    final cores = kPaletas[i % kPaletas.length];

    return Glass(
      mode: _mode,
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cabeçalho
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [cores[0], cores[2]]),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0A0910), width: 2),
                      image: DecorationImage(image: AssetImage(widget.audioService.currentAlbum?.coverAsset ?? _f1), fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mary's Secret Box",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text(p.local,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.62))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: Text(p.tag.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: Colors.white.withOpacity(0.8))),
                ),
              ],
            ),
          ),

          // foto 4:5 — toque duplo curte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onDoubleTap: () => _curtir(p, soLigar: true),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: cores,
                          ),
                        ),
                      ),
                      Image.asset(p.foto,
                          fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                      Center(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutBack,
                          scale: _coracao == p.id ? 1 : 0,
                          child: const Icon(Icons.favorite_rounded,
                              size: 92,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 24)]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // texto
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.titulo,
                    style: const TextStyle(
                        fontSize: 17,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: Colors.white)),
                const SizedBox(height: 5),
                Text(p.descricao,
                    style: TextStyle(
                        fontSize: 13, height: 1.55, color: Colors.white.withOpacity(0.78))),
                const SizedBox(height: 11),
                Text(p.data.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.4,
                        color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _acao(Widget icone, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(width: 44, height: 44, child: Center(child: icone)),
      );
}
