import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const int gridSize = 20;
  static const int snakeSpeed = 300;

  List<int> snake = [45, 65, 85];
  int food = Random().nextInt(gridSize * gridSize);
  Direction direction = Direction.right;
  bool isPlaying = false;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    setState(() {
      snake = [45, 65, 85];
      direction = Direction.right;
      isPlaying = true;
      isGameOver = false;
    });

    moveSnake();
  }

  /*void moveSnake() async {
    while (isPlaying) {
      await Future.delayed(Duration(milliseconds: snakeSpeed));
      setState(() {
        final snakeHead = snake.last;

        if (direction == Direction.right) {
          if (snakeHead % gridSize == gridSize - 1 ||
              snake.contains(snakeHead + 1)) {
            gameOver();
            return;
          }
          snake.add(snakeHead + 1);
        } else if (direction == Direction.left) {
          if (snakeHead % gridSize == 0 || snake.contains(snakeHead - 1)) {
            gameOver();
            return;
          }
          snake.add(snakeHead - 1);
        } else if (direction == Direction.up) {
          if (snakeHead < gridSize || snake.contains(snakeHead - gridSize)) {
            gameOver();
            return;
          }
          snake.add(snakeHead - gridSize);
        } else if (direction == Direction.down) {
          if (snakeHead >= (gridSize * gridSize) - gridSize ||
              snake.contains(snakeHead + gridSize)) {
            gameOver();
            return;
          }
          snake.add(snakeHead + gridSize);
        }

        if (snake.last == food) {
          generateFood();
        } else {
          snake.removeAt(0);
        }
      });
    }
  }
*/

  void moveSnake() async {
    while (isPlaying) {
      await Future.delayed(Duration(milliseconds: snakeSpeed));
      setState(() {
        final snakeHead = snake.last;

        if (direction == Direction.right) {
          if (snakeHead % gridSize == gridSize - 1) {
            gameOver();
            return;
          }
          snake.add(snakeHead + 1);
        } else if (direction == Direction.left) {
          if (snakeHead % gridSize == 0) {
            gameOver();
            return;
          }
          snake.add(snakeHead - 1);
        } else if (direction == Direction.up) {
          if (snakeHead < gridSize) {
            gameOver();
            return;
          }
          snake.add(snakeHead - gridSize);
        } else if (direction == Direction.down) {
          if (snakeHead >= (gridSize * gridSize) - gridSize) {
            gameOver();
            return;
          }
          snake.add(snakeHead + gridSize);
        }

        if (snake.last == food) {
          generateFood();
        } else {
          snake.removeAt(0);
        }
      });
    }
  }

  void generateFood() {
    final random = Random();
    food = random.nextInt(gridSize * gridSize);
    if (snake.contains(food)) {
      generateFood();
    }
  }

  void gameOver() {
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('You scored ${snake.length - 3} points.'),
          actions: [
            ElevatedButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void handleKeyPress(LogicalKeyboardKey key) {
    if (!isPlaying) return;

    if (key == LogicalKeyboardKey.arrowUp && direction != Direction.down) {
      setState(() {
        direction = Direction.up;
      });
    } else if (key == LogicalKeyboardKey.arrowDown &&
        direction != Direction.up) {
      setState(() {
        direction = Direction.down;
      });
    } else if (key == LogicalKeyboardKey.arrowLeft &&
        direction != Direction.right) {
      setState(() {
        direction = Direction.left;
      });
    } else if (key == LogicalKeyboardKey.arrowRight &&
        direction != Direction.left) {
      setState(() {
        direction = Direction.right;
      });
    }
  }

  void toggleGame() {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      moveSnake();
    }
  }

  void restartGame() {
    startGame();
  }

  Widget buildSnakeCell(int index) {
    final isSnakeHead = index == snake.last;
    final isSnakeBody = snake.contains(index);
    final isFood = index == food;

    Color cellColor;
    if (isSnakeHead) {
      cellColor = Colors.green;
    } else if (isSnakeBody) {
      cellColor = Colors.lightGreen;
    } else if (isFood) {
      cellColor = Colors.red;
    } else {
      cellColor = Colors.grey;
    }

    Widget getSnakeWidget() {
      if (isSnakeHead) {
        return Container(
          color: Colors.green,
        );
      } else if (isSnakeBody) {
        return Container(
          color: Colors.lightGreen,
        );
      } else if (isFood) {
        return Container(
            child: Container(
          color: Colors.red,
        ));
      } else {
        return Container(
          color: Colors.grey,
        );
      }
    }

    return Container(
      child: getSnakeWidget(),
      /*decoration: BoxDecoration(
        color: cellColor,
        // borderRadius: BorderRadius.circular(4),
      ),*/
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          setState(() {
            if (details.delta.dy > 0 && direction != Direction.up) {
              direction = Direction.down;
            } else if (details.delta.dy < 0 && direction != Direction.down) {
              direction = Direction.up;
            }
          });
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            if (details.delta.dx > 0 && direction != Direction.left) {
              direction = Direction.right;
            } else if (details.delta.dx < 0 && direction != Direction.right) {
              direction = Direction.left;
            }
          });
        },
        child: Container(
          color: Colors.black,
          child: Column(
            children: [
              Flexible(
                child: GridView.builder(
                  itemCount: gridSize * gridSize,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemBuilder: (context, index) {
                    return buildSnakeCell(index);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            direction = Direction.up;
                          });
                        },
                        child: const Icon(
                          CupertinoIcons.arrow_up,
                          color: Colors.white,
                          size: 40,
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                direction = Direction.left;
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.arrow_left,
                              color: Colors.white,
                              size: 40,
                            )),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                direction = Direction.right;
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.arrow_right,
                              color: Colors.white,
                              size: 40,
                            )),
                      ],
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            direction = Direction.down;
                          });
                        },
                        child: const Icon(
                          CupertinoIcons.down_arrow,
                          color: Colors.white,
                          size: 40,
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: toggleGame,
              child: isPlaying ? const Text('Pause') : const Text('Play'),
            ),
            ElevatedButton(
              onPressed: isGameOver ? restartGame : null,
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
