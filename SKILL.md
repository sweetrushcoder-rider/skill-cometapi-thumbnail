---
name: cometapi-thumbnail
description: Generate YouTube/video thumbnails using CometAPI's Gemini Flash model. Use when the user wants to create video thumbnails, YouTube thumbnails, or quick image assets for video content. Optimized for fast generation with style presets for different video types (tech, tutorial, gaming, business, creative, news, review).
---

# CometAPI Thumbnail Generator

Generate professional YouTube/video thumbnails quickly using AI.

## Quick Start

**Fastest way:**
```bash
bash scripts/thumbnail.sh "Your Video Title Here"
```

That's it! Generates a tech-style thumbnail in seconds.

## Usage

### Basic Usage
```bash
bash scripts/thumbnail.sh "Video Title"
```

### With Style Preset
```bash
bash scripts/thumbnail.sh -s tutorial "Python for Beginners"
```

### Custom Output Location
```bash
bash scripts/thumbnail.sh -o ~/Desktop/thumb.png "My Video"
```

### With Additional Prompt Details
```bash
bash scripts/thumbnail.sh -s gaming -p "include Minecraft elements" "Best Gaming Setup"
```

## Style Presets

| Style | Description | Best For |
|-------|-------------|----------|
| `tech` | Modern, blue/purple gradients, circuit patterns | Tech tutorials, AI/ML content |
| `tutorial` | Educational, bright, friendly, step-by-step feel | How-to videos, courses |
| `gaming` | Vibrant, neon, dynamic, exciting | Gaming content |
| `business` | Corporate, minimal, blue/gray, professional | Business tips, corporate videos |
| `creative` | Artistic, bold, abstract, unique | Creative projects, art videos |
| `news` | Broadcast style, bold headlines, urgent | News, updates, announcements |
| `review` | Product showcase, ratings, comparison | Product reviews, comparisons |

**Default:** `tech` (if no style specified)

## Options

| Option | Description |
|--------|-------------|
| `-s, --style STYLE` | Thumbnail style preset |
| `-o, --output FILE` | Output file path |
| `-p, --prompt TEXT` | Additional prompt details |
| `-h, --help` | Show help message |

## Examples

**Tech Tutorial:**
```bash
bash scripts/thumbnail.sh -s tech "Using Claude Projects to Build RAG"
```

**Gaming Video:**
```bash
bash scripts/thumbnail.sh -s gaming "Top 10 Games of 2026"
```

**Business Advice:**
```bash
bash scripts/thumbnail.sh -s business "5 Marketing Strategies That Work"
```

**Tutorial with Custom Prompt:**
```bash
bash scripts/thumbnail.sh -s tutorial -p "include Python logo and code snippets" "Python Web Scraping Tutorial"
```

**Save to specific location:**
```bash
bash scripts/thumbnail.sh -s review -o ~/videos/thumbnail.png "iPhone 18 Review"
```

## Output

- **Default location:** `skills/cometapi-thumbnail/output/thumbnail_TIMESTAMP.png`
- **Resolution:** 2K (2048px) at 16:9 aspect ratio
- **Format:** PNG
- **Model:** Gemini 3.1 Flash (fast generation)

## Workflow

1. User provides video title
2. Choose style preset (default: tech)
3. Optionally add custom prompt details
4. Script generates optimized thumbnail prompt
5. Returns PNG image at 16:9 ratio
6. **Automatically send image to user on current messaging channel (Telegram, Discord, etc.)**

## Integration with OpenClaw

When user asks to create a thumbnail:
1. Extract video title from request
2. Determine appropriate style
3. Run thumbnail script
4. **Send the generated image directly to the user on the current messaging channel:**
   - For **Telegram**: Use curl to send via Telegram Bot API:
     ```bash
     curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPhoto" \
       -F chat_id="${CHAT_ID}" \
       -F caption="🎨 Thumbnail: ${VIDEO_TITLE}" \
       -F photo="@${OUTPUT_PATH}"
     ```
   - Get TELEGRAM_BOT_TOKEN from `~/.openclaw/openclaw.json` (channels.telegram.botToken)
   - Get CHAT_ID from the current session context
5. Confirm success to the user with the thumbnail preview

## Tips for Better Thumbnails

**Good titles:**
- Clear and specific
- Include key topic
- Action-oriented when possible

**Custom prompt additions:**
- Specific colors: "use green and gold colors"
- Specific elements: "include Python logo"
- Mood: "dramatic lighting" or "bright and cheerful"
- Text elements: "leave space for text overlay"

**Examples:**
```bash
# With specific colors
bash scripts/thumbnail.sh -p "use dark theme with neon green accents" "VS Code Tips"

# With specific elements  
bash scripts/thumbnail.sh -p "include React logo prominently" "React Hooks Explained"

# With mood
bash scripts/thumbnail.sh -p "dramatic lighting, cinematic feel" "The Future of AI"
```

## API Configuration

Uses CometAPI with Gemini Flash model:
- **Endpoint:** `https://api.cometapi.com/v1beta/models/gemini-3.1-flash-image-preview:generateContent`
- **Auth:** Requires COMETAPI_KEY
- **Config:** `~/.config/cometapi-config.json`

## Related Skills

- `cometapi-nanobana` - Full image generation with more options
- `cometapi-flux2flex` - High-quality image generation
- `document-publisher` - Publish thumbnails to waterplace.sfll.ws

## Troubleshooting

**"COMETAPI_KEY not found"**
Set your API key:
```bash
export COMETAPI_KEY='your-key-here'
```

**Slow generation**
The Flash model is optimized for speed. Typical generation time: 5-15 seconds.

**Wrong aspect ratio**
Thumbnails are always 16:9 (YouTube standard). Use nanobana skill for other ratios.
