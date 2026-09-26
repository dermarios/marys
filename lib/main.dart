import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'services/audio_service.dart' as pitty_audio;
import 'services/lock_screen_audio_handler.dart';
import 'screens/liquid_player_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/credits_screen.dart';
import 'screens/artist_screen.dart';
import 'widgets/mini_player.dart';

late LockScreenAudioHandler audioHandler;
late pitty_audio.PittyAudioService audioService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔄 Initializing AudioService...');
  final handler = await AudioService.init(
    builder: () => LockScreenAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.forven.pittyplayer.channel.audio',
      androidNotificationChannelName: 'Just',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  audioHandler = handler as LockScreenAudioHandler;
  print('✅ AudioService ready');

  audioService = pitty_audio.PittyAudioService(audioHandler);
  print('✅ PittyAudioService created');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeWithSwipe(),
    );
  }
}

class HomeWithSwipe extends StatefulWidget {
  const HomeWithSwipe({super.key});

  @override
  State<HomeWithSwipe> createState() => _HomeWithSwipeState();
}

class _HomeWithSwipeState extends State<HomeWithSwipe> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        ArtistScreen(
          audioService: audioService,
        ),
        LiquidPlayerScreen(
          audioService: audioService,
        ),
        PlayerShell(
          audioService: audioService,
          child: GalleryScreen(
            audioService: audioService,
          ),
        ),
        PlayerShell(
          audioService: audioService,
          child: CreditsScreen(
            audioService: audioService,
          ),
        ),
      ],
    );
  }
}
