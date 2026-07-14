import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:rxdart/rxdart.dart';

import 'package:aware/models/article.dart';
import 'package:aware/services/reader_audio_service.dart';

class _MockFlutterTts extends FlutterTts {
  bool stopped = false;
  bool spoken = false;
  bool speakThrows = false;
  bool stopThrows = false;
  String? spokenText;
  double? lastSpeechRate;
  Map<String, String>? lastVoiceSettings;
  int setVoiceCallCount = 0;

  void Function()? startHandler;
  ProgressHandler? progressHandler;
  void Function()? completionHandler;
  void Function()? cancelHandler;
  void Function()? pauseHandler;
  void Function()? continueHandler;

  @override
  Future<dynamic> awaitSpeakCompletion(bool enabled) async {}

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    lastSpeechRate = rate;
  }

  @override
  Future<dynamic> setVolume(double volume) async {}

  @override
  Future<dynamic> setPitch(double pitch) async {}

  @override
  Future<dynamic> setSharedInstance(bool shared) async {}

  @override
  Future<dynamic> setIosAudioCategory(
    IosTextToSpeechAudioCategory category, [
    List<IosTextToSpeechAudioCategoryOptions>? options,
    IosTextToSpeechAudioMode? mode,
  ]) async {
    return null;
  }

  @override
  Future<dynamic> setVoice(Map<String, String> voice) async {
    lastVoiceSettings = voice;
    setVoiceCallCount++;
    return null;
  }

  @override
  Future<dynamic> stop() async {
    if (stopThrows) throw Exception('TTS stop error');
    stopped = true;
    return null;
  }

  @override
  Future<dynamic> speak(String text) async {
    if (speakThrows) throw Exception('TTS error');
    spoken = true;
    spokenText = text;
    return null;
  }

  @override
  Future<dynamic> pause() async => null;

  @override
  void setStartHandler(void Function()? handler) {
    startHandler = handler;
  }

  @override
  void setProgressHandler(ProgressHandler callback) {
    progressHandler = callback;
  }

  @override
  void setCompletionHandler(void Function()? handler) {
    completionHandler = handler;
  }

  @override
  void setCancelHandler(void Function()? handler) {
    cancelHandler = handler;
  }

  @override
  void setPauseHandler(void Function()? handler) {
    pauseHandler = handler;
  }

  @override
  void setContinueHandler(void Function()? handler) {
    continueHandler = handler;
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('ReaderAudioHandler', () {
    late _MockFlutterTts mockTts;
    late ReaderAudioHandler handler;

    final sampleArticles = [
      Article(
        feedId: 1,
        guid: 'guid-1',
        title: 'Article One',
        author: 'Author A',
        summary: 'Summary one',
        publishedAt: 1000,
      ),
      Article(
        feedId: 1,
        guid: 'guid-2',
        title: 'Article Two',
        author: 'Author B',
        summary: 'Summary two',
        publishedAt: 2000,
      ),
      Article(
        feedId: 1,
        guid: 'guid-3',
        title: 'Article Three',
        author: 'Author C',
        summary: 'Summary three',
        publishedAt: 3000,
      ),
    ];

    setUp(() {
      mockTts = _MockFlutterTts();
      handler = ReaderAudioHandler(
        isAudioServiceBacked: false,
        tts: mockTts,
      );
    });

    tearDown(() {
      handler.readerState.close();
    });

    // _init() is async from the constructor; handlers are registered
    // asynchronously. Pump microtasks to let them complete.
    Future<void> _pump() async {
      for (var i = 0; i < 10; i++) {
        await Future.delayed(Duration.zero);
      }
    }

    test('standalone factory sets isAudioServiceBacked=false', () {
      // Construct via named constructor with mock TTS to avoid platform calls.
      final standalone = ReaderAudioHandler(
        isAudioServiceBacked: false,
        tts: mockTts,
      );
      expect(standalone.isAudioServiceBacked, isFalse);
      standalone.readerState.close();
    });

    test('play without content sets pendingAutoplay and buffering', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      // No content registered yet
      await handler.play();
      expect(mockTts.spoken, isFalse);
    });

    test('playback TTS error resets state', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: ['speak error'],
        paragraphOffsets: [0],
        plainText: 'speak error',
      );
      // Make TTS speak throw
      mockTts.speakThrows = true;
      await handler.activateArticle(0, autoplay: true);
      expect(handler.readerState.value.isPlaying, isFalse);
    });

    test('hasContentFor returns false for unregistered content', () {
      expect(handler.hasContentFor(0), isFalse);
      expect(handler.hasContentFor(5), isFalse);
    });

    test('hasContentFor returns true after registerArticleContent', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: ['Hello world'],
        paragraphOffsets: [0],
        plainText: 'Hello world',
      );
      expect(handler.hasContentFor(0), isTrue);
    });

    test('configureQueue sets up articles and media items', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      expect(handler.readerState.value.currentArticleIndex, 0);
    });

    test('configureQueue clamps currentIndex to valid range', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 999);
      expect(handler.readerState.value.currentArticleIndex, sampleArticles.length - 1);

      await handler.configureQueue(sampleArticles, currentIndex: -1);
      expect(handler.readerState.value.currentArticleIndex, 0);
    });

    test('activateArticle moves to next article', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: ['Paragraph one'],
        paragraphOffsets: [0],
        plainText: 'Paragraph one',
      );
      await handler.registerArticleContent(
        articleIndex: 1,
        paragraphs: ['Paragraph two'],
        paragraphOffsets: [0],
        plainText: 'Paragraph two',
      );

      await handler.activateArticle(1, autoplay: false);
      expect(handler.readerState.value.currentArticleIndex, 1);
    });

    test('skipToNext moves to next index', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 1,
        paragraphs: ['Next paragraph'],
        paragraphOffsets: [0],
        plainText: 'Next paragraph',
      );

      await handler.skipToNext();
      expect(handler.readerState.value.currentArticleIndex, 1);
    });

    test('skipToNext does not exceed last article', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 2);
      await handler.skipToNext();
      expect(handler.readerState.value.currentArticleIndex, 2);
    });

    test('skipToPrevious moves to previous index', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 1);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: ['Previous paragraph'],
        paragraphOffsets: [0],
        plainText: 'Previous paragraph',
      );

      await handler.skipToPrevious();
      expect(handler.readerState.value.currentArticleIndex, 0);
    });

    test('skipToPrevious does not go before first article', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.skipToPrevious();
      expect(handler.readerState.value.currentArticleIndex, 0);
    });

    test('activateArticle with autoplay starts TTS when content available', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 1,
        paragraphs: ['Playable content'],
        paragraphOffsets: [0],
        plainText: 'Playable content',
      );

      await handler.activateArticle(1, autoplay: true);
      expect(mockTts.spoken, isTrue);
      expect(mockTts.spokenText, 'Playable content');
    });

    test('activateArticle with autoplay sets pendingAutoplay when content missing', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.activateArticle(1, autoplay: true);
      // Content not registered, so pendingAutoplay should be true
      // and TTS should NOT have been called
      expect(mockTts.spoken, isFalse);
    });

    test('registerArticleContent triggers pending autoplay', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.activateArticle(1, autoplay: true);

      // Content wasn't registered yet, TTS shouldn't have spoken
      expect(mockTts.spoken, isFalse);

      // Now register content - should trigger pending autoplay
      await handler.registerArticleContent(
        articleIndex: 1,
        paragraphs: ['Deferred playable'],
        paragraphOffsets: [0],
        plainText: 'Deferred playable',
      );

      expect(mockTts.spoken, isTrue);
      expect(mockTts.spokenText, 'Deferred playable');
    });

    test('registerArticleContent skips pending autoplay when index changed', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.activateArticle(1, autoplay: true);

      // Simulate skip ahead while content was loading
      await handler.activateArticle(2, autoplay: true);

      // Register content for article 1 - should NOT trigger since _currentIndex is now 2
      await handler.registerArticleContent(
        articleIndex: 1,
        paragraphs: ['Should not play'],
        paragraphOffsets: [0],
        plainText: 'Should not play',
      );

      expect(mockTts.spoken, isFalse);
    });

    test('registerArticleContent with empty paragraphs does not crash', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: [],
        paragraphOffsets: [],
        plainText: '',
      );
      // Should not throw
    });

    test('stop stops TTS and resets state', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: ['Playing'],
        paragraphOffsets: [0],
        plainText: 'Playing',
      );
      await handler.registerArticleContent(
        articleIndex: 1,
        paragraphs: ['Next article'],
        paragraphOffsets: [0],
        plainText: 'Next article',
      );
      await handler.activateArticle(1, autoplay: true);
      expect(mockTts.spoken, isTrue);

      mockTts.spoken = false;
      await handler.stop();
      expect(handler.readerState.value.isPlaying, isFalse);
      expect(handler.readerState.value.isPaused, isFalse);
    });

    test('play resumes from paused state', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: ['Paragraph to resume'],
        paragraphOffsets: [0],
        plainText: 'Paragraph to resume',
      );
      await handler.registerArticleContent(
        articleIndex: 1,
        paragraphs: ['Next article'],
        paragraphOffsets: [0],
        plainText: 'Next article',
      );
      await handler.activateArticle(1, autoplay: true);
      mockTts.spoken = false;

      await handler.pause();
      expect(handler.readerState.value.isPaused, isTrue);

      await handler.play();
      expect(mockTts.spoken, isTrue);
    });

    group('normalizeWord', () {
      test('strips leading non-word characters', () {
        expect(handler.normalizeWord('..."hello'), 'hello');
      });

      test('strips trailing non-word characters', () {
        expect(handler.normalizeWord('hello...'), 'hello');
      });

      test('preserves word with no non-word characters', () {
        expect(handler.normalizeWord('hello'), 'hello');
      });

      test('handles empty string', () {
        expect(handler.normalizeWord(''), '');
      });

      test('handles string with only non-word characters', () {
        expect(handler.normalizeWord('...'), '');
      });
    });

    group('seek', () {
      test('recalculates paragraph based on position', () async {
        await handler.configureQueue(sampleArticles, currentIndex: 0);
        // plainText "aaabbb", offsets [0,3], words=2 => ~750ms
        await handler.registerArticleContent(
          articleIndex: 0,
          paragraphs: ['aaa', 'bbb'],
          paragraphOffsets: [0, 3],
          plainText: 'aaabbb',
        );
        mockTts.spoken = false;
        await handler.seek(const Duration(milliseconds: 500));
        expect(mockTts.spoken, isTrue);
        expect(mockTts.spokenText, 'bbb');
      });

      test('no-ops when no content registered', () async {
        await handler.configureQueue(sampleArticles, currentIndex: 0);
        await handler.seek(const Duration(milliseconds: 500));
        expect(mockTts.spoken, isFalse);
      });
    });

    group('updateSpeechConfig', () {
      test('updates speech rate on TTS', () async {
        await handler.updateSpeechConfig(
          speechRate: 0.7,
          voiceId: null,
          autoPlayNext: false,
        );
        expect(mockTts.lastSpeechRate, 0.7);
      });

      test('sets pipe-delimited voice correctly', () async {
        await handler.updateSpeechConfig(
          speechRate: 0.5,
          voiceId: 'com.example.voice|en-US',
          autoPlayNext: false,
        );
        expect(mockTts.lastVoiceSettings, {
          'name': 'com.example.voice',
          'locale': 'en-US',
        });
      });

      test('clears voice when voiceId changes to null', () async {
        // First set a voice
        await handler.updateSpeechConfig(
          speechRate: 0.5,
          voiceId: 'some-voice',
          autoPlayNext: false,
        );
        final beforeCount = mockTts.setVoiceCallCount;

        // Now clear it
        await handler.updateSpeechConfig(
          speechRate: 0.5,
          voiceId: null,
          autoPlayNext: false,
        );
        expect(mockTts.setVoiceCallCount, beforeCount + 1);
        // clearing sends empty name/locale
        expect(mockTts.lastVoiceSettings?['name'], '');
        expect(mockTts.lastVoiceSettings?['locale'], '');
      });

      test('skips voice update when voiceId unchanged', () async {
        await handler.updateSpeechConfig(
          speechRate: 0.5,
          voiceId: 'same-voice',
          autoPlayNext: false,
        );
        final afterFirst = mockTts.setVoiceCallCount;
        await handler.updateSpeechConfig(
          speechRate: 0.5,
          voiceId: 'same-voice',
          autoPlayNext: false,
        );
        expect(mockTts.setVoiceCallCount, afterFirst);
      });
    });

    group('completion handler', () {
      test('advances to next paragraph', () async {
        // Start at article 1 so activateArticle(0) actually changes index
        await handler.configureQueue(sampleArticles, currentIndex: 1);
        await handler.registerArticleContent(
          articleIndex: 0,
          paragraphs: ['first para', 'second para'],
          paragraphOffsets: [0, 11],
          plainText: 'first parasecond para',
        );
        await handler.activateArticle(0, autoplay: true);
        mockTts.spoken = false;

        // Trigger completion handler to advance to next paragraph
        mockTts.completionHandler!();
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration.zero);
        }
        expect(mockTts.spoken, isTrue);
        expect(mockTts.spokenText, 'second para');
      });

      test('finishes article on last paragraph', () async {
        await handler.configureQueue(sampleArticles, currentIndex: 1);
        await handler.registerArticleContent(
          articleIndex: 0,
          paragraphs: ['only para'],
          paragraphOffsets: [0],
          plainText: 'only para',
        );
        await handler.activateArticle(0, autoplay: true);
        for (var i = 0; i < 5; i++) {
          await Future.delayed(Duration.zero);
        }

        // Trigger completion handler on last (only) paragraph
        mockTts.completionHandler!();
        for (var i = 0; i < 10; i++) {
          await Future.delayed(Duration.zero);
        }
        expect(handler.readerState.value.isPlaying, isFalse);
      });
    });

    group('progress handler', () {
      test('resolves current word from progress callback', () async {
        await handler.configureQueue(sampleArticles, currentIndex: 1);
        await handler.registerArticleContent(
          articleIndex: 0,
          paragraphs: ['hello world'],
          paragraphOffsets: [0],
          plainText: 'hello world',
        );
        await handler.activateArticle(0, autoplay: true);
        // Trigger start handler to set _currentParagraphIndex properly
        mockTts.startHandler!();
        for (var i = 0; i < 3; i++) {
          await Future.delayed(Duration.zero);
        }

        // Simulate TTS reporting progress on "world"
        mockTts.progressHandler!('hello world', 6, 11, 'world');
        for (var i = 0; i < 3; i++) {
          await Future.delayed(Duration.zero);
        }
        expect(handler.readerState.value.currentWord, 'world');
      });
    });

    test('configureQueue with empty articles adds null mediaItem', () async {
      await handler.configureQueue([], currentIndex: 0);
      expect(handler.readerState.value.currentArticleIndex, 0);
    });

    test('activateArticle TTS stop error does not crash', () async {
      mockTts.stopThrows = true;
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: ['para'],
        paragraphOffsets: [0],
        plainText: 'para',
      );
      await handler.activateArticle(1, autoplay: false);
      expect(handler.readerState.value.currentArticleIndex, 1);
    });

    test('playFromParagraph starts playback at given paragraph', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.registerArticleContent(
        articleIndex: 0,
        paragraphs: ['first para', 'second para'],
        paragraphOffsets: [0, 11],
        plainText: 'first parasecond para',
      );
      await handler.playFromParagraph(1);
      expect(mockTts.spokenText, 'second para');
    });

    test('pause during pending autoplay cancels and resets state', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.activateArticle(1, autoplay: true);
      await _pump();
      await handler.pause();
      await _pump();
      expect(handler.readerState.value.isBuffering, isFalse);
      expect(handler.readerState.value.isPlaying, isFalse);
    });

    test('pause when not playing returns silently', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      await handler.pause();
      // Should not throw
      expect(handler.readerState.value.isPlaying, isFalse);
    });

    test('completion handler with no content returns silently', () async {
      await handler.configureQueue(sampleArticles, currentIndex: 0);
      // Don't register any content - _currentContent is null
      await _pump();
      mockTts.completionHandler!();
      await _pump();
      expect(handler.readerState.value.isPlaying, isFalse);
    });

    group('TTS handler callbacks', () {
      test('cancelHandler resets state', () async {
        await _pump();
        await handler.configureQueue(sampleArticles, currentIndex: 0);
        mockTts.cancelHandler!();
        expect(handler.readerState.value.isPlaying, isFalse);
        expect(handler.readerState.value.isPaused, isFalse);
      });

      test('pauseHandler sets paused state', () async {
        await _pump();
        await handler.configureQueue(sampleArticles, currentIndex: 0);
        mockTts.pauseHandler!();
        expect(handler.readerState.value.isPaused, isTrue);
      });

      test('continueHandler sets playing state', () async {
        await _pump();
        await handler.configureQueue(sampleArticles, currentIndex: 0);
        mockTts.continueHandler!();
        expect(handler.readerState.value.isPlaying, isTrue);
        expect(handler.readerState.value.isPaused, isFalse);
      });
    });

    group('startPlayback edge cases', () {
      test('play with empty paragraphs stops immediately', () async {
        await handler.configureQueue(sampleArticles, currentIndex: 0);
        await handler.registerArticleContent(
          articleIndex: 0,
          paragraphs: [],
          paragraphOffsets: [],
          plainText: '',
        );
        await handler.play();
        expect(handler.readerState.value.isPlaying, isFalse);
      });

      test('activateArticle on empty articles list returns silently', () async {
        // Never call configureQueue — articles list is empty
        await handler.activateArticle(0, autoplay: false);
        expect(handler.readerState.value.currentArticleIndex, 0);
      });
    });
  });
}
