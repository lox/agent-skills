---
name: frontend-design
description: Creates distinctive, production-grade frontend interfaces with a strong visual point of view. Use when building web components, pages, applications, or prototypes that should feel memorable, polished, and non-generic.
---

# Frontend Design

Creates distinctive, production-grade frontend interfaces with a clear point of view. Builds real working code that feels designed, not statistically averaged.

## Design Thinking

Before coding, lock the concept:

- **Purpose**: What problem does this interface solve? Who uses it? What emotion, energy, or reaction should it create?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. Use it as a commitment, not a loose vibe.
- **Reference Check**: Name 2-3 specific inspirations before building. Include at least 1 non-obvious real-world or historical reference. Avoid defaulting to common tech examples unless the product already demands that language.
- **Reference Inputs**: If the user provides a Refero style page, `styles.refero.design` result, or `DESIGN.md`, extract the palette, typography, spacing rhythm, component density, and interaction cues. Turn those into design tokens and direction notes before coding.
- **Constraints**: Technical requirements, framework boundaries, performance limits, accessibility needs, and existing design-system constraints.
- **Signature Hook**: Define the one memorable move users will remember. It could be a sculptural type treatment, a reactive background, a custom cursor, an asymmetric hero, a storytelling hover state, or another clear signature element.

**CRITICAL**: Choose one clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work. The key is intentionality, not intensity. Simplicity should feel architectural, not empty.

Before full implementation, define a compact design system in your own working notes or response:

- A strict 5-7 colour palette with roles: primary, accent, neutrals, and one surprise colour
- One characterful display font paired with one highly legible body font
- Core tokens for spacing, radius, shadow, and motion using CSS variables or Tailwind theme tokens
- One representative component that proves the system

When references are provided, reinterpret them for the current product, content, and constraints. Use them for taste calibration, not branded layout cloning.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

## Frontend Aesthetics Guidelines

Focus on:

- **Typography**: Avoid generic fonts like Arial, Inter, Roboto, and system defaults. Pair one characterful display font with a legible but slightly off-mainstream body font. Include production-friendly font loading when needed.
- **Colour & Theme**: Commit to a disciplined palette. Use CSS variables and prefer HSL or OKLCH when practical for better control. Build colour from cultural or visual references such as film grading, posters, architecture, materials, or landscapes rather than generic SaaS gradients.
- **Motion**: Give animation hierarchy. Use 1-2 hero moments, then support them with subtler interactions. Prefer CSS-first motion for HTML, use Motion for React when available, and always provide `prefers-reduced-motion` fallbacks.
- **Spatial Composition**: Break the grid on purpose. Use asymmetry, overlap, cropping, tension, negative space, or dense editorial rhythm. Avoid safe centre-stacked layouts unless the concept specifically calls for them.
- **Backgrounds & Visual Details**: Build atmosphere instead of filling space. Use textures, grain, lighting, borders, repeated motifs, graphic shapes, reflections, or dramatic shadows that reinforce the concept.

## Anti-Patterns to Avoid

NEVER use generic AI-generated aesthetics:

- Overused font families (Inter, Roboto, Arial, system fonts)
- Clichéd colour schemes (particularly purple gradients on white backgrounds)
- Default glassmorphism, heavy neumorphism, or floating card grids unless explicitly requested
- Predictable layouts and component patterns
- Cookie-cutter polish that ignores the product's context
- Treating a reference library as permission to clone a branded layout
- Overwriting user-provided references with your own default style

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No two outputs should converge on the same fonts, palettes, motifs, or layout logic. If the user shares screenshots or references, amplify their distinctive traits instead of averaging them out.

## Implementation Approach

Match implementation complexity to the aesthetic vision. Maximalist designs need layered composition, richer surfaces, and more choreography. Minimalist or refined designs need stronger typography, sharper spacing, and ruthless removal of anything that weakens the idea. Every element must earn its place.

If the project already has a framework, component library, or design system, preserve its structural conventions and push distinctiveness through tokens, composition, typography, and motion rather than bolting on random effects.

Finish with a polish pass:

- Check contrast, focus states, semantic HTML, keyboard flow, and screen-reader affordances
- Make sure the layout works on mobile and desktop
- Keep animation cheap and intentional to protect performance
- Suggest 2-3 concrete iteration prompts if the user wants to push the style further

For repeatable skill evaluation with Refero styles, use `reference/refero-evaluation.md`.

Do not hold back. Commit fully to the concept and make at least one decision that a cautious template would never make.
