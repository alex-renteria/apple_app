#!/usr/bin/env python3
"""Refine the pouch close-up: curved pocket, longer roo ears."""
import cairosvg

CREAM = "#FFF6EC"
TAN = "#F3CFA4"
RIM = "#E8B987"
DARK = "#4A2C20"
BLUSH = "#FFB5A0"

art = f"""
  <!-- roo ears: longer, leaf-shaped, tilted out -->
  <ellipse cx="385" cy="265" rx="52" ry="125" fill="{CREAM}" transform="rotate(-24 385 265)"/>
  <ellipse cx="639" cy="265" rx="52" ry="125" fill="{CREAM}" transform="rotate(24 639 265)"/>
  <ellipse cx="392" cy="280" rx="27" ry="78" fill="{BLUSH}" transform="rotate(-24 392 280)"/>
  <ellipse cx="632" cy="280" rx="27" ry="78" fill="{BLUSH}" transform="rotate(24 632 280)"/>
  <!-- joey head -->
  <circle cx="512" cy="475" r="185" fill="{CREAM}"/>
  <!-- closed happy eyes -->
  <path d="M 412 465 Q 441 492 470 465" stroke="{DARK}" stroke-width="16"
        fill="none" stroke-linecap="round"/>
  <path d="M 554 465 Q 583 492 612 465" stroke="{DARK}" stroke-width="16"
        fill="none" stroke-linecap="round"/>
  <!-- nose + smile -->
  <ellipse cx="512" cy="528" rx="23" ry="17" fill="{DARK}"/>
  <path d="M 512 545 Q 512 574 481 579 M 512 545 Q 512 574 543 579"
        stroke="{DARK}" stroke-width="12" fill="none" stroke-linecap="round"/>
  <circle cx="392" cy="532" r="25" fill="{BLUSH}"/>
  <circle cx="632" cy="532" r="25" fill="{BLUSH}"/>
  <!-- pouch: rounded pocket with a smiling rim -->
  <path d="M 190 640
           Q 512 575 834 640
           Q 850 870 512 905
           Q 174 870 190 640 Z" fill="{TAN}"/>
  <path d="M 190 640 Q 512 575 834 640 Q 834 690 512 725 Q 190 690 190 640 Z"
        fill="{RIM}"/>
  <!-- paws on the rim -->
  <ellipse cx="408" cy="652" rx="46" ry="32" fill="{CREAM}"/>
  <ellipse cx="616" cy="652" rx="46" ry="32" fill="{CREAM}"/>
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

cairosvg.svg2png(bytestring=svg.encode(), write_to="branding/pouch-a2-closeup.png",
                 output_width=1024, output_height=1024)
print("rendered branding/pouch-a2-closeup.png")
