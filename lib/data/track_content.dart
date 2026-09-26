import 'package:url_launcher/url_launcher.dart';
import 'package:msb_just/models/track.dart';

/// Conteúdo editorial das faixas. Tudo aqui é EXEMPLO — troque pelos dados reais.

const kSiteArtista = 'https://pitty.com.br';

const kBioArtista =
    'Voz do rock brasileiro desde 2003, com letras diretas sobre identidade, liberdade e o peso do cotidiano.';

class ConteudoFaixa {
  final List<String> letra;
  final String? clipeYoutubeId;
  final String clipeLabel;
  final String? clipeTitulo;
  const ConteudoFaixa({
    required this.letra,
    this.clipeYoutubeId,
    this.clipeLabel = 'CLIPE OFICIAL',
    this.clipeTitulo,
  });
}

const _letraExemplo = <String>[
  '(letra de exemplo — linha um)',
  'o reflexo atravessa o vidro',
  'e o que sobra é só ruído',
  'devagar, o vidro respira',
  'nada aqui fica parado',
  'até a luz muda de lado',
];

/// Chave = Track.title (como aparece no tracks.json).
const kConteudo = <String, ConteudoFaixa>{
  'Leprechaun': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Painted on Your Face': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'All the Pleasures for You': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Weird': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Suicide Playground': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Carry Me to Chaos': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Until the Day You Be Born': ConteudoFaixa(
    letra: _letraExemplo,
    clipeYoutubeId: 'XMaYPNlArYA',
    clipeLabel: 'STUDIO SESSIONS',
    clipeTitulo: 'Until the Day You Be Born',
  ),
  'Corruption Messiah': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Forbidden Tree': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Cocaine Bread': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Marys Secret Box': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
  'Silent Sky': ConteudoFaixa(letra: _letraExemplo, clipeYoutubeId: 'XMaYPNlArYA'),
};

ConteudoFaixa conteudoDe(Track? t) =>
    (t == null ? null : kConteudo[t.title]) ?? const ConteudoFaixa(letra: _letraExemplo);

class AlbumSpotify {
  final String nome;
  final String spotifyId;
  final int paleta; // índice em kPaletas
  const AlbumSpotify(this.nome, this.spotifyId, this.paleta);
}

const kAlbuns = <AlbumSpotify>[
  AlbumSpotify('Admirável Chip Novo', 'ALBUM_ID_1', 0),
  AlbumSpotify('Anacrônico', 'ALBUM_ID_2', 1),
  AlbumSpotify('Chiaroscuro', 'ALBUM_ID_3', 2),
];

class VideoFa {
  final String titulo, usuario, duracao, url;
  const VideoFa(this.titulo, this.usuario, this.duracao, this.url);
}

const kVideosFas = <VideoFa>[
  VideoFa('Cover no violão', '@marinasom', '3:12', 'https://www.youtube.com/'),
  VideoFa('Grade do show em SP', '@rockdabia', '0:58', 'https://www.youtube.com/'),
  VideoFa('Bateria cover', '@teobatera', '4:01', 'https://www.youtube.com/'),
  VideoFa('Coro da plateia', '@lucasfm', '1:24', 'https://www.youtube.com/'),
];

class Regravacao {
  final String artista, info, ano;
  const Regravacao(this.artista, this.info, this.ano);
}

const kRegravacoes = <Regravacao>[
  Regravacao('Banda Vidraça', 'Versão acústica', '2019'),
  Regravacao('Carol Bastos', 'Ao vivo · MTV', '2016'),
  Regravacao('Os Ruídos', 'Punk rock', '2012'),
];

const kCreditosFaixa = <(String funcao, String nomes)>[
  ('Composição', 'Ana Ferraz, Rui Almeida'),
  ('Produção', 'Marcelo Tavares, Bia Nogueira'),
  ('Estúdio', 'Caio Ribeiro, Helena Prado'),
  ('Banda', 'Pitty, Duda Machado'),
  ('Fotografia', 'Jorge Daux, Lia Sampaio'),
];

// ─── links ──────────────────────────────────────────────────────────────

Future<void> abrirLink(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

/// Deep link: tenta o app do Spotify; se não estiver instalado, abre a web.
Future<void> abrirSpotifyAlbum(String id) async {
  final app = Uri.parse('spotify:album:$id');
  if (await canLaunchUrl(app)) {
    await launchUrl(app, mode: LaunchMode.externalApplication);
  } else {
    await abrirLink('https://open.spotify.com/album/$id');
  }
}

String _q(String titulo) => Uri.encodeComponent('$titulo Pitty');
String linkSpotify(String t) => 'https://open.spotify.com/search/${_q(t)}';
String linkAppleMusic(String t) => 'https://music.apple.com/br/search?term=${_q(t)}';
String linkDeezer(String t) => 'https://www.deezer.com/search/${_q(t)}';
