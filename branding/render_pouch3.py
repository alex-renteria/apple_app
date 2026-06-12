#!/usr/bin/env python3
"""Final pouch icon: clean pocket with stitching, rounder roo face."""
import cairosvg

CREAM = "#FFF6EC"
TAN = "#F0C795"
DARK = "#4A2C20"
BLUSH = "#FFB5A0"

art = f"""
  <!-- roo ears: wide base, leaning outward -->
  <ellipse cx="378" cy="280" rx="58" ry="118" fill="{CREAM}" transform="rotate(-30 378 280)"/>
  <ellipse cx="646" cy="280" rx="58" ry="118" fill="{CREAM}" transform="rotate(30 646 280)"/>
  <ellipse cx="386" cy="294" rx="30" ry="72" fill="{BLUSH}" transform="rotate(-30 386 294)"/>
  <ellipse cx="638" cy="294" rx="30" ry="72" fill="{BLUSH}" transform="rotate(30 638 294)"/>
  <!-- joey head: slightly tall oval, roo-ish -->
  <ellipse cx="512" cy="478" rx="178" ry="190" fill="{CREAM}"/>
  <!-- closed happy eyes -->
  <path d="M 415 462 Q 443 489 471 462" stroke="{DARK}" stroke-width="16"
        fill="none" stroke-linecap="round"/>
  <path d="M 553 462 Q 581 489 609 462" stroke="{DARK}" stroke-width="16"
        fill="none" stroke-linecap="round"/>
  <!-- roo nose: wider, oval -->
  <ellipse cx="512" cy="535" rx="30" ry="20" fill="{DARK}"/>
  <path d="M 512 553 Q 512 580 484 585 M 512 553 Q 512 580 540 585"
        stroke="{DARK}" stroke-width="12" fill="none" stroke-linecap="round"/>
  <circle cx="394" cy="535" r="24" fill="{BLUSH}"/>
  <circle cx="630" cy="535" r="24" fill="{BLUSH}"/>
  <!-- pouch: smooth pocket, single colour -->
  <path d="M 186 645
           Q 512 580 838 645
           Q 846 880 512 910
           Q 178 880 186 645 Z" fill="{TAN}"/>
  <!-- stitching along the rim -->
  <path d="M 240 668 Q 512 612 784 668" stroke="{CREAM}" stroke-width="14"
        fill="none" stroke-linecap="round" stroke-dasharray="2 46"/>
  <!-- paws on the rim -->
  <ellipse cx="412" cy="648" rx="46" ry="32" fill="{CREAM}"/>
  <ellipse cx="612" cy="648" rx="46" ry="32" fill="{CREAM}"/>
"""

svg = f"""<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#FFA751"/>
      <stop offset="1" stop-color="#FF5E62"/>
    </linearGradient>
    <clipPath id="rounded"><rect width="1024" height="1024" rx="230"/></clipPath>
  </defs>
  <g clip-path="url(#rounded)">
    <rect width="1024" height="1024" fill="url(#bg)"/>
    {art}
  </g>
</svg>"""

cairosvg.svg2png(bytestring=svg.encode(), write_to="branding/pouch-final.png",
                 output_width=1024, output_height=1024)
print("rendered branding/pouch-final.png")
