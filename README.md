# Image to ASCII

A convolutional neural network that turns images into ASCII art.

Instead of the usual approach — averaging each cell's brightness and indexing into a character ramp — this project uses a small CNN that looks at an **8×16 grayscale patch** and predicts which character best matches its *shape and texture*. That preserves detail in complex subjects (faces, animals) that brightness-averaging tends to flatten.



## Requirements

- Python 3.12+
- `onnxruntime`, `pillow`, `numpy`

```bash
pip install onnxruntime pillow numpy
```

The pre-trained weights are already committed in `ascii_cam_model/`, so you don't need to train anything to get started.

## Usage

**Easiest — drag and drop.** Drag any image file onto `convert.bat`. It prints the ASCII art, saves a PNG to `samples/`, and opens it in your image viewer.

```
C:\Users\You\Desktop\image to ASCII\GhostChar\convert.bat
```

**Or from the terminal:**

```bash
python model-training/single_test.py path/to/photo.jpg
```

That prints ASCII to the console. To get a viewable PNG instead:

```bash
python model-training/render_ascii.py path/to/photo.jpg --cols 170 --theme "Classic B&W"
```

Output lands in `samples/<name>-ascii.png` and opens automatically.

### `render_ascii.py` options

```
  image_path          Path to the input image.
  -c, --cols          Output width in characters (default: 150)
  -o, --output        Output PNG path (default: samples/<name>-ascii.png)
  --theme             Classic B&W | Matrix Green | Amber Terminal | Cyberpunk Pink | Ice Blue
  -i, --invert        Reverse the character density ramp
  --font-size         Pixel size per character (default: 12)
```

### Themes

| Name | Background | Text |
|---|---|---|
| `Classic B&W` | black | white |
| `Matrix Green` | near-black | bright green |
| `Amber Terminal` | near-black | amber |
| `Cyberpunk Pink` | dark purple | hot pink |
| `Ice Blue` | dark navy | cyan |

### `single_test.py` options

```
Options:
  image_path          Path to the input image file.
  -c, --cols          Output width in characters (default: 100)
  -m, --model         Path to .onnx or .keras weights (auto-detected if omitted)
  -cfg, --config      Path to config.json (default: model-training/config.json)
  -i, --invert        Reverse the character density ramp (for light-background terminals)
  -o, --output        Save the ASCII art to a text file instead of printing it
```

Examples:

```bash
# Wide, high-detail output, saved to a file
python model-training/single_test.py portrait.jpg --cols 160 -o portrait.txt

# Light background image
python model-training/single_test.py logo.png -i
```

Higher `--cols` means more character cells, so more inference time — roughly 0.4–1.0 s for a 12 MP photo at `--cols 170` on CPU.

## The character ramp

`config.json` defines the 20 characters the model predicts between, ordered dark → light. The model's class indices map directly onto this list, so **changing the order or length here requires retraining** — the network's output layer has one unit per character.

```json
"ASCII_CHARS": [" ", ".", ",", "-", "~", ":", "i", "r", "s", "t", "l", "C", "O", "Z", "w", "m", "#", "8", "%", "@"]
```

## How an image is processed

1. Convert to grayscale (`L`)
2. Compute row count from the image's aspect ratio and the 8×16 cell size
3. Resize the whole image to `cols × 8` by `rows × 16` with LANCZOS resampling — this makes each character cell land on exactly one patch
4. Slice into `(rows × cols, 16, 8, 1)` float patches
5. Run ONNX Runtime, take `argmax` over the 20 classes per patch
6. Index into the ramp and join into rows of text

## Model

- **Input:** `(16, 8, 1)` — a single grayscale character cell
- **Architecture:** `Conv2D(16) → BatchNorm → MaxPool(2,1) → Conv2D(32) → BatchNorm → MaxPool(2,2) → Flatten → Dropout(0.3) → Dense(20, softmax)`
- **Size:** ~63 KB (`model.onnx`), ~35 KB quantized (`model_quant.onnx`)

The first max-pool is `(2, 1)` — height before width — because the input patch is tall and narrow.

Weights are also published on [HuggingFace](https://huggingface.co/Papaya-Voldemort/image-to-ascii).

## Retraining

Only needed if you change the character set or want to improve accuracy. Requires `keras` and `torch` on top of the base deps:

```bash
pip install keras torch opencv-python onnx
```

Three stages, run in order:

```bash
# 1. Synthetic character patches with augmentation (rotation, contrast, blur, noise)
python model-training/generate_data.py

# 2. Pre-train the CNN on those synthetic patches
python model-training/train_model.py

# 3. Fine-tune on real photos
python model-training/fine_tune.py images/ --epochs 8 --max-per-char 5
```

Or run the whole thing including the COCO dataset download:

```bash
python model-training/main.py
```

Stage 3 is the interesting one. It runs **`jp2a`** (a real ASCII converter) over each real photo to produce ground-truth ASCII text, then labels the matching 8×16 pixel patches with whichever character `jp2a` chose. That supervises the CNN using another algorithm's output. It needs COCO images in an `images/` folder — `main.py` fetches ~1200 of them (1000 people, 200 objects).

To regenerate the quantized weights after retraining:

```bash
python model-training/optimize_model.py
```

### `jp2a` dependency

`fine_tune.py` shells out to the `jp2a` binary. It's not in the standard Windows Python ecosystem — on macOS use `brew install jp2a`, and on Windows your realistic options are WSL or building it from source (it needs GLib and a C toolchain). It's only needed for retraining, not for converting images.

## Project structure

```
.
├── ascii_cam_model/          Pre-trained weights (.keras, .onnx, quantized .onnx)
├── convert.bat               Drag-and-drop: drop an image on it to convert
├── samples/                  Output PNGs land here
├── model-training/
│   ├── single_test.py        Image -> ASCII converter (prints to terminal)
│   ├── render_ascii.py       Image -> ASCII converter (saves a viewable PNG)
│   ├── make_sample.py        Generates a test image, so you can try it without a photo
│   ├── main.py               Full pipeline: download data + all 3 training stages
│   ├── generate_data.py      Synthetic character patch generation
│   ├── train_model.py        Base CNN pre-training + ONNX export
│   ├── fine_tune.py          jp2a-supervised fine-tuning on real photos
│   ├── optimize_model.py     Keras -> ONNX -> INT8 quantization
│   ├── push_to_hub.py        Upload weights to HuggingFace Hub
│   └── config.json           Character ramp
├── config.json               Character ramp (same content, repo root)
├── pyproject.toml            Dependency manifest
└── LICENSE                   MIT
```

`convert.bat`, `render_ascii.py`, `make_sample.py` and `samples/` are additions, not part of the original project.

