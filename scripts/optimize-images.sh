#!/bin/bash

# Image Optimization Script for Hook Mountain Handmade
# Uses ImageMagick to process images to 3:4 aspect ratio, multiple sizes, WebP + JPEG

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INPUT_DIR="$PROJECT_DIR/images"
OUTPUT_DIR="$PROJECT_DIR/images-optimized"

# Quality settings
WEBP_QUALITY=80
JPEG_QUALITY=82

# Target aspect ratio (3:4 = 0.75)
TARGET_RATIO=0.75

# Function to get a clean filename from path
clean_name() {
    local filename=$(basename "$1")
    # Remove extension
    filename="${filename%.*}"
    # Replace special chars with hyphens, lowercase
    echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Function to get average edge color (samples from edges of image)
get_edge_color() {
    local input="$1"
    # Sample from top and bottom 20 pixels, get average color
    magick "$input" \( +clone -gravity North -crop x20+0+0 +repage \) \
                    \( +clone -gravity South -crop x20+0+0 +repage \) \
                    -gravity Center -crop x20+0+0 +repage \
                    -append -scale 1x1! -format '%[hex:p{0,0}]' info: 2>/dev/null || echo "FFFFFF"
}

# Function to process a single image
process_image() {
    local input="$1"
    local output_dir="$2"
    local sizes="$3"  # Comma-separated: "320,640"
    local name="$4"   # Optional custom name

    if [ ! -f "$input" ]; then
        echo "  [SKIP] File not found: $input"
        return
    fi

    # Get clean name if not provided
    if [ -z "$name" ]; then
        name=$(clean_name "$input")
    fi

    # Get image dimensions
    local dims=$(magick identify -format '%wx%h' "$input" 2>/dev/null)
    local width=$(echo "$dims" | cut -d'x' -f1)
    local height=$(echo "$dims" | cut -d'x' -f2)

    if [ -z "$width" ] || [ -z "$height" ]; then
        echo "  [ERROR] Could not read dimensions: $input"
        return
    fi

    local current_ratio=$(echo "scale=3; $width / $height" | bc)

    # Check if image is roughly square (ratio > 0.85)
    local is_square=$(echo "$current_ratio > 0.85" | bc)

    local temp_file=""
    local source_file="$input"

    if [ "$is_square" -eq 1 ]; then
        echo "  [EXTEND] Square image detected ($width x $height, ratio=$current_ratio)"

        # Get edge color for background
        local edge_color=$(get_edge_color "$input")
        echo "    Edge color: #$edge_color"

        # Calculate new height for 3:4 ratio
        local new_height=$(echo "scale=0; $width / $TARGET_RATIO" | bc)

        # Create temp file with extended canvas
        temp_file=$(mktemp /tmp/claude/img_XXXXXX.png)
        magick "$input" -background "#$edge_color" -gravity center \
               -extent "${width}x${new_height}" "$temp_file"
        source_file="$temp_file"
        echo "    Extended to: $width x $new_height"
    fi

    # Process each size
    IFS=',' read -ra SIZE_ARRAY <<< "$sizes"
    for target_width in "${SIZE_ARRAY[@]}"; do
        local target_height=$(echo "scale=0; $target_width / $TARGET_RATIO" | bc)

        # WebP output
        local webp_out="$output_dir/${name}-${target_width}w.webp"
        magick "$source_file" -resize "${target_width}x${target_height}^" \
               -gravity center -extent "${target_width}x${target_height}" \
               -quality $WEBP_QUALITY "$webp_out"

        # JPEG output
        local jpg_out="$output_dir/${name}-${target_width}w.jpg"
        magick "$source_file" -resize "${target_width}x${target_height}^" \
               -gravity center -extent "${target_width}x${target_height}" \
               -quality $JPEG_QUALITY "$jpg_out"

        echo "    Created: ${name}-${target_width}w.webp/.jpg"
    done

    # Cleanup temp file
    if [ -n "$temp_file" ] && [ -f "$temp_file" ]; then
        rm "$temp_file"
    fi
}

# Function to process logo (keep as PNG)
process_logo() {
    local input="$1"
    local output_dir="$2"
    local sizes="$3"
    local name="$4"

    if [ ! -f "$input" ]; then
        echo "  [SKIP] Logo not found: $input"
        return
    fi

    IFS=',' read -ra SIZE_ARRAY <<< "$sizes"
    for target_width in "${SIZE_ARRAY[@]}"; do
        local out="$output_dir/${name}-${target_width}w.png"
        magick "$input" -resize "${target_width}x" -quality 90 "$out"
        echo "    Created: ${name}-${target_width}w.png"
    done
}

# Function to process favicon
process_favicon() {
    local input="$1"
    local output_dir="$2"

    if [ ! -f "$input" ]; then
        echo "  [SKIP] Favicon not found: $input"
        return
    fi

    # Standard favicon sizes
    for size in 16 32 180; do
        local out="$output_dir/favicon-${size}.png"
        magick "$input" -resize "${size}x${size}" "$out"
        echo "    Created: favicon-${size}.png"
    done
}

echo "========================================"
echo "Hook Mountain Handmade Image Optimizer"
echo "========================================"
echo ""
echo "Input:  $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo ""

# Ensure temp directory exists
mkdir -p /tmp/claude

# ========================================
# PATTERN IMAGES (320w, 640w)
# ========================================
echo "Processing PATTERN images..."

# Sweater patterns
SWEATER_PATTERNS=(
    "2024_05_upload_medium-1-1-edited.jpeg:briary"
    "2024_05_pxl_20240327_160102273.mp3-edited.jpg:planted-cardigan"
    "2024_05_upload_medium-8-edited.jpeg:thimble-sweater"
    "2024_05_pxl_20231117_2104414932-1-edited.jpg:ring-of-fortune"
    "2024_05_pxl_20231001_200632629.mp2_-edited.jpg:arachne-pullover"
    "2024_05_pxl_20230820_2043000572-edited.jpg:teapot-cardigan"
    "2023_04_pxl_20230107_164347145_3.jpg:layer-cake"
    "2024_05_pxl_20230112_193806689-edited.jpg:bakehouse-cardigan"
    "2024_03_pxl_20230305_212032005.mp_.jpg:beatrix-sweater"
    "2023_03_pxl_20230112_190332442.mp_.jpg:very-snug"
    "2024_05_44cf986b-9748-4997-88f8-37118b738099_medium2.jpeg:brooks-river"
    "2024_05_file0_medium2.jpeg:lisbon-cardigan"
    "2024_05_pxl_20220108_142053195.mp__1__medium.webp:squash-blossom"
    "2024_05_upload_medium-4-edited.jpeg:unlocked-pullover"
    "2024_05_pxl_20230408_191939412_2-edited.jpg:challah-sweater"
    "2024_05_upload_medium2.jpeg:bun-break"
    "2024_05_pxl_20210908_190552008-1-edited.jpg:bookshop-cardigan"
    "2024_05_pxl_20210908_191202519.mp_-edited.jpg:string-or-nothing"
    "2022_04_pxl_20210602_154543739.jpg:night-market"
    "2024_05_pxl_20210908_192001701_medium.webp:space-clouds"
    "2024_05_6bfed330-f9d7-4cb8-a5d8-7a533e663d75_medium2-edited.webp:brunch"
    "2024_05_pxl_20240410_1731321362-1-1.jpg:unplugged"
    "2024_05_pxl_20210908_192534681.mp_medium2.jpg:pillars-of-uruk"
    "2024_05_pxl_20230112_185443219-1-edited.jpg:reality-bytes"
    "2024_05_upload_medium-4-2.jpeg:yaara"
    "2024_05_ef5c5cda-d449-49ba-aa49-a9cc8e5bfeb8_medium2-edited.jpeg:tide-pools"
    "2024_05_20200704_141911_medium2-edited.jpg:uprising"
    "2024_05_cc2dc837-6648-4031-9843-a011d8208493_medium2-edited.jpeg:winter-garden"
)

# Summer patterns
SUMMER_PATTERNS=(
    "2024_05_upload_medium2-4-edited.jpeg:agrihan"
    "2024_05_upload_medium2-4-1-edited.jpeg:pollinator-tank"
    "2024_05_upload_medium2-3-1-edited.jpeg:daily-gelato"
    "2024_05_pxl_20230421_020425279.portrait_medium2-edited.jpg:mustard-flower-tee"
    "2024_05_upload_medium2-1-2.jpeg:auri-tee"
    "2024_05_upload_medium2-2-1.jpeg:berry-jam"
)

# Accessory patterns - Hats
HAT_PATTERNS=(
    "2024_05_img_20191202_140350434_medium.webp:sustain-comfort"
    "2024_05_upload_medium-14.jpeg:way-to-my-heart-hat"
    "2024_05_upload_medium-10-1-edited.jpeg:shire-hat"
    "2024_05_image-1.jpeg:strawberry-toast-hat"
    "2024_05_upload_medium-13-1-edited.jpeg:ski-lift-hat"
    "2024_05_img_20191013_101159791_medium-edited-1.webp:star-child"
    "2024_05_upload_medium-12-1-edited-1.jpeg:thistleburr-hat"
    "2024_05_upload_medium-1-3-edited.jpeg:haycorns"
    "2024_05_upload_medium-11-edited-1.jpeg:study-in-cats-1"
    "2024_05_upload_medium-12-edited-1.jpeg:study-in-cats-2"
    "2024_05_upload_medium-5-3-edited.jpeg:shave-ice"
    "2024_05_upload_medium-3-3.jpeg:misty-mountains"
    "2024_05_upload_medium-3-4-edited.jpeg:manzanita-avenue"
    "2024_05_upload_medium2-3-edited.jpeg:finial-hat"
    "2024_05_img_20211204_111401_medium-edited.jpg:forest-trees-hat"
    "2024_05_img_20210214_160311_medium-1.webp:fuck-cancer"
)

# Accessory patterns - Gloves
GLOVE_PATTERNS=(
    "2024_05_upload_medium-17-edited.jpeg:thistleburr-mitts"
    "2024_05_upload_medium-7-1-edited.jpeg:sock-hands"
    "2024_05_upload_medium-2-4-edited-2.jpeg:just-sleeves"
    "2024_05_upload_medium-9-1-edited.jpeg:strawberry-toast-mitts"
    "2024_05_pxl_20211127_194340947_medium-edited-2.webp:forest-trees-gloves"
)

# Accessory patterns - Scarves
SCARF_PATTERNS=(
    "2024_05_upload_medium-19-edited.jpeg:sea-glass-shawl"
    "2024_05_upload_medium2-1-1.jpeg:orchard-vine"
    "2024_05_upload_medium-15-1.jpeg:way-to-my-heart-cowl"
)

# Process all pattern images
for entry in "${SWEATER_PATTERNS[@]}" "${SUMMER_PATTERNS[@]}" "${HAT_PATTERNS[@]}" "${GLOVE_PATTERNS[@]}" "${SCARF_PATTERNS[@]}"; do
    file=$(echo "$entry" | cut -d':' -f1)
    name=$(echo "$entry" | cut -d':' -f2)
    echo "  Processing: $name"
    process_image "$INPUT_DIR/$file" "$OUTPUT_DIR/patterns" "320,640" "$name"
done

# ========================================
# CATEGORY IMAGES (400w, 800w)
# ========================================
echo ""
echo "Processing CATEGORY images..."

CATEGORY_IMAGES=(
    "2025_07_daisy-chain-1.jpg:summer-styles"
    "2024_04_pxl_20251201_2014547382.jpg:sweaters"
    "2024_04_pxl_20251030_1522367082.jpg:accessories"
    "2024_05_upload_medium-1.jpeg:sweaters-alt"
    "2024_03_pxl_20231114_181413205-1.jpg:accessories-alt"
    "2024_03_pxl_20230730_172040998_exported_1501_1690738882154.jpg:summer-styles-alt"
    "2024_05_upload_medium-20.jpeg:summer-browse"
)

for entry in "${CATEGORY_IMAGES[@]}"; do
    file=$(echo "$entry" | cut -d':' -f1)
    name=$(echo "$entry" | cut -d':' -f2)
    echo "  Processing: $name"
    process_image "$INPUT_DIR/$file" "$OUTPUT_DIR/categories" "400,800" "$name"
done

# ========================================
# FEATURED IMAGES (350w, 700w)
# ========================================
echo ""
echo "Processing FEATURED images..."

FEATURED_IMAGES=(
    "2025_11_pxl_20251111_1707159522.jpg:innkeeper-sweater"
    "2025_11_pxl_20250816_1857233132-1.jpg:arachne-featured"
    "2024_04_pxl_20240813_1533319452-1.jpg:test-knit-callout"
    "2024_10_pxl_20230820_2043067602.jpg:about-portrait"
)

for entry in "${FEATURED_IMAGES[@]}"; do
    file=$(echo "$entry" | cut -d':' -f1)
    name=$(echo "$entry" | cut -d':' -f2)
    echo "  Processing: $name"
    process_image "$INPUT_DIR/$file" "$OUTPUT_DIR/featured" "350,700" "$name"
done

# ========================================
# LOGO (120w, 240w, 300w - PNG)
# ========================================
echo ""
echo "Processing LOGO..."

process_logo "$INPUT_DIR/2025_11_jovi_logo-1.png" "$OUTPUT_DIR/logo" "120,240,300" "logo"

# ========================================
# FAVICON (16, 32, 180 - PNG)
# ========================================
echo ""
echo "Processing FAVICON..."

process_favicon "$INPUT_DIR/2022_03_d86e37ab-8b3b-2574-eb82-0f33ae1f23eb.png" "$OUTPUT_DIR/logo"

# Also process the small logo for inline use
echo ""
echo "Processing small inline logo..."
process_logo "$INPUT_DIR/2024_05_unnamed.png" "$OUTPUT_DIR/logo" "60,120" "logo-small"

echo ""
echo "========================================"
echo "Optimization complete!"
echo "========================================"

# Show output summary
echo ""
echo "Output summary:"
for dir in patterns categories featured logo; do
    count=$(ls -1 "$OUTPUT_DIR/$dir" 2>/dev/null | wc -l | tr -d ' ')
    echo "  $dir/: $count files"
done

# Show total size comparison
echo ""
echo "Size comparison:"
original_size=$(du -sh "$INPUT_DIR" 2>/dev/null | cut -f1)
optimized_size=$(du -sh "$OUTPUT_DIR" 2>/dev/null | cut -f1)
echo "  Original:  $original_size"
echo "  Optimized: $optimized_size"
