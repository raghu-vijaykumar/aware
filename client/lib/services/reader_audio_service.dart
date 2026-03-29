import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:rxdart/rxdart.dart';

import '../models/article.dart';
import '../providers/app_state.dart';

ReaderAudioHandler? _readerAudioHandler;

ReaderAudioHandler get readerAudioHandler =>
    _readerAudioHandler ??= ReaderAudioHandler.standalone();

class ReaderPlaybackSnapshot {
  final bool isPlaying;
  final bool isPaused;
  final bool isBuffering;
  final int currentArticleIndex;
  final int currentParagraphIndex;
  final double progress;
  final String currentWord;

  const ReaderPlaybackSnapshot({
    required this.isPlaying,
    required this.isPaused,
    required this.isBuffering,
    required this.currentArticleIndex,
    required this.currentParagraphIndex,
    required this.progress,
    required this.currentWord,
  });

  const ReaderPlaybackSnapshot.idle()
      : isPlaying = false,
        isPaused = false,
        isBuffering = false,
        currentArticleIndex = 0,
        currentParagraphIndex = 0,
        progress = 0.0,
        currentWord = '';

  ReaderPlaybackSnapshot copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? isBuffering,
    int? currentArticleIndex,
    int? currentParagraphIndex,
    double? progress,
    String? currentWord,
  }) {
    return ReaderPlaybackSnapshot(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isBuffering: isBuffering ?? this.isBuffering,
      currentArticleIndex: currentArticleIndex ?? this.currentArticleIndex,
      currentParagraphIndex:
          currentParagraphIndex ?? this.currentParagraphIndex,
      progress: progress ?? this.progress,
      currentWord: currentWord ?? this.currentWord,
    );
  }
}

class _ArticleSpeechContent {
  final List<String> paragraphs;
  final List<int> paragraphOffsets;
  final String plainText;

  const _ArticleSpeechContent({
    required this.paragraphs,
    required this.paragraphOffsets,
    required this.plainText,
  });
}

class ReaderAudioService {
  static Future<void> ensureInitialized() async {
    if (_readerAudioHandler != null &&
        (_readerAudioHandler!.isAudioServiceBacked ||
            kIsWeb ||
            (!Platform.isAndroid && !Platform.isIOS))) {
      return;
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _readerAudioHandler ??= ReaderAudioHandler.standalone();
      return;
    }

    _readerAudioHandler = await AudioService.init(
      builder: ReaderAudioHandler.new,
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.example.aware.aware.reader_audio',
        androidNotificationChannelName: 'Reader playback',
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }
}

class ReaderAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final bool isAudioServiceBacked;
  final FlutterTts _tts = FlutterTts();
  final BehaviorSubject<ReaderPlaybackSnapshot> readerState =
      BehaviorSubject.seeded(const ReaderPlaybackSnapshot.idle());

  final Map<int, _ArticleSpeechContent> _contentByIndex = {};
  List<Article> _articles = const [];
  int _currentIndex = 0;
  int _currentParagraphIndex = 0;
  int _offsetBase = 0;
  double _speechRate = AppState.speechRateBase;
  String? _voiceId;
  bool _autoPlayNext = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isBuffering = false;
  bool _pendingAutoplay = false;
  String _currentWord = '';

  ReaderAudioHandler({this.isAudioServiceBacked = true}) {
    _init();
  }

  ReaderAudioHandler.standalone() : this(isAudioServiceBacked: false);

  Future<void> _init() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(AppState.speechRateBase);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.allowAirPlay,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    }

    _attachTtsHandlers();
    _broadcastState(processingState: AudioProcessingState.idle);
  }

  _ArticleSpeechContent? get _currentContent => _contentByIndex[_currentIndex];

  Future<void> configureQueue(
    List<Article> articles, {
    required int currentIndex,
  }) async {
    _articles = List<Article>.unmodifiable(articles);
    _currentIndex = _clampIndex(currentIndex);
    final items = List<MediaItem>.generate(
      _articles.length,
      _buildMediaItem,
      growable: false,
    );
    queue.add(items);
    if (items.isNotEmpty) {
      mediaItem.add(items[_currentIndex]);
    } else {
      mediaItem.add(null);
    }
    _publishSnapshot(
      currentArticleIndex: _currentIndex,
      currentParagraphIndex: _currentParagraphIndex,
      progress: readerState.value.progress,
      currentWord: _currentWord,
    );
    _broadcastState(
      processingState:
          _isPlaying ? AudioProcessingState.ready : AudioProcessingState.idle,
    );
  }

  Future<void> registerArticleContent({
    required int articleIndex,
    required List<String> paragraphs,
    required List<int> paragraphOffsets,
    required String plainText,
  }) async {
    _contentByIndex[articleIndex] = _ArticleSpeechContent(
      paragraphs: List<String>.unmodifiable(paragraphs),
      paragraphOffsets: List<int>.unmodifiable(paragraphOffsets),
      plainText: plainText,
    );

    if (_currentIndex == articleIndex) {
      mediaItem.add(_buildMediaItem(articleIndex));
      _broadcastState();
      if (_pendingAutoplay) {
        _pendingAutoplay = false;
        await _startPlayback(paragraphIndex: _currentParagraphIndex);
      }
    }
  }

  Future<void> updateSpeechConfig({
    required double speechRate,
    required String? voiceId,
    required bool autoPlayNext,
  }) async {
    _autoPlayNext = autoPlayNext;

    if ((_speechRate - speechRate).abs() > 0.001) {
      _speechRate = speechRate;
      await _tts.setSpeechRate(speechRate);
    }

    if (_voiceId == voiceId) return;
    _voiceId = voiceId;

    if (voiceId == null) {
      try {
        await _tts.setVoice({'name': '', 'locale': ''});
      } catch (_) {
        // Some engines do not support clearing the selected voice explicitly.
      }
      return;
    }

    final parts = voiceId.split('|');
    final name = parts.isNotEmpty ? parts[0] : null;
    final locale = parts.length > 1 ? parts[1] : null;
    await _tts.setVoice({
      if (name != null) 'name': name,
      if (locale != null) 'locale': locale,
    });
  }

  Future<void> activateArticle(
    int index, {
    bool autoplay = false,
    int paragraphIndex = 0,
  }) async {
    if (_articles.isEmpty) return;

    final targetIndex = _clampIndex(index);
    final changedArticle = targetIndex != _currentIndex;
    if (changedArticle) {
      await _tts.stop();
    }

    _currentIndex = targetIndex;
    _currentParagraphIndex = paragraphIndex.clamp(
      0,
      _maxParagraphIndexFor(targetIndex),
    );
    _offsetBase = _offsetForParagraph(_currentIndex, _currentParagraphIndex);
    _currentWord = '';
    _isPlaying = false;
    _isPaused = false;
    _pendingAutoplay = autoplay;

    mediaItem.add(_buildMediaItem(_currentIndex));
    _publishSnapshot(
      currentArticleIndex: _currentIndex,
      currentParagraphIndex: _currentParagraphIndex,
      progress: _progressForParagraph(_currentIndex, _currentParagraphIndex),
      currentWord: '',
    );

    final hasContent = _contentByIndex.containsKey(_currentIndex);
    _isBuffering = autoplay && !hasContent;
    _broadcastState(
      processingState: _isBuffering
          ? AudioProcessingState.loading
          : AudioProcessingState.ready,
    );

    if (autoplay && hasContent) {
      _pendingAutoplay = false;
      await _startPlayback(paragraphIndex: _currentParagraphIndex);
    }
  }

  Future<void> playFromParagraph(int paragraphIndex) async {
    await _startPlayback(paragraphIndex: paragraphIndex);
  }

  @override
  Future<void> play() async {
    if (_isPaused) {
      await _resumePlayback();
      return;
    }
    await _startPlayback(paragraphIndex: _currentParagraphIndex);
  }

  @override
  Future<void> pause() async {
    if (!_isPlaying) return;
    await _tts.pause();
  }

  @override
  Future<void> stop() async {
    _pendingAutoplay = false;
    await _tts.stop();
    _isPlaying = false;
    _isPaused = false;
    _isBuffering = false;
    _currentWord = '';
    _publishSnapshot(currentWord: '', progress: readerState.value.progress);
    _broadcastState(processingState: AudioProcessingState.idle);
  }

  @override
  Future<void> seek(Duration position) async {
    final content = _currentContent;
    if (content == null || content.plainText.isEmpty) return;

    final duration = _estimatedDurationForContent(content);
    if (duration.inMilliseconds <= 0) return;

    final ratio = (position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    final targetOffset = (content.plainText.length * ratio).round();
    final paragraphIndex = content.paragraphOffsets.lastIndexWhere(
      (offset) => offset <= targetOffset,
    );
    final targetParagraph = paragraphIndex < 0 ? 0 : paragraphIndex;
    await _startPlayback(paragraphIndex: targetParagraph);
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex >= _articles.length - 1) return;
    await activateArticle(
      _currentIndex + 1,
      autoplay: _isPlaying,
      paragraphIndex: 0,
    );
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex <= 0) return;
    await activateArticle(
      _currentIndex - 1,
      autoplay: _isPlaying,
      paragraphIndex: 0,
    );
  }

  Future<void> _startPlayback({required int paragraphIndex}) async {
    final content = _currentContent;
    if (content == null || content.paragraphs.isEmpty) {
      _pendingAutoplay = true;
      _isBuffering = true;
      _broadcastState(processingState: AudioProcessingState.loading);
      return;
    }

    final targetParagraph =
        paragraphIndex.clamp(0, content.paragraphs.length - 1);
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      final session = await AudioSession.instance;
      final activated = await session.setActive(true);
      if (!activated) return;
    }

    _pendingAutoplay = false;
    _isBuffering = false;
    _currentParagraphIndex = targetParagraph;
    _offsetBase = _offsetForParagraph(_currentIndex, targetParagraph);
    _publishSnapshot(
      currentArticleIndex: _currentIndex,
      currentParagraphIndex: targetParagraph,
      progress: _progressForParagraph(_currentIndex, targetParagraph),
      currentWord: '',
    );
    _broadcastState(processingState: AudioProcessingState.ready);

    await _tts.stop();
    await _tts.speak(content.paragraphs[targetParagraph]);
  }

  Future<void> _resumePlayback() async {
    await _startPlayback(paragraphIndex: _currentParagraphIndex);
  }

  void _attachTtsHandlers() {
    _tts.setStartHandler(() {
      _isPlaying = true;
      _isPaused = false;
      _isBuffering = false;
      _broadcastState(processingState: AudioProcessingState.ready);
      _publishSnapshot(currentWord: '');
    });

    _tts.setProgressHandler((String text, int start, int end, String? word) {
      final content = _currentContent;
      if (content == null || content.plainText.isEmpty) return;

      final absolute = (_offsetBase + start).clamp(0, content.plainText.length);
      final progress = absolute / content.plainText.length;
      final paragraphIndex = content.paragraphOffsets
          .lastIndexWhere((offset) => offset <= absolute);

      _currentParagraphIndex = paragraphIndex >= 0 ? paragraphIndex : 0;
      _currentWord = _resolveCurrentWord(
        content.plainText,
        text,
        start,
        end,
        word,
      );
      _publishSnapshot(
        currentArticleIndex: _currentIndex,
        currentParagraphIndex: _currentParagraphIndex,
        progress: progress,
        currentWord: _currentWord,
      );
      _broadcastState();
    });

    _tts.setCompletionHandler(() async {
      final content = _currentContent;
      if (content == null) return;

      final nextParagraph = _currentParagraphIndex + 1;
      if (nextParagraph < content.paragraphs.length) {
        await _startPlayback(paragraphIndex: nextParagraph);
        return;
      }

      _isPlaying = false;
      _isPaused = false;
      _currentWord = '';
      _publishSnapshot(progress: 1.0, currentWord: '');
      _broadcastState(processingState: AudioProcessingState.completed);

      if (_autoPlayNext && _currentIndex < _articles.length - 1) {
        await activateArticle(_currentIndex + 1, autoplay: true);
      }
    });

    _tts.setCancelHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _isBuffering = false;
      _currentWord = '';
      _publishSnapshot(currentWord: '');
      _broadcastState(
        processingState: _pendingAutoplay
            ? AudioProcessingState.loading
            : AudioProcessingState.ready,
      );
    });

    _tts.setPauseHandler(() {
      _isPlaying = false;
      _isPaused = true;
      _broadcastState(processingState: AudioProcessingState.ready);
    });

    _tts.setContinueHandler(() {
      _isPlaying = true;
      _isPaused = false;
      _broadcastState(processingState: AudioProcessingState.ready);
    });
  }

  MediaItem _buildMediaItem(int index) {
    final article = _articles[index];
    final content = _contentByIndex[index];
    final duration =
        content == null ? null : _estimatedDurationForContent(content);
    final artUri = article.imageUrl == null || article.imageUrl!.isEmpty
        ? null
        : Uri.tryParse(article.imageUrl!);

    return MediaItem(
      id: article.guid,
      title: article.title ?? 'Article',
      artist: article.author,
      artUri: artUri,
      duration: duration,
      playable: true,
      extras: {'articleIndex': index},
    );
  }

  Duration _estimatedDurationForContent(_ArticleSpeechContent content) {
    final words = RegExp(r'\S+').allMatches(content.plainText).length;
    if (words == 0) return Duration.zero;
    final speedRatio = (_speechRate / AppState.speechRateBase).clamp(0.5, 4.0);
    final seconds = (words / (160 * speedRatio)) * 60;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  int _clampIndex(int index) {
    if (_articles.isEmpty) return 0;
    return index.clamp(0, _articles.length - 1);
  }

  int _maxParagraphIndexFor(int articleIndex) {
    final content = _contentByIndex[articleIndex];
    if (content == null || content.paragraphs.isEmpty) return 0;
    return content.paragraphs.length - 1;
  }

  int _offsetForParagraph(int articleIndex, int paragraphIndex) {
    final content = _contentByIndex[articleIndex];
    if (content == null || content.paragraphOffsets.isEmpty) return 0;
    final index = paragraphIndex.clamp(0, content.paragraphOffsets.length - 1);
    return content.paragraphOffsets[index];
  }

  double _progressForParagraph(int articleIndex, int paragraphIndex) {
    final content = _contentByIndex[articleIndex];
    if (content == null || content.plainText.isEmpty) return 0.0;
    return (_offsetForParagraph(articleIndex, paragraphIndex) /
            content.plainText.length)
        .clamp(0.0, 1.0);
  }

  String _resolveCurrentWord(
    String plainText,
    String ttsText,
    int start,
    int end,
    String? reportedWord,
  ) {
    final fromReported = _normalizeWord(reportedWord ?? '');
    if (fromReported.isNotEmpty) return fromReported;

    if (start >= 0 && end > start && end <= ttsText.length) {
      final fromRange = _normalizeWord(ttsText.substring(start, end));
      if (fromRange.isNotEmpty) return fromRange;
    }

    final absoluteIndex = (_offsetBase + start).clamp(0, plainText.length);
    var left = absoluteIndex;
    while (left > 0 && RegExp(r'[\w]').hasMatch(plainText[left - 1])) {
      left -= 1;
    }
    var right = absoluteIndex;
    while (right < plainText.length &&
        RegExp(r'[\w]').hasMatch(plainText[right])) {
      right += 1;
    }
    if (right > left) {
      return _normalizeWord(plainText.substring(left, right));
    }
    return '';
  }

  String _normalizeWord(String input) {
    return input.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '').trim();
  }

  void _publishSnapshot({
    bool? isPlaying,
    bool? isPaused,
    bool? isBuffering,
    int? currentArticleIndex,
    int? currentParagraphIndex,
    double? progress,
    String? currentWord,
  }) {
    readerState.add(
      readerState.value.copyWith(
        isPlaying: isPlaying ?? _isPlaying,
        isPaused: isPaused ?? _isPaused,
        isBuffering: isBuffering ?? _isBuffering,
        currentArticleIndex: currentArticleIndex ?? _currentIndex,
        currentParagraphIndex: currentParagraphIndex ?? _currentParagraphIndex,
        progress: (progress ?? readerState.value.progress).clamp(0.0, 1.0),
        currentWord: currentWord ?? _currentWord,
      ),
    );
  }

  void _broadcastState({
    AudioProcessingState? processingState,
  }) {
    final content = _currentContent;
    final duration =
        content == null ? Duration.zero : _estimatedDurationForContent(content);
    final progress = readerState.value.progress.clamp(0.0, 1.0);
    final position = Duration(
      milliseconds: (duration.inMilliseconds * progress).round(),
    );

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (_isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.playPause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState ??
            (_isBuffering
                ? AudioProcessingState.loading
                : _isPlaying || _isPaused
                    ? AudioProcessingState.ready
                    : AudioProcessingState.idle),
        playing: _isPlaying,
        updatePosition: position,
        bufferedPosition: position,
        speed: 1.0,
        queueIndex: _articles.isEmpty ? null : _currentIndex,
      ),
    );
  }
}
