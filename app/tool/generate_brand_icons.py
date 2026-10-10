"""Generate Echo launcher and web icons from the canonical Voiceprint geometry."""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
PINE = "#17352C"
LICHEN = "#D8F277"
CLAY = "#FF7657"
VOICE_BARS = (
    (29, 54, 74),
    (43, 42, 86),
    (57, 30, 98),
    (71, 39, 89),
    (85, 48, 80),
    (99, 56, 72),
)


def _draw_mark(size: int, *, maskable: bool = False) -> Image.Image:
    supersampling = 8
    canvas_size = size * supersampling
    unit = canvas_size / 128
    image = Image.new(
        "RGBA",
        (canvas_size, canvas_size),
        PINE if maskable else (0, 0, 0, 0),
    )
    draw = ImageDraw.Draw(image)

    if not maskable:
        draw.rounded_rectangle(
            tuple(round(value * unit) for value in (6, 6, 122, 122)),
            radius=round(38 * unit),
            fill=PINE,
        )

    stroke = round(8 * unit)
    radius = stroke / 2
    for x, start, end in VOICE_BARS:
        scaled_x = x * unit
        scaled_start = start * unit
        scaled_end = end * unit
        draw.rectangle(
            (
                round(scaled_x - radius),
                round(scaled_start),
                round(scaled_x + radius),
                round(scaled_end),
            ),
            fill=LICHEN,
        )
        for y in (scaled_start, scaled_end):
            draw.ellipse(
                (
                    round(scaled_x - radius),
                    round(y - radius),
                    round(scaled_x + radius),
                    round(y + radius),
                ),
                fill=LICHEN,
            )

    point_x = 99 * unit
    point_y = 91 * unit
    point_radius = 8 * unit
    draw.ellipse(
        (
            round(point_x - point_radius),
            round(point_y - point_radius),
            round(point_x + point_radius),
            round(point_y + point_radius),
        ),
        fill=CLAY,
    )
    return image.resize((size, size), Image.Resampling.LANCZOS)


def _save(path: Path, size: int, *, maskable: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    _draw_mark(size, maskable=maskable).save(path, optimize=True)


def main() -> None:
    _save(ROOT / "web/favicon.png", 32)
    _save(ROOT / "web/icons/Icon-192.png", 192)
    _save(ROOT / "web/icons/Icon-512.png", 512)
    _save(ROOT / "web/icons/Icon-maskable-192.png", 192, maskable=True)
    _save(ROOT / "web/icons/Icon-maskable-512.png", 512, maskable=True)

    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for density, size in android_sizes.items():
        _save(
            ROOT
            / "android/app/src/main/res"
            / density
            / "ic_launcher.png",
            size,
        )


if __name__ == "__main__":
    main()
