import 'dart:async';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

class AudioController {
  static final Logger _log = Logger('AudioController');

  SoLoud? _soloud;
  SoundHandle? _backgroundMusicHandle;

  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
  }

  void dispose() {
    _soloud?.deinit();
  }

  Future<void> playSound(String assetKey) async {
    try {
      final source = await _soloud!
          .loadAsset('assets/sounds/$assetKey', mode: LoadMode.disk);
      await _soloud!.play(source);
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }

  Future<void> playBackgroundMusic() async {
    if (_backgroundMusicHandle != null) {
      if (_soloud!.getIsValidVoiceHandle(_backgroundMusicHandle!)) {
        _log.info('Background music is already playing. Stopping first.');
        await _soloud!.stop(_backgroundMusicHandle!);
      }
    }

    _log.info('Loading background music');
    final musicSource = await _soloud!
        .loadAsset('assets/music/looped-song.ogg', mode: LoadMode.disk);
    musicSource.allInstancesFinished.first.then((_) {
      _soloud!.disposeSource(musicSource);
      _log.info('Background music source disposed');
      _backgroundMusicHandle = null;
    });

    _log.info('Playing background music');
    _backgroundMusicHandle = await _soloud!.play(
      musicSource,
      volume: 0.3, // Sesuaikan volume sesuai keinginan
      looping: true,
    );
  }

  void fadeOutMusic() {
    if (_backgroundMusicHandle == null) {
      _log.info('Nothing to fade out');
      return;
    }
    const length = Duration(seconds: 5);
    _soloud!.fadeVolume(_backgroundMusicHandle!, 0, length);
    _soloud!.scheduleStop(_backgroundMusicHandle!, length);
  }

  void applyFilter() {
    _soloud!.addGlobalFilter(FilterType.freeverbFilter);
    _soloud!.setFilterParameter(FilterType.freeverbFilter, 0, 0.2);
    _soloud!.setFilterParameter(FilterType.freeverbFilter, 2, 0.9);
  }

  void removeFilter() {
    _soloud!.removeGlobalFilter(FilterType.freeverbFilter);
  }


}
