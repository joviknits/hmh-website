# Image Standards & Organization

This document outlines the image organization, aspect ratios, sizes, and formats used for Hook Mountain Handmade.

## Core Standards
- **Aspect Ratio:** **3:4 (Portrait)** is the standard for most product and category images (calculated as `width / 0.75`).
- **Formats:** Every optimized image is provided in two formats:
  - **WebP** (Quality: 80)
  - **JPEG** (Quality: 82)
- **Naming Convention:** `[clean-name]-[width]w.[ext]` (e.g., `agrihan-320w.webp`).

## Organization & Sizes

| Category | Directory | Responsive Widths | Usage |
| :--- | :--- | :--- | :--- |
| **Patterns** | `images-optimized/patterns/` | `320w`, `640w` | Knitting pattern cards and lists. |
| **Categories** | `images-optimized/categories/` | `400w`, `800w` | Category navigation and landing pages. |
| **Featured** | `images-optimized/featured/` | `350w`, `700w` | Homepage callouts and featured content. |
| **Logo** | `images-optimized/logo/` | `60w`, `120w`, `240w`, `300w` | Site branding (PNG only). |
| **Favicons** | `images-optimized/logo/` | `16`, `32`, `180` | Browser and touch icons (PNG only). |

## Optimization Workflow
- **Script:** `scripts/optimize-images.sh`
- **Input:** `images/` (Original high-res assets)
- **Output:** `images-optimized/` (Automatically populated by script)

## Special Cases
- **Logos:** Kept as **PNG** to preserve transparency.
- **Favicons:** Standard square sizes (16x16, 32x32, 180x180).
- **Featured Portraits:** May vary (e.g., `about-portrait` is 1:1 square).
