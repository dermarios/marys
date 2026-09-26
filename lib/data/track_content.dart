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
  // 'I see in the crowd': ConteudoFaixa(letra: [...], clipeYoutubeId: 'XXXXXXXXXXX'),
};

ConteudoFaixa conteudoDe(Track? t) =>
    (t == null ? null : kConteudo[t.title]) ?? const ConteudoFaixa(letra: _letraExemplo);

/// Retorna o conteúdo (vídeo) do álbum. Independente da faixa atual.
const kConteudoAlbuns = <String, ConteudoFaixa>{
  'just': ConteudoFaixa(
    letra: _letraExemplo,
    clipeYoutubeId: 'XMaYPNlArYA',
    clipeLabel: 'STUDIO SESSIONS',
    clipeTitulo: 'Until the Day You Be Born',
  ),
  'beyond-smoke': ConteudoFaixa(
    letra: _letraExemplo,
    clipeYoutubeId: 'v_RNStDxtzo',
    clipeLabel: 'CLIPE OFICIAL',
    clipeTitulo: 'Beyond Smoke',
  ),
};

ConteudoFaixa conteudoDoAlbum(String? albumId) =>
    (albumId == null ? null : kConteudoAlbuns[albumId.toLowerCase()]) ??
    const ConteudoFaixa(letra: _letraExemplo);

enum ServicoStreaming { spotify, appleMusic, deezer }

class AlbumSpotify {
  final String nome;
  final String spotifyId;
  final int paleta; // índice em kPaletas
  final ServicoStreaming servico;
  const AlbumSpotify(this.nome, this.spotifyId, this.paleta, {this.servico = ServicoStreaming.spotify});
}

const kAlbuns = <AlbumSpotify>[
  AlbumSpotify('Admirável Chip Novo', 'ALBUM_ID_1', 0),
  AlbumSpotify('Anacrônico', 'ALBUM_ID_2', 1),
  AlbumSpotify('Chiaroscuro', 'ALBUM_ID_3', 2),
];

/// Cards de álbuns relacionados por álbum. Configurável pelo desenvolvedor.
const kAlbunsRelacionados = <String, List<AlbumSpotify>>{
  'just': <AlbumSpotify>[
    AlbumSpotify('Admirável Chip Novo', 'ALBUM_ID_1', 0, servico: ServicoStreaming.spotify),
    AlbumSpotify('Anacrônico', 'ALBUM_ID_2', 1, servico: ServicoStreaming.appleMusic),
    AlbumSpotify('Chiaroscuro', 'ALBUM_ID_3', 2, servico: ServicoStreaming.deezer),
  ],
  'beyond-smoke': <AlbumSpotify>[
    AlbumSpotify('Admirável Chip Novo', 'ALBUM_ID_1', 0, servico: ServicoStreaming.spotify),
    AlbumSpotify('Anacrônico', 'ALBUM_ID_2', 1, servico: ServicoStreaming.appleMusic),
    AlbumSpotify('Chiaroscuro', 'ALBUM_ID_3', 2, servico: ServicoStreaming.deezer),
  ],
  'escravos-do-tempo': <AlbumSpotify>[
    AlbumSpotify('Admirável Chip Novo', 'ALBUM_ID_1', 0, servico: ServicoStreaming.spotify),
    AlbumSpotify('Anacrônico', 'ALBUM_ID_2', 1, servico: ServicoStreaming.appleMusic),
    AlbumSpotify('Chiaroscuro', 'ALBUM_ID_3', 2, servico: ServicoStreaming.deezer),
  ],
};

List<AlbumSpotify> albumnsRelacionadosDo(String? albumId) =>
    (albumId == null ? null : kAlbunsRelacionados[albumId.toLowerCase()]) ?? kAlbuns;

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
