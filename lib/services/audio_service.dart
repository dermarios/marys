import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/track.dart';
import '../models/album.dart';
import 'lock_screen_audio_handler.dart';

class PittyAudioService {
  late AudioPlayer _player;
  late LockScreenAudioHandler _audioHandler;
  List<Track> _tracks = [];
  Album? _currentAlbum;
  bool _tracksLoaded = false;
  int _repeatMode = 0;
  bool _shuffleMode = false;
  Set<String> _likedTracks = {};
  final _random = math.Random();
  Future<void>? _cargaInicial;
  int _trocasPendentes = 0;

  StreamSubscription<int?>? _currentIndexSubscription;

  late final ValueNotifier<Track?> currentTrackNotifier;
  late final ValueNotifier<Album?> currentAlbumNotifier;

  final _opQueue = <Future<void> Function()>[];
  bool _emExecucao = false;

  PittyAudioService(this._audioHandler) {
    _player = _audioHandler.player;
    currentTrackNotifier = ValueNotifier<Track?>(null);
    currentAlbumNotifier = ValueNotifier<Album?>(null);
    _initializeAudioSession().ignore();
    _setupCurrentTrackListener();
  }

  void _setupCurrentTrackListener() {
    _currentIndexSubscription = _player.currentIndexStream.listen((index) {
      if (_trocasPendentes > 0) return;
      if (index != null && index < _tracks.length) {
        currentTrackNotifier.value = _tracks[index];
      }
    });
  }

  void _publicarEstadoReal() {
    if (_currentAlbum != null) {
      currentAlbumNotifier.value = _currentAlbum;
    }
    final index = _player.currentIndex ?? 0;
    if (index >= 0 && index < _tracks.length) {
      currentTrackNotifier.value = _tracks[index];
    }
  }

  Future<void> _initializeAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      print('Error configuring audio session: $e');
    }
  }

  Future<T> _emSerie<T>(Future<T> Function() op) async {
    final completer = Completer<T>();
    _opQueue.add(() async {
      try {
        final resultado = await op();
        completer.complete(resultado);
      } catch (e) {
        completer.completeError(e);
      }
      return;
    });
    _processarFila();
    return completer.future;
  }

  void _processarFila() {
    if (_emExecucao || _opQueue.isEmpty) return;
    _emExecucao = true;
    _executarProxima();
  }

  void _executarProxima() {
    if (_opQueue.isEmpty) {
      _emExecucao = false;
      return;
    }
    final op = _opQueue.removeAt(0);
    op().whenComplete(_executarProxima);
  }

  void _tocar() {
    _player.play().catchError((e) {
      print('✗ Erro ao tocar: $e');
    });
  }

  Future<void> loadTracks() async {
    _cargaInicial ??= _emSerie<void>(() async {
      if (_tracksLoaded) return;
      _tracks = kAlbums.first.tracks;
      _currentAlbum = kAlbums.first;

      await _audioHandler.initializePlaylist(_tracks);

      if (_tracks.isNotEmpty) {
        currentTrackNotifier.value = _tracks.first;
      }
      currentAlbumNotifier.value = kAlbums.first;
      _tracksLoaded = true;
      print('✓ Faixas iniciais carregadas');
    });
    return _cargaInicial;
  }

  Future<void> loadAlbum(Album album) async {
    return _emSerie<void>(() async {
      _tracks = album.tracks;
      _currentAlbum = album;
      await _audioHandler.initializePlaylist(_tracks, initialIndex: 0);
      currentAlbumNotifier.value = album;
      if (_tracks.isNotEmpty) {
        currentTrackNotifier.value = _tracks.first;
      }
      print('✓ Álbum carregado: ${album.title} (${_tracks.length} faixas)');
    });
  }

  Future<void> playAlbum(Album album, {int startIndex = 0}) async {
    if (album.tracks.isEmpty) return Future.value();

    if (!identical(_currentAlbum, album)) {
      currentAlbumNotifier.value = album;
      if (album.tracks.isNotEmpty && startIndex < album.tracks.length) {
        currentTrackNotifier.value = album.tracks[startIndex];
      }
    }

    return _emSerie<void>(() async {
      _trocasPendentes++;
      try {
        final mesmoAlbum = identical(_currentAlbum, album);

        if (mesmoAlbum) {
          if (!_player.playing) {
            _tocar();
            print('→ Retomando álbum pausado');
          } else {
            print('✓ Álbum já está tocando');
          }
          return;
        }

        await _player.pause();
        _tracks = album.tracks;
        _currentAlbum = album;
        await _audioHandler.initializePlaylist(_tracks, initialIndex: startIndex);

        if (_tracks.isNotEmpty) {
          _tocar();
          print('→ Tocando: ${_tracks[startIndex].title}');
        }
      } finally {
        _trocasPendentes--;
        if (_trocasPendentes == 0) {
          _publicarEstadoReal();
        }
      }
    });
  }

  Future<void> play(Track track) async {
    return _emSerie<void>(() async {
      try {
        final trackIndex = _tracks.indexOf(track);
        if (trackIndex == -1) {
          print('✗ Faixa não encontrada: ${track.title}');
          return;
        }

        await _player.seek(Duration.zero, index: trackIndex);
        currentTrackNotifier.value = track;
        _tocar();
        print('→ Tocando: ${track.title}');
      } catch (e) {
        print('✗ Erro ao tocar faixa: $e');
        rethrow;
      }
    });
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    _tocar();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    if (_tracks.isEmpty) return;

    if (_shuffleMode) {
      final randomIndex = _random.nextInt(_tracks.length);
      await play(_tracks[randomIndex]);
    } else if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> previous() async {
    if (_tracks.isEmpty) return;

    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  AudioPlayer get player => _player;
  List<Track> get tracks => _tracks;
  Track? get currentTrack => currentTrackNotifier.value;
  Album? get currentAlbum => _currentAlbum;
  int get repeatMode => _repeatMode;
  bool get shuffleMode => _shuffleMode;

  void toggleRepeatMode() {
    _repeatMode = (_repeatMode + 1) % 3;
    _player.setLoopMode(
      _repeatMode == 0 ? LoopMode.off :
      _repeatMode == 1 ? LoopMode.one :
      LoopMode.all
    );
  }

  void toggleShuffle() {
    _shuffleMode = !_shuffleMode;
    _player.setShuffleModeEnabled(_shuffleMode);
  }

  bool isLiked(Track track) => _likedTracks.contains(track.path);

  void toggleLike(Track track) {
    if (_likedTracks.contains(track.path)) {
      _likedTracks.remove(track.path);
    } else {
      _likedTracks.add(track.path);
    }
  }

  void dispose() {
    _currentIndexSubscription?.cancel();
    currentTrackNotifier.dispose();
    currentAlbumNotifier.dispose();
    _player.dispose();
  }
}

typedef AudioService = PittyAudioService;
