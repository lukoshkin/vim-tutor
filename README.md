# Vim-tutor

Learn Vim by competing with others!

## Usage

* To start the "join lines" competition from the project folder:

  ```bash
  ./tutor.sh compete archive/join_lines
  ```

  Which opens `join_lines/tasks.md` and `join_lines/answers.md` in Vim diff mode,
  after showing a preamble. You can quickly toggle the highlighting of diverging
  lines with `do` mapping in normal mode. However, when it is on, you hardly
  leave the competition prematurely if not intentionally. After saving the
  results and closing Vim, the score appears on the screen.

![](png/preamble.png)
![](png/diff-mode.png)
![](png/score.png)

---

* Take up creating your own challenge with a stencil:

  ```bash
  ./tutor.sh stencil -a lukoshkin -p fancy_name archive/fancy_name
  ```

  This creates a proper folder structure of files you need to fill. The
  specified options above add entries about the author and the problem name to
  `tasks.md` file (as well as to `answers.md` and README.md). Anytime a user
  starts your competition, they will appear in its preamble.

  One can overwrite "global" rules with their own by creating `rules.vim` file
  in the directory with the problem. In stencil this is taken into account by
  appending `-r` or `--rules` option.

## Scoring

Currently, the score is calculated using the formula:

<img src="https://latex.codecogs.com/svg.latex?\frac{90}{1%20+%200.1\cdot%3C\text{number%20of%20keystrokes}%3E}%20%20+%20\frac{9}{1%20+%20\log(1+%3C\text{elapsed%20time}%3E)}%20+%201" />

## TODO list

- [x] Scoring system
- [ ] More detailed README
- [ ] bash/zsh completions
- [ ] Leaderboard
- [ ] Useful tips
