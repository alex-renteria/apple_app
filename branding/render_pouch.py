#!/usr/bin/env python3
"""Render 'Pouch' logo refinements: joey-in-pouch close-up vs full kangaroo."""
import cairosvg

CANVAS = """<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{c1}"/>
      <stop offset="1" stop-color="{c2}"/>
    </linearGradient>
    <clipPath id="rounded"><rect width="1024" height="1024" rx="230"/></clipPath>
  </defs>
  <g clip-path="url(#rounded)">
    <rect width="1024" height="1024" fill="url(#bg)"/>
    {art}
  </g>
</svg>"""

CREAM = "#FFF6EC"
TAN = "#F3CFA4"
DARK = "#4A2C20"
BLUSH = "#FFB5A0"

# --- Variant A: pouch close-up, joey peeking out -----------------------
pouch_closeup = f"""
  <!-- joey ears (rounded, inner blush) -->
  <ellipse cx="392" cy="300" rx="62" ry="110" fill="{CREAM}" transform="rotate(-20 392 300)"/>
  <ellipse cx="632" cy="300" rx="62" ry="110" fill="{CREAM}" transform="rotate(20 632 300)"/>
  <ellipse cx="398" cy="312" rx="34" ry="68" fill="{BLUSH}" transform="rotate(-20 398 312)"/>
  <ellipse cx="626" cy="312" rx="34" ry="68" fill="{BLUSH}" transform="rotate(20 626 312)"/>
  <!-- joey head -->
  <circle cx="512" cy="470" r="190" fill="{CREAM}"/>
  <!-- eyes: closed happy arcs -->
  <path d="M 408 460 Q 438 488 468 460" stroke="{DARK}" stroke-width="16"
        fill="none" stroke-linecap="round"/>
  <path d="M 556 460 Q 586 488 616 460" stroke="{DARK}" stroke-width="16"
        fill="none" stroke-linecap="round"/>
  <!-- nose + smile -->
  <ellipse cx="512" cy="525" rx="24" ry="18" fill="{DARK}"/>
  <path d="M 512 543 Q 512 575 478 580 M 512 543 Q 512 575 546 580"
        stroke="{DARK}" stroke-width="13" fill="none" stroke-linecap="round"/>
  <!-- cheeks -->
  <circle cx="386" cy="528" r="26" fill="{BLUSH}"/>
  <circle cx="638" cy="528" r="26" fill="{BLUSH}"/>
  <!-- pouch: hammock across the bottom, in front of the head -->
  <path d="M 130 620 Q 512 560 894 620 L 894 1024 L 130 1024 Z" fill="{TAN}"/>
  <path d="M 130 620 Q 512 560 894 620 Q 894 700 512 740 Q 130 700 130 620 Z"
        fill="#E8B987"/>
  <!-- joey paws resting on pouch rim -->
  <ellipse cx="400" cy="640" rx="48" ry="34" fill="{CREAM}"/>
  <ellipse cx="624" cy="640" rx="48" ry="34" fill="{CREAM}"/>
"""

# --- Variant B: polished full kangaroo ---------------------------------
kangaroo2 = f"""
  <path d="M 580 740 Q 790 800 850 590" stroke="{CREAM}" stroke-width="95"
        fill="none" stroke-linecap="round"/>
  <ellipse cx="430" cy="858" rx="150" ry="46" fill="{CREAM}"/>
  <ellipse cx="430" cy="430" rx="95" ry="130" fill="{CREAM}" transform="rotate(28 430 430)"/>
  <ellipse cx="490" cy="630" rx="215" ry="245" fill="{CREAM}"/>
  <!-- rounder ears with blush inner -->
  <ellipse cx="322" cy="205" rx="42" ry="72" fill="{CREAM}" transform="rotate(-20 322 205)"/>
  <ellipse cx="420" cy="196" rx="42" ry="72" fill="{CREAM}" transform="rotate(16 420 196)"/>
  <ellipse cx="326" cy="214" rx="22" ry="42" fill="{BLUSH}" transform="rotate(-20 326 214)"/>
  <ellipse cx="416" cy="206" rx="22" ry="42" fill="{BLUSH}" transform="rotate(16 416 206)"/>
  <circle cx="370" cy="300" r="98" fill="{CREAM}"/>
  <ellipse cx="290" cy="335" rx="75" ry="52" fill="{CREAM}"/>
  <path d="M 320 288 Q 340 306 360 288" stroke="{DARK}" stroke-width="13"
        fill="none" stroke-linecap="round"/>
  <ellipse cx="234" cy="326" rx="17" ry="14" fill="{DARK}"/>
  <!-- pouch -->
  <path d="M 350 655 Q 490 595 630 655 L 630 710 Q 490 800 350 710 Z" fill="{TAN}"/>
  <!-- joey: ears, head, happy face -->
  <ellipse cx="448" cy="580" rx="22" ry="46" fill="{CREAM}" transform="rotate(-18 448 580)"/>
  <ellipse cx="540" cy="576" rx="22" ry="46" fill="{CREAM}" transform="rotate(16 540 576)"/>
  <circle cx="494" cy="650" r="68" fill="{CREAM}"/>
  <path d="M 462 644 Q 476 658 490 644" stroke="{DARK}" stroke-width="10"
        fill="none" stroke-linecap="round"/>
  <path d="M 502 644 Q 516 658 530 644" stroke="{DARK}" stroke-width="10"
        fill="none" stroke-linecap="round"/>
  <ellipse cx="496" cy="678" rx="12" ry="9" fill="{DARK}"/>
"""

variants = {
    "pouch-a-closeup": ("#FFA751", "#FF5E62", pouch_closeup),
    "pouch-b-kangaroo": ("#FFA751", "#FF5E62", kangaroo2),
}

for name, (c1, c2, art) in variants.items():
    svg = CANVAS.format(c1=c1, c2=c2, art=art)
    cairosvg.svg2png(bytestring=svg.encode(), write_to=f"branding/{name}.png",
                     output_width=1024, output_height=1024)
    print(f"rendered branding/{name}.png")
