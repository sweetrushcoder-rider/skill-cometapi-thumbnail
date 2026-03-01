#!/bin/bash
# CometAPI Nanobana Image Generator
# Generates images using Gemini 3 Pro Image Preview via CometAPI

# Load CometAPI configuration
CONFIG_LOADER="/home/esu/clawd/scripts/load-cometapi-config.sh"
if [[ -f "$CONFIG_LOADER" ]]; then
    source "$CONFIG_LOADER" "nanobana" 2>/dev/null || true
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/../output}"
mkdir -p "$OUTPUT_DIR"

# Default values
ASPECT_RATIO="1:1"
IMAGE_SIZE="4K"
MODEL="${COMETAPI_MODEL:-gemini-3-pro-image-preview}"

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS] "prompt text"

Generate images using CometAPI's Gemini models.

Options:
    -o, --output FILE       Output file path (default: output/image_TIMESTAMP.png)
    -a, --aspect RATIO      Aspect ratio: 1:1, 16:9, 9:16, 4:3, 3:4 (default: 1:1)
    -s, --size SIZE         Image size: 1K, 2K, 4K (default: 4K)
    -m, --model MODEL       Model: gemini-3-pro-image-preview, gemini-3.1-flash-image-preview (default: gemini-3-pro-image-preview)
    -k, --key KEY           CometAPI key (or use COMETAPI_KEY env var)
    -h, --help              Show this help message

Models:
    gemini-3-pro-image-preview        - Higher quality, slower
    gemini-3.1-flash-image-preview    - Faster generation

Examples:
    $0 "A beautiful sunset over the ocean"
    $0 -a 16:9 -s 2K "Futuristic city at night"
    $0 -m gemini-3.1-flash-image-preview "Fast generation test"
    $0 -o ~/my_image.png "Abstract art with vibrant colors"

Get your API key from: https://api.cometapi.com/console/token
EOF
    exit 1
}

# Parse arguments
PROMPT=""
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -a|--aspect)
            ASPECT_RATIO="$2"
            shift 2
            ;;
        -s|--size)
            IMAGE_SIZE="$2"
            shift 2
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -k|--key)
            COMETAPI_KEY="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            PROMPT="$1"
            shift
            ;;
    esac
done

# Validate
if [ -z "$PROMPT" ]; then
    echo "Error: No prompt provided"
    usage
fi

if [ -z "$COMETAPI_KEY" ]; then
    echo "Error: COMETAPI_KEY not set"
    echo "Set it with: export COMETAPI_KEY='your-key-here'"
    echo "Or use: $0 --key YOUR_KEY \"prompt\""
    echo "Get your key from: https://api.cometapi.com/console/token"
    exit 1
fi

# Set output file if not specified
if [ -z "$OUTPUT_FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    OUTPUT_FILE="$OUTPUT_DIR/image_${TIMESTAMP}.png"
fi

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "Generating image with CometAPI..."
echo "  Model: $MODEL"
echo "  Prompt: $PROMPT"
echo "  Aspect: $ASPECT_RATIO"
echo "  Size: $IMAGE_SIZE"
echo "  Output: $OUTPUT_FILE"
echo ""

# Make API request
RESPONSE=$(curl -s -X POST \
    "https://api.cometapi.com/v1beta/models/${MODEL}:generateContent" \
    -H "x-goog-api-key: $COMETAPI_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"contents\": [{\"parts\": [{\"text\": \"$PROMPT\"}]}],
        \"generationConfig\": {
            \"responseModalities\": [\"TEXT\", \"IMAGE\"],
            \"imageConfig\": {
                \"aspectRatio\": \"$ASPECT_RATIO\",
                \"imageSize\": \"$IMAGE_SIZE\"
            }
        }
    }")

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    echo "Error from API:"
    echo "$RESPONSE" | jq '.error'
    exit 1
fi

# Extract and decode image
echo "$RESPONSE" | jq -r '.candidates[0].content.parts[] | select(.inlineData) | .inlineData.data' | head -1 | base64 --decode > "$OUTPUT_FILE"

# Check if file was created
if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo ""
    echo "✓ Success! Image saved to: $OUTPUT_FILE"
    echo "  File size: $FILE_SIZE"
    echo "$OUTPUT_FILE"
else
    echo "Error: Failed to save image"
    echo "API Response:"
    echo "$RESPONSE" | jq '.'
    exit 1
fi
