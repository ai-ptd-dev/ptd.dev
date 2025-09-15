#!/bin/bash

# Create a simple PTD text logo programmatically using ImageMagick
mkdir -p public/images/icons

# Function to create logo at specific size
create_logo() {
  local size=$1
  local output=$2
  
  convert -size ${size}x${size} xc:'#0a0e27' \
    -gravity center \
    -font "DejaVu-Sans-Bold" \
    -pointsize $((size/3)) \
    -fill 'gradient:#00bcd4-#00e5ff' \
    -annotate +0+0 'PTD' \
    -blur 0x1 \
    -fill '#00bcd4' \
    -annotate +0+0 'PTD' \
    "$output"
}

# Create different sizes
create_logo 16 public/images/icons/favicon-16x16.png
create_logo 32 public/images/icons/favicon-32x32.png
create_logo 48 public/images/icons/favicon-48x48.png
create_logo 64 public/images/icons/favicon-64x64.png
create_logo 96 public/images/icons/favicon-96x96.png
create_logo 128 public/images/icons/icon-128x128.png
create_logo 144 public/images/icons/icon-144x144.png
create_logo 152 public/images/icons/icon-152x152.png
create_logo 180 public/images/icons/apple-touch-icon.png
create_logo 192 public/images/icons/icon-192x192.png
create_logo 192 public/images/icons/android-chrome-192x192.png
create_logo 384 public/images/icons/icon-384x384.png
create_logo 512 public/images/icons/icon-512x512.png
create_logo 512 public/images/icons/android-chrome-512x512.png
create_logo 144 public/images/icons/mstile-144x144.png

# Create a high-quality OG image with better styling
convert -size 1200x630 xc:'#0a0e27' \
  -gravity center \
  -font "DejaVu-Sans-Bold" \
  -pointsize 200 \
  -fill 'gradient:#00bcd4-#00e5ff' \
  -annotate +0-50 'PTD' \
  -blur 0x2 \
  -fill '#00bcd4' \
  -annotate +0-50 'PTD' \
  -font "DejaVu-Sans" \
  -pointsize 36 \
  -fill '#9ca3af' \
  -annotate +0+100 'Polyglot Transpilation Development' \
  -pointsize 24 \
  -annotate +0+150 'Write Expressive • Deploy Native' \
  public/images/icons/og-image.png

# Create multi-resolution favicon
convert public/images/icons/favicon-16x16.png \
        public/images/icons/favicon-32x32.png \
        public/images/icons/favicon-48x48.png \
        public/favicon.ico

echo "PTD logos created successfully!"
ls -la public/images/icons/
