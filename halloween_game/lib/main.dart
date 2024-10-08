import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Catch Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EmojiCatchGame(),
    );
  }
}

class EmojiCatchGame extends StatefulWidget {
  const EmojiCatchGame({super.key});

  @override
  _EmojiCatchGameState createState() => _EmojiCatchGameState();
}

class _EmojiCatchGameState extends State<EmojiCatchGame> {
  double paddlePosition = 0.5;
  double paddleWidth = 100.0;
  List<EmojiItem> fallingEmojis = [];
  int score = 0;
  late Timer emojiTimer;
  late Timer gameTimer;
  int timeLeft = 60;
  bool gameOver = false;
  final backgroundMusicPlayer = AudioPlayer();
  final soundEffectPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    backgroundMusicPlayer.setLoopMode(LoopMode.all);
    backgroundMusicPlayer.setAsset('img_sound/soundeffect_halloween.aac');
    backgroundMusicPlayer.play();
    resetGame();
  }

  void spawnEmojis() async {
    Random random = Random();
    while (!gameOver) {
      await Future.delayed(Duration(seconds: random.nextInt(3) + 1));
      if (!gameOver) {
        setState(() {
          fallingEmojis.add(EmojiItem(
            leftPosition: random.nextDouble(),
            topPosition: 0.0,
            emoji: random.nextBool() ? '🎃' : '🍬',
            isCorrect: true,
          ));

          fallingEmojis.add(EmojiItem(
            leftPosition: random.nextDouble(),
            topPosition: 0.0,
            emoji: random.nextBool() ? '👻' : '🦇',
            isCorrect: false,
          ));
        });
      }
    }
  }

  void startEmojiTimer() {
    emojiTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        for (var emoji in fallingEmojis) {
          emoji.move();
        }
        checkCollisions();
        fallingEmojis.removeWhere((emoji) => emoji.topPosition > 1.0);
      });
    });
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        gameTimer.cancel();
        setState(() {
          gameOver = true;
          emojiTimer.cancel();
        });
      }
    });
  }

  void checkCollisions() {
    for (var emoji in fallingEmojis) {
      if (emoji.topPosition > 0.9 &&
          emoji.leftPosition >= paddlePosition - 0.05 &&
          emoji.leftPosition <=
              paddlePosition +
                  (paddleWidth / MediaQuery.of(context).size.width) +
                  0.05) {
        setState(() {
          if (emoji.isCorrect) {
            score += 10;
            soundEffectPlayer.setAsset('img_sound/soundeffect_win.aac');
            soundEffectPlayer.play();
          } else {
            score -= 10;
            soundEffectPlayer.setAsset('img_sound/soundeffect_loss_spooky.aac');
            soundEffectPlayer.play();
          }
          emoji.topPosition = 2.0;
        });
      }
    }
  }

  void resetGame() {
    setState(() {
      score = 0;
      timeLeft = 60;
      gameOver = false;
      fallingEmojis.clear();
    });
    startEmojiTimer();
    startGameTimer();
    spawnEmojis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            paddlePosition +=
                details.delta.dx / MediaQuery.of(context).size.width;
            paddlePosition = paddlePosition.clamp(
                0.0, 1.0 - paddleWidth / MediaQuery.of(context).size.width);
          });
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'img_sound/bkgdimg_halloween.jpg',
                fit: BoxFit.cover,
              ),
            ),
            for (var emoji in fallingEmojis)
              Positioned(
                left: emoji.leftPosition * MediaQuery.of(context).size.width,
                top: emoji.topPosition * MediaQuery.of(context).size.height,
                child: Text(
                  emoji.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            Positioned(
              left: paddlePosition * MediaQuery.of(context).size.width,
              bottom: 20,
              child: Container(
                width: paddleWidth,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.brown[700],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(2, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '👻',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.orange,
                  fontFamily: 'Creepster',
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: Text(
                'Time: $timeLeft',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.orange,
                  fontFamily: 'Creepster',
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            if (gameOver)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          score >= 100 ? 'Congratulations!' : 'Game Over',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.orange,
                            fontFamily: 'Creepster',
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your score: $score',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.orange,
                            fontFamily: 'Creepster',
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: resetGame,
                          child: const Text('Start Over'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emojiTimer.cancel();
    gameTimer.cancel();
    backgroundMusicPlayer.dispose();
    soundEffectPlayer.dispose();
    super.dispose();
  }
}

class EmojiItem {
  double leftPosition;
  double topPosition;
  final String emoji;
  final bool isCorrect;

  EmojiItem({
    required this.leftPosition,
    required this.topPosition,
    required this.emoji,
    required this.isCorrect,
  });

  void move() {
    topPosition += 0.015;
  }
}
