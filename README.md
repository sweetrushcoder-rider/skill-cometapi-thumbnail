# CometAPI Thumbnail Generator

Generate YouTube/video thumbnails quickly using AI.

## Quick Start

```bash
bash scripts/thumbnail.sh "Your Video Title"
```

That's it! Generates a professional thumbnail in 5-15 seconds.

## Style Presets

| Style | Description | Best For |
|-------|-------------|----------|
| `tech` | Blue/purple gradients, circuit patterns | Tech tutorials, AI/ML |
| `tutorial` | Bright, educational, step-by-step feel | How-to videos, courses |
| `gaming` | Vibrant, neon, dynamic | Gaming content |
| `business` | Corporate, minimal, professional | Business tips |
| `creative` | Artistic, bold, abstract | Creative projects |
| `news` | Broadcast style, urgent | News, announcements |
| `review` | Product showcase, ratings | Product reviews |

## Usage Examples

```bash
# Tech thumbnail
bash scripts/thumbnail.sh -s tech "Build Your First AI App"

# Tutorial with custom details
bash scripts/thumbnail.sh -s tutorial -p "include Python logo" "Python Tutorial"

# Save to custom location
bash scripts/thumbnail.sh -s gaming -o ~/thumb.png "Best Games 2026"
```

## Features

- ✅ Optimized for speed (Gemini 3.1 Flash)
- ✅ 7 style presets
- ✅ YouTube-ready (16:9, 2K)
- ✅ Simple CLI
- ✅ Customizable prompts

## Requirements

- CometAPI key
- OpenClaw (optional, for integration)

## Related Skills

- [skill-cometapi-nanobana](https://github.com/sweetrushcoder-rider/skill-cometapi-nanobana) - Full image generation
- [skill-cometapi-flux2flex](https://github.com/sweetrushcoder-rider/skill-cometapi-flux2flex) - High-quality images

## License

MIT
