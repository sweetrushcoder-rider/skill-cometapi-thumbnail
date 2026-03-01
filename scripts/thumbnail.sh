#!/bin/bash
# Generate YouTube/video thumbnails using CometAPI's Gemini Flash model
# Optimized for fast, high-quality thumbnail generation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Default settings optimized for thumbnails
DEFAULT_MODEL="gemini-3.1-flash-image-preview"
DEFAULT_ASPECT="16:9"
DEFAULT_SIZE="2K"
DEFAULT_OUTPUT="$SKILL_DIR/output"

# Load CometAPI key from config
load_api_key() {
    local config_file="$HOME/.config/cometapi-config.json"
    
    if [ -f "$config_file" ]; then
        local key=$(jq -r '.nanobana.api_key // empty' "$config_file" 2>/dev/null)
        if [ -n "$key" ]; then
            echo "$key"
            return 0
        fi
    fi
    
    # Fallback to environment variable
    if [ -n "$COMETAPI_KEY" ]; then
        echo "$COMETAPI_KEY"
        return 0
    fi
    
    echo "Error: COMETAPI_KEY not found" >&2
    return 1
}

# Style presets for common thumbnail types
get_style_preset() {
    local style="$1"
    
    case "$style" in
        "tech")
            echo "modern tech aesthetic, clean design, blue and purple gradient, professional, glowing accents, circuit patterns"
            ;;
        "tutorial")
            echo "educational style, clear and readable, bright colors, step-by-step visual elements, friendly and approachable"
            ;;
        "gaming")
            echo "vibrant gaming aesthetic, bold colors, dynamic composition, neon accents, energetic and exciting"
            ;;
        "business")
            echo "professional corporate style, clean minimal design, blue and gray tones, executive feel, trustworthy"
            ;;
        "creative")
            echo "artistic and creative style, bold colors, abstract elements, eye-catching, unique and memorable"
            ;;
        "news")
            echo "news broadcast style, professional, bold headlines, red and blue accents, urgent and important"
            ;;
        "review")
            echo "review style, product showcase, rating stars or scores, comparison elements, honest and clear"
            ;;
        *)
            echo "professional, eye-catching, high contrast, YouTube optimized"
            ;;
    esac
}

# Generate thumbnail
generate_thumbnail() {
    local title="$1"
    local style="$2"
    local output="$3"
    local custom_prompt="$4"
    
    local api_key=$(load_api_key)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Build prompt
    local style_desc=$(get_style_preset "$style")
    local base_prompt="YouTube video thumbnail for: '$title'. $style_desc"
    
    if [ -n "$custom_prompt" ]; then
        base_prompt="$base_prompt. $custom_prompt"
    fi
    
    # Ensure output directory exists
    mkdir -p "$(dirname "$output")"
    
    echo "🎨 Generating thumbnail..." >&2
    echo "  Title: $title" >&2
    echo "  Style: $style" >&2
    echo "  Output: $output" >&2
    
    # Generate using CometAPI
    cd "$SKILL_DIR"
    bash scripts/generate_image.sh \
        -m "$DEFAULT_MODEL" \
        -a "$DEFAULT_ASPECT" \
        -s "$DEFAULT_SIZE" \
        -o "$output" \
        "$base_prompt"
}

# Usage
usage() {
    cat << EOF
Usage: thumbnail.sh [OPTIONS] "Video Title"

Generate YouTube/video thumbnails using AI

Options:
  -s, --style STYLE      Thumbnail style preset:
                         tech, tutorial, gaming, business, creative, news, review
  -o, --output FILE      Output file path (default: output/thumbnail_TIMESTAMP.png)
  -p, --prompt TEXT      Additional prompt details
  -h, --help             Show this help

Examples:
  # Quick thumbnail with default style
  thumbnail.sh "How to Build a RAG System"

  # Tech style
  thumbnail.sh -s tech "Using Claude Projects for RAG"

  # Custom output location
  thumbnail.sh -s tutorial -o ~/my_thumb.png "Python Tutorial for Beginners"

  # With custom prompt additions
  thumbnail.sh -s gaming -p "include Minecraft elements" "Best Gaming Setup 2026"

Style Presets:
  tech      - Modern tech, blue/purple gradients, circuit patterns
  tutorial  - Educational, bright, friendly, step-by-step feel
  gaming    - Vibrant, neon, dynamic, exciting
  business  - Corporate, minimal, blue/gray, professional
  creative  - Artistic, bold, abstract, unique
  news      - Broadcast style, bold headlines, urgent
  review    - Product showcase, ratings, comparison elements
EOF
    exit 0
}

# Parse arguments
TITLE=""
STYLE="tech"
OUTPUT=""
CUSTOM_PROMPT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--style)
            STYLE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -p|--prompt)
            CUSTOM_PROMPT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [ -z "$TITLE" ]; then
                TITLE="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$TITLE" ]; then
    echo "Error: Video title required" >&2
    usage
fi

# Generate default output path if not specified
if [ -z "$OUTPUT" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    OUTPUT="$DEFAULT_OUTPUT/thumbnail_$TIMESTAMP.png"
fi

# Generate thumbnail
generate_thumbnail "$TITLE" "$STYLE" "$OUTPUT" "$CUSTOM_PROMPT"
