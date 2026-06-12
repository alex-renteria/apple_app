#!/usr/bin/env python3
"""Render Family Hub app icon concepts to PNG for comparison."""
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
DARK = "#4A2C20"

# --- Concept 1: kangaroo mum + joey -----------------------------------
kangaroo = f"""
  <!-- tail -->
  <path d="M 580 740 Q 790 800 850 590" stroke="{CREAM}" stroke-width="95"
        fill="none" stroke-linecap="round"/>
  <!-- feet -->
  <ellipse cx="430" cy="858" rx="150" ry="46" fill="{CREAM}"/>
  <!-- neck bridging head and body -->
  <ellipse cx="430" cy="430" rx="95" ry="130" fill="{CREAM}" transform="rotate(28 430 430)"/>
  <!-- body -->
  <ellipse cx="490" cy="630" rx="215" ry="245" fill="{CREAM}"/>
  <!-- ears -->
  <ellipse cx="320" cy="190" rx="34" ry="80" fill="{CREAM}" transform="rotate(-18 320 190)"/>
  <ellipse cx="420" cy="180" rx="34" ry="80" fill="{CREAM}" transform="rotate(14 420 180)"/>
  <!-- head -->
  <circle cx="370" cy="300" r="98" fill="{CREAM}"/>
  <!-- snout -->
  <ellipse cx="290" cy="335" rx="75" ry="52" fill="{CREAM}"/>
  <!-- eye + nose -->
  <circle cx="338" cy="290" r="14" fill="{DARK}"/>
  <circle cx="232" cy="328" r="13" fill="{DARK}"/>
  <!-- pouch -->
  <path d="M 355 660 Q 490 590 625 660 L 625 705 Q 490 800 355 705 Z" fill="#F3CFA4"/>
  <!-- joey -->
  <ellipse cx="455" cy="640" rx="26" ry="52" fill="{CREAM}" transform="rotate(-16 455 640)"/>
  <ellipse cx="535" cy="636" rx="26" ry="52" fill="{CREAM}" transform="rotate(14 535 636)"/>
  <circle cx="494" cy="668" r="62" fill="{CREAM}"/>
  <circle cx="472" cy="662" r="10" fill="{DARK}"/>
  <circle cx="516" cy="662" r="10" fill="{DARK}"/>
  <circle cx="494" cy="690" r="8" fill="{DARK}"/>
"""

# --- Concept 2: sun-hub ------------------------------------------------
rays = "".join(
    f'<rect x="477" y="130" width="70" height="180" rx="35" fill="#FFD66B" '
    f'transform="rotate({k * 45} 512 512)"/>'
    for k in range(8)
)
heart = ('M0,30 C-32,2 -37,-20 -17,-28 C-4,-33 0,-21 0,-15 '
         'C0,-21 4,-33 17,-28 C37,-20 32,2 0,30 Z')
sunhub = f"""
  {rays}
  <circle cx="512" cy="512" r="195" fill="#FFD66B"/>
  <circle cx="512" cy="512" r="128" fill="{CREAM}"/>
  <path d="{heart}" fill="#FF5E62" transform="translate(512 506) scale(3.4)"/>
"""

# --- Concept 3: house + heart ------------------------------------------
house = f"""
  <path d="M 512 240 L 800 478 L 224 478 Z" fill="{CREAM}" stroke="{CREAM}"
        stroke-width="70" stroke-linejoin="round"/>
  <rect x="276" y="470" width="472" height="328" rx="44" fill="{CREAM}"/>
  <path d="{heart}" fill="#FF5E62" transform="translate(512 600) scale(4.2)"/>
"""

concepts = {
    "icon-1-kangaroo": ("#FFA751", "#FF5E62", kangaroo),
    "icon-2-sunhub": ("#2BB3A3", "#0E7C86", sunhub),
    "icon-3-house": ("#6FB98F", "#2E8B6E", house),
}

for name, (c1, c2, art) in concepts.items():
    svg = CANVAS.format(c1=c1, c2=c2, art=art)
    cairosvg.svg2png(bytestring=svg.encode(), write_to=f"branding/{name}.png",
                     output_width=1024, output_height=1024)
    print(f"rendered branding/{name}.png")
