import 'track.dart';

class Album {
  final String id;
  final String title;
  final String coverAsset;
  final List<Track> tracks;

  Album({
    required this.id,
    required this.title,
    required this.coverAsset,
    required this.tracks,
  });
}

final kAlbums = [
  Album(
    id: 'beyond-smoke',
    title: 'Beyond Smoke',
    coverAsset: 'assets/albuns/beyond-smolke/a2940860726_1x1_700.avif',
    tracks: [
      Track(
        path: 'assets/albuns/beyond-smolke/01 - Beyond Smoke.mp3',
        title: 'Beyond Smoke',
        imageAsset: 'assets/albuns/beyond-smolke/a2940860726_1x1_700.avif',
      ),
    ],
  ),
  Album(
    id: 'escravos-do-tempo',
    title: 'Escravos do Tempo\nContinuo e Lento',
    coverAsset: 'assets/albuns/escravos-do-tempo-continuo-e-lento/51Lw+X7jACL._UXNaN_FMjpg_QL85_.jpg',
    tracks: [
      Track(
        path: 'assets/albuns/escravos-do-tempo-continuo-e-lento/01 - A Temperança.mp3',
        title: 'A Temperança',
        imageAsset: 'assets/albuns/escravos-do-tempo-continuo-e-lento/51Lw+X7jACL._UXNaN_FMjpg_QL85_.jpg',
      ),
      Track(
        path: 'assets/albuns/escravos-do-tempo-continuo-e-lento/02 - Absinto.mp3',
        title: 'Absinto',
        imageAsset: 'assets/albuns/escravos-do-tempo-continuo-e-lento/51Lw+X7jACL._UXNaN_FMjpg_QL85_.jpg',
      ),
      Track(
        path: 'assets/albuns/escravos-do-tempo-continuo-e-lento/03 - Convidado Mau Grado.mp3',
        title: 'Convidado Mau Grado',
        imageAsset: 'assets/albuns/escravos-do-tempo-continuo-e-lento/51Lw+X7jACL._UXNaN_FMjpg_QL85_.jpg',
      ),
      Track(
        path: 'assets/albuns/escravos-do-tempo-continuo-e-lento/04 - Selvagem.mp3',
        title: 'Selvagem',
        imageAsset: 'assets/albuns/escravos-do-tempo-continuo-e-lento/51Lw+X7jACL._UXNaN_FMjpg_QL85_.jpg',
      ),
      Track(
        path: 'assets/albuns/escravos-do-tempo-continuo-e-lento/05 - Magnus Ignis.mp3',
        title: 'Magnus Ignis',
        imageAsset: 'assets/albuns/escravos-do-tempo-continuo-e-lento/51Lw+X7jACL._UXNaN_FMjpg_QL85_.jpg',
      ),
    ],
  ),
  Album(
    id: 'just',
    title: 'Just',
    coverAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
    tracks: [
      Track(
        path: 'assets/albuns/just/01 - Leprechaun.mp3',
        title: 'Leprechaun',
        duration: const Duration(minutes: 4, seconds: 3),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/02 - Painted on Your Face.mp3',
        title: 'Painted on Your Face',
        duration: const Duration(minutes: 4, seconds: 44),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/03 - All the Pleasures for You.mp3',
        title: 'All the Pleasures for You',
        duration: const Duration(minutes: 4, seconds: 12),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/04 - Weird.mp3',
        title: 'Weird',
        duration: const Duration(minutes: 4, seconds: 31),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/05 - Suicide Playground.mp3',
        title: 'Suicide Playground',
        duration: const Duration(minutes: 4, seconds: 18),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/06 - Carry Me to Chaos.mp3',
        title: 'Carry Me to Chaos',
        duration: const Duration(minutes: 3, seconds: 52),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/07 - Until the Day You Be Born.mp3',
        title: 'Until the Day You Be Born',
        duration: const Duration(minutes: 4, seconds: 3),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/08 - Corruption Messiah.mp3',
        title: 'Corruption Messiah',
        duration: const Duration(minutes: 4, seconds: 12),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/09 - Forbidden Tree.mp3',
        title: 'Forbidden Tree',
        duration: const Duration(minutes: 4, seconds: 41),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/10 - Cocaine Bread.mp3',
        title: 'Cocaine Bread',
        duration: const Duration(minutes: 4, seconds: 28),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/11 - Marys Secret Box.mp3',
        title: 'Marys Secret Box',
        duration: const Duration(minutes: 3, seconds: 41),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
      Track(
        path: 'assets/albuns/just/12 - Silent Sky.mp3',
        title: 'Silent Sky',
        duration: const Duration(minutes: 3, seconds: 18),
        imageAsset: 'assets/albuns/just/Jorge-Daux-@jorgedaux.webp',
      ),
    ],
  ),
];
