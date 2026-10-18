# Skip the Test

A tiny platformer that lives in a single HTML file. You're a kid stuck inside your own school notebook, and the only way out is to get through four subjects without failing.

Made for Hack Club Stardance.

**Play it:** [add your live link here]
**Hours spent:** [add your real number here]

## The idea

I wanted to make something that looks like it was doodled during a boring lesson, not a polished indie game. So the whole world is a notebook page:

- The background is graph paper with a red margin line.
- Walls are ink blocks.
- Spikes are red pen.
- Coins are highlighters.
- Enemies are red **4**s, as in bad grades. Jump on them to squash them.
- The exit is a green door.

## How to play

| Key | Action |
| --- | --- |
| Left / Right or A / D | Move |
| Up, W or Space | Jump (hold for higher) |
| R | Restart the level |

On a phone, on-screen buttons show up automatically.

Get to the door in each of the four levels. Grab the highlighters if you can, and avoid the spikes and the 4s (unless you land on top of them).

## Levels

1. **English:** learn to jump and collect.
2. **Maths:** spikes under the platforms, so a missed jump hurts.
3. **History:** walking 4s that turn around at walls and ledges.
4. **Oral exam:** everything at once, climbing to the exit.

At the end you get a final grade out of 10. It drops by 1 for every 2 fails (minimum 4), and a perfect run with every highlighter earns "+ honours". Your best record is saved in the browser.

## How it's built

Everything is in one file, `index.html`. No libraries, no engine, no images, no audio files.

- **Rendering:** a 320x192 `<canvas>` scaled up with `image-rendering: pixelated`. Every sprite is drawn with rectangles, circles and a few triangles.
- **Levels:** arrays of strings (`#` wall, `^` spike, `c` coin, `e` enemy, `P` start, `E` exit).
- **Physics:** axis-by-axis tile collision (X first, then Y), gravity, and a fixed 60 updates per second so it runs the same on any screen.
- **Jump feel:** coyote time (6 frames), jump buffering, and variable jump height.
- **Enemies:** walk back and forth and turn at walls and ledges. Stomp them from above, or touch them from the side and you fail.
- **Sound:** short WebAudio square-wave beeps.
- **Saving:** `localStorage` for the best record.

## Run it locally

No install needed.

1. Download `index.html`.
2. Open it in any modern browser.

## Devlogs

1. What is this? (the concept)
2. Making it feel good to jump
3. Levels, sound and polish

[add links to your devlogs here]

## AI use

I used Claude (Anthropic's AI assistant) to help build this game. [Edit this section to say exactly what you wrote yourself, what Claude helped with, and anything you changed or added.]

## What's next

- More levels
- Moving platforms
- A boss called "The Final Exam"

## License

[Pick one, for example MIT]
