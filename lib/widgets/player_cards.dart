import 'package:flutter/material.dart';

import 'package:msb_just/data/track_content.dart';
import 'package:msb_just/screens/liquid_player_screen.dart';
import 'package:msb_just/screens/lyrics_fullscreen.dart';
import 'package:msb_just/services/audio_service.dart';

const _mode = GlassMode.fosco;

TextStyle _rotulo() => const TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.8, color: Colors.white);
TextStyle _meta() => TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.6));
TextStyle _sub() => TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.65));

/// Card de vidro com cabeçalho opcional.
class CardVidro extends StatelessWidget {
  final String? titulo;
  final Widget? acao;
  final Widget child;
  final EdgeInsets padding;
  const CardVidro({
    super.key,
    this.titulo,
    this.acao,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 15, 16, 15),
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      mode: _mode,
      radius: 24,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(titulo!.toUpperCase(), style: _rotulo()), if (acao != null) acao!],
            ),
          if (titulo != null) const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

Widget _linha({required bool primeira, required Widget child}) => Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: primeira
            ? null
            : Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: child,
    );

Widget _avatar(String nome, List<Color> cores, {double size = 38}) => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: cores.take(2).toList()),
      ),
      child: Text(
        nome.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );

// ─── Letra (com botão Tela cheia) ───────────────────────────────────────
class LetraCard extends StatelessWidget {
  final AudioService audioService;
  const LetraCard({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    final letra = conteudoDe(audioService.currentTrack).letra;
    return CardVidro(
      titulo: 'Letra',
      acao: GestureDetector(
        onTap: () => Navigator.of(context).push(LyricsFullscreen.rota(audioService)),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.open_in_full_rounded, size: 12, color: Colors.white),
              SizedBox(width: 6),
              Text('Tela cheia',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
      child: StreamBuilder<Duration>(
        stream: audioService.player.positionStream,
        builder: (_, snap) {
          final ativa = linhaAtiva(audioService, snap.data, letra.length);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < letra.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 450),
                    style: TextStyle(
                      fontSize: 19,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: i == ativa
                          ? Colors.white
                          : Colors.white.withOpacity(i < ativa ? 0.45 : 0.62),
                    ),
                    child: Text(letra[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

int linhaAtiva(AudioService s, Duration? pos, int n) {
  final total = s.player.duration;
  if (pos == null || total == null || total.inMilliseconds == 0 || n == 0) return 0;
  final per = total.inMilliseconds / n;
  return (pos.inMilliseconds / per).floor().clamp(0, n - 1);
}

// ─── Clipe ──────────────────────────────────────────────────────────────
class ClipeCard extends StatelessWidget {
  final ConteudoFaixa conteudo;
  final String titulo;
  const ClipeCard({super.key, required this.conteudo, required this.titulo});

  @override
  Widget build(BuildContext context) {
    final id = conteudo.clipeYoutubeId;
    return CardVidro(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: id == null ? null : () => abrirLink('https://www.youtube.com/watch?v=$id'),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black),
                  if (id != null)
                    Image.network('https://img.youtube.com/vi/$id/hqdefault.jpg',
                        fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          const Color(0xFF08070C).withOpacity(0.7)
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Glass(
                      mode: _mode,
                      radius: 29,
                      child: const SizedBox(
                        width: 58,
                        height: 58,
                        child: Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CLIPE OFICIAL',
                    style: TextStyle(
                        fontSize: 9, letterSpacing: 1.8, color: Colors.white.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Álbum no Spotify (deep link) ───────────────────────────────────────
class AlbumSpotifyCard extends StatelessWidget {
  final AlbumSpotify album;
  const AlbumSpotifyCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => abrirSpotifyAlbum(album.spotifyId),
      child: _LinhaServico(
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: kPaletas[album.paleta % kPaletas.length],
            ),
          ),
        ),
        titulo: album.nome,
        subtitulo: 'Abrir álbum no Spotify',
        cor: const Color(0xFF1ED760),
        tinta: Colors.black,
      ),
    );
  }
}

class _LinhaServico extends StatelessWidget {
  final Widget leading;
  final String titulo, subtitulo;
  final Color cor, tinta;
  const _LinhaServico({
    required this.leading,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.tinta,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      mode: _mode,
      radius: 20,
      padding: const EdgeInsets.fromLTRB(11, 11, 12, 11),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: _sub()),
              ],
            ),
          ),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(16)),
            child: Text('Ouvir',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tinta)),
          ),
        ],
      ),
    );
  }
}

// ─── Sobre o artista ────────────────────────────────────────────────────
class SobreArtistaCard extends StatelessWidget {
  final List<Color> paleta;
  const SobreArtistaCard({super.key, required this.paleta});

  @override
  Widget build(BuildContext context) {
    return CardVidro(
      titulo: 'Sobre o artista',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: paleta.take(2).toList()),
                ),
              ),
              const SizedBox(width: 13),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pitty',
                      style: TextStyle(
                          fontSize: 24, fontStyle: FontStyle.italic, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Rock · Salvador, BA', style: _sub()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(kBioArtista,
              style: TextStyle(fontSize: 13, height: 1.55, color: Colors.white.withOpacity(0.78))),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => abrirLink(kSiteArtista),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white.withOpacity(0.14),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Site oficial',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.north_east_rounded, size: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vídeos de fãs (carrossel) ──────────────────────────────────────────
class VideosFasCard extends StatelessWidget {
  const VideosFasCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardVidro(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('VÍDEOS DE FÃS', style: _rotulo()),
                Text('${kVideosFas.length} vídeos', style: _meta()),
              ],
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kVideosFas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final v = kVideosFas[i];
                final c = kPaletas[i % kPaletas.length];
                return GestureDetector(
                  onTap: () => abrirLink(v.url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [c[i % 3], c[(i + 1) % 3], const Color(0xFF0A0910)],
                          stops: const [0, 0.7, 1],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF08070C).withOpacity(0.8)
                                  ],
                                  stops: const [0.45, 1],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF08070C).withOpacity(0.45),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow_rounded, size: 11, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(v.duracao,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 11,
                            right: 11,
                            bottom: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.titulo,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                const SizedBox(height: 2),
                                Text(v.usuario,
                                    style: TextStyle(
                                        fontSize: 10.5, color: Colors.white.withOpacity(0.8))),
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
        ],
      ),
    );
  }
}

// ─── Regravações ────────────────────────────────────────────────────────
class RegravacoesCard extends StatelessWidget {
  const RegravacoesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardVidro(
      titulo: 'Regravações',
      acao: Text('${kRegravacoes.length} versões', style: _meta()),
      child: Column(
        children: [
          for (var i = 0; i < kRegravacoes.length; i++)
            _linha(
              primeira: i == 0,
              child: Row(
                children: [
                  _avatar(kRegravacoes[i].artista, kPaletas[(i + 1) % kPaletas.length]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kRegravacoes[i].artista,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        Text(kRegravacoes[i].info, style: _sub()),
                      ],
                    ),
                  ),
                  Text(kRegravacoes[i].ano, style: _meta()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Créditos da faixa ──────────────────────────────────────────────────
class CreditosFaixaCard extends StatelessWidget {
  const CreditosFaixaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardVidro(
      titulo: 'Créditos',
      child: Column(
        children: [
          for (var i = 0; i < kCreditosFaixa.length; i++)
            _linha(
              primeira: i == 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kCreditosFaixa[i].$1,
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.62))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(kCreditosFaixa[i].$2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Streaming (Spotify / Apple Music / Deezer) ─────────────────────────
class StreamingCards extends StatelessWidget {
  final String titulo;
  const StreamingCards({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    final servicos = [
      ('Spotify', 'S', const Color(0xFF1ED760), Colors.black, linkSpotify(titulo)),
      ('Apple Music', '♪', const Color(0xFFFA2D48), Colors.white, linkAppleMusic(titulo)),
      ('Deezer', 'D', const Color(0xFFA238FF), Colors.white, linkDeezer(titulo)),
    ];
    return Column(
      children: [
        for (final (nome, marca, cor, tinta, url) in servicos) ...[
          GestureDetector(
            onTap: () => abrirLink(url),
            child: _LinhaServico(
              leading: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(12)),
                child: Text(marca,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: tinta)),
              ),
              titulo: nome,
              subtitulo: '$titulo · Pitty',
              cor: cor,
              tinta: tinta,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Sequência de cards do player expandido, na ordem do protótipo.
List<Widget> cardsPlayerExpandido(BuildContext context, AudioService s) {
  final t = s.currentTrack;
  final i = t == null ? 0 : s.tracks.indexOf(t).clamp(0, 999);
  const gap = SizedBox(height: 12);
  return [
    LetraCard(audioService: s),
    gap,
    ClipeCard(conteudo: conteudoDe(t), titulo: t?.title ?? ''),
    gap,
    SobreArtistaCard(paleta: kPaletas[i % kPaletas.length]),
    gap,
    const VideosFasCard(),
    gap,
    const RegravacoesCard(),
    gap,
    const CreditosFaixaCard(),
    gap,
    StreamingCards(titulo: t?.title ?? ''),
  ];
}
