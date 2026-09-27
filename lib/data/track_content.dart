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
  'Leprechaun': ConteudoFaixa(letra: <String>[
    'Leprechaun',
    'Ladies and gentlemans',
    'The" Secrets of Infinity Circus Company"',
    ' have the pleasure to introduce you…',
    '…The box!!! ',
    'How many wonders may be traped inside this jail?',
    'But please…take care littles!!!',
    'If you just set your hopes inside the box',
    'Your dreams may become to life…',
    '…or may lost itselfs…forever.',
  ]),
  'Painted on Your Face': ConteudoFaixa(letra: <String>[
    'Painted on your face ',
    'Perception, Frustration',
    'You finally realised',
    'your fake mould, your castle of cards',
    'it\'s not safe place to hide',
    'You\'re drowned in your own worlds',
    'You\'re playing on fire again',
    'Did you gave to devil the clues to our secret plan?',
    'Was painted on your face the shame you\'ve tried to hide inside',
    'Regretless, Self mercy...',
    'just try to be a good looser now',
    'The silence, so indiscreet',
    'It tells me your filthy thoughts',
    'You can\'t shine on into this hole',
    'Step inside! Welcome to my jungle!',
    'Was painted on your face the shame you\'ve tried to hide inside',
    'Regretless, Self mercy...',
    'just try to be a good looser now',
    'Hollow, hollow inside.',
    'There\'s no safe place to hide.',
    'Was painted on your face the shame you\'ve tried to hide inside',
    'Regretless, Self mercy...',
    'just try to be a good looser now',
  ]),
  'All the Pleasures for You': ConteudoFaixa(letra: <String>[
    'All the pleasures for  you',
    'Speak little child',
    'How many pleasures are hunting you?',
    'How many mortal souls',
    'Still not gave up to you?',
    'Your bittersweet kisses',
    'Your  deep seductor eyes',
    'Your  soft  vicious voice',
    'You\'re aways there delighted',
    'A perfect existence',
    'All the pleasures for  you',
    'To fulfill the hole inner self',
    'Trying to find some trace of authenticity',
    'You never asked yourself',
    'How should be outside this shell',
    'Now you\'re much more blind',
    'But all is clear when we\'re in dark',
    'Blind misery, searching for something useful',
    'Riding through the dark path of your doubts',
    'In the highest point of your mindwar',
    'You\'ll become a slave of your sand mask',
    'You never asked yourself',
    'How should be outside this shell',
    'Now you\'re much more blind',
    'But all is clear when we\'re in  dark',
  ]),
  'Weird': ConteudoFaixa(letra: <String>[
    'Weird',
    'This place is chocking me',
    'I\'ll walk around searching for something',
    'I don\'t want to see',
    'My shadow is running alone',
    'A prey of my demons',
    'It will happen again',
    'There\'s something weird in a point I\'m still not get in mind',
    'I\'m losing all my control',
    'Maybe if I had a gun...out to hell this thoughts',
    'It\'s just a wild desire',
    'a fucking punch in the face and a zeal in the bones',
    'I\'m trying to lost myself ',
    'in somekind of psychdelic nightmare',
    'The stones...',
    'it\'s just like me',
    'it is so heavy and it is so cold',
    'I\'m thinking better!!',
    'The stones is so passive',
    'It could be kicked exactly like me...like me',
  ]),
  'Suicide Playground': ConteudoFaixa(letra: <String>[
    'Suicide Playground',
    'Let the wine falls down',
    'and blind the eyes of the sinners',
    'there\'s no place to regreat',
    'Catch me as a prey submissive in your trap',
    'a condemned captive',
    'Is my pleasure when you lie',
    'Make on me ',
    'your private suicide playground',
    'That\'s the night of the tricksters',
    'only instinct tells the truth',
    'There\'s no place to honesty',
    'And the wine in our veins',
    'Have becomes brand new',
    'in every little death',
    'Is my pleasure when you lie',
    'Make on me ',
    'your private suicide playground',
  ]),
  'Carry Me to Chaos': ConteudoFaixa(letra: <String>[
    'Carry me to Chaos ',
    'A past that shades our future',
    'A  void point in the time picture',
    'We drunk with death to celebrate them greed for lust',
    'There\'s something unfinished in the untouchable part of our minds',
    'Dress your shapeless skin and stay submerged under a wild decision',
    'Cut your wings and come down',
    'Look inside your tyrant\'s eyes',
    'Read between the lines we\'re writing',
    'You\'ll find out there many questions to your answers',
    'Till a doubt, make it grow up and spread it on the wind',
    'Maybe we can see it as long as we are young',
    'Proud about the scars, proud about the lost war',
    'Have you ever  felt you don\'t belong this place??',
    'Turning away',
    'You\'re scared to think about me',
    'Leave out this day',
    'Carry me to chaos',
  ]),
  'Corruption Messiah': ConteudoFaixa(letra: <String>[
    'Corruption Messiah ',
    'Give a shot, be the bullet',
    'give a chance , take away the chance',
    'plant the fear,  shed the hope',
    'make a plan, cover up the dirge ',
    'sell your soul, buy some others souls',
    'enjoy a little peace, feel their hate grow up',
    'please your enemy, stab him from behind',
    'trust in luck and get a disguise',
    'You can have some still years...if doesn\'t remain any old friend',
    'Feed your ego with apparent dignity',
    'Free a captive and show your sympathy',
    'Loose some battles , don\'t be watched',
    'Arise from ashes like a tired fighter',
    'Give a shot, plant the fear',
    'Sell your soul, cover up the dirge',
    'Spit in their remains, stay away from chains',
    'And last but not least',
    'never trust in yourself',
    'You can have some still years...if doesn\'t remain any old friend',
    'Your glass face doesn\'t denies the truth behind the mask',
    'Praises will come to Corruption messiah',
    'make them feel guilty for believe in your pretty talks',
    'many praises will come to corruption messiah.',
  ]),
  'Forbidden Tree': ConteudoFaixa(letra: <String>[
    'Forbidden tree',
    'While she comes my blood turns to cold',
    'She\'s a messenger of contradictions',
    'I must open my eyes to see',
    'if what\'s happening around me',
    'still make sense to my old fool mind.',
    'Say some words, you make me believe',
    'that this pain is no more in me',
    'In awakening the scene reveals other ways.',
    'Leave my hands! I\'ll walk through this road till that strange light.',
    'It seems like led, but I cannot feel my feet touching on the ground.',
    'We go on through the harder path',
    'with no one to teach us how return',
    'Burying our friends on the way along',
    'letting go with them some part of our minds.',
    'It\'s the search for a momentary truth',
    'I need a heal for my restlessness',
    'She\'ll makes me forget for a while',
    'So I\'ll lay my body over her arms',
  ]),
  'Cocaine Bread': ConteudoFaixa(letra: <String>[
    'Cocaine Bread',
    'We have written our sentence within',
    'a pool of dust and blame',
    'Sinking our roots into the mire',
    'Castaways in wastelands',
    'Do you can see a dying old kid reflected into my eyes?',
    'Laugh on my face if you realize that it\'s not your last dance',
    'Cut the ties',
    'Twisted waves',
    'Your mind will never be trapped again',
    'It feeds your pain',
    'Cocaine bread',
    'Don\'t hope for tears above your grave',
    'What\'s your part in the deal?',
    'Time slips away through the fingers',
    'Mad thoughts takes place inside',
  ]),
  'Marys Secret Box': ConteudoFaixa(letra: <String>[
    'Mary\'s Secret Box',
    'I\'ve heard the steps of a shadowman',
    'please don\'t let him come in',
    'I\'ll spit my rage on you',
    'The sound of the opening door',
    'brings to me the fright and shame',
    'My soul is bleeding through ',
    'I try to put my mind out of the space and time',
    'It helps to ease the pain',
    'A distortion world and a grey sky,',
    'I see it all the time',
    'My pride was stolen for you',
    'My meat is not to you',
  ]),
  'Silent Sky': ConteudoFaixa(letra: <String>[
    'Silent Sky',
    'Abandoned dream\'s rag',
    'Left in the cold',
    'In company of flies',
    'Chasing the past',
    'Looks like the last dawn is so far away',
    'A thousand voices I\'ve heard',
    'And a thousand times it conceals',
    'Words won\'t be wasted',
    'And tears won\'t be shed',
    'Under rough skin remains the child\'s hope',
    'That silent sky brings some peace I can\'t steal',
  ]),
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
  'escravos-do-tempo': ConteudoFaixa(
    letra: _letraExemplo,
    clipeYoutubeId: 'vaFN2K1BJqs',
    clipeLabel: 'CLIPE OFICIAL',
    clipeTitulo: 'Escravos do Tempo Continuo e Lento',
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
    AlbumSpotify('Just', '6gzUED8aFdwlH2Li60D8Oe', 0, servico: ServicoStreaming.spotify),
    AlbumSpotify('Just', '1105047334', 1, servico: ServicoStreaming.appleMusic),
    AlbumSpotify('Just', '34vHFnplKrXFhCl8DMNBF', 2, servico: ServicoStreaming.deezer),
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
String linkAppleMusicAlbum(String id) => 'https://music.apple.com/br/album/just/$id';
String linkDeezer(String t) => 'https://www.deezer.com/search/${_q(t)}';
String linkDeezerAlbum(String id) => 'https://link.deezer.com/s/$id';

// ─── Fotos por álbum ────────────────────────────────────────────────
class Foto {
  final String asset;
  final String legenda;
  final String sub;
  final int cols;
  final int rows;
  const Foto(this.asset, this.legenda, this.sub, this.cols, this.rows);
}

const kFotosPorAlbum = <String, List<Foto>>{
  'just': [
    Foto('assets/albuns/just/fotos/596808697_25618519724439065_5418686845622157502_n.jpg', 'Foto 1', 'Just', 2, 1),
    Foto('assets/albuns/just/fotos/596810720_25618519681105736_8647549233638235941_n.jpg', 'Foto 2', 'Just', 1, 1),
    Foto('assets/albuns/just/fotos/597814157_25618519791105725_1282261320201049684_n.jpg', 'Foto 3', 'Just', 1, 2),
    Foto('assets/albuns/just/fotos/597967119_25618519647772406_5351213839960951359_n.jpg', 'Foto 4', 'Just', 1, 1),
    Foto('assets/albuns/just/fotos/598015977_25618975347726836_2284519281725335253_n.jpg', 'Foto 5', 'Just', 1, 1),
    Foto('assets/albuns/just/fotos/599940809_25618094744481563_5618017685269495687_n.jpg', 'Foto 6', 'Just', 2, 1),
    Foto('assets/albuns/just/fotos/647394672_26380402064917490_2009591765790192284_n.jpg', 'Foto 7', 'Just', 1, 1),
    Foto('assets/albuns/just/fotos/648933701_26380725371551826_3678365400862571929_n.jpg', 'Foto 8', 'Just', 2, 2),
  ],
};

List<Foto> fotosDoAlbum(String? albumId) {
  if (albumId == null) return [];
  return kFotosPorAlbum[albumId] ?? [];
}
