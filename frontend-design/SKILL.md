---
name: frontend-design
description: Creates distinctive, production-grade frontend interfaces with a strong visual point of view. Use when building web components, pages, applications, or prototypes that should feel memorable, polished, and non-generic.
---

# Frontend Design

Creates distinctive, production-grade frontend interfaces with a clear point of view. Builds real working code that feels specific to the brief, not statistically averaged.

## Start From The Product

Before styling anything, pin down the product surface:

- **Subject**: What concrete thing is this interface about? If the brief is vague, choose one subject and state it.
- **Audience and moment**: Who is using it, on what device, with what pressure, skill level, and goal?
- **Surface**: List the actual sections, controls, data, and actions. Replace generic cards with the real content the user needs.
- **Constraints**: Framework, component library, design system, performance, accessibility, existing brand, and any references.
- **Success test**: One sentence describing what should feel better after the UI exists.

AI UI tools drift into generic patterns when they guess. Do not let them guess the product.

## Design Pass

Do one compact design pass before coding:

1. **Extract references**. If the user provides a screenshot, moodboard, existing page, design system, or `DESIGN.md`, extract palette, typography, spacing rhythm, density, imagery, and interaction cues. Reinterpret those traits; do not clone a branded layout. If no reference is provided, pick 2-3 subject-specific non-web references from the product's world, materials, tools, places, eras, or media.
2. **Explore three directions in working notes**. Make them meaningfully different in layout mechanic, density, palette, type, motion, and signature. Do not just swap colours.
3. **Choose the least templated direction that still fits the brief**. Reject hero-plus-card-grid, centred SaaS composition, and decorative numbered sections unless the content truly calls for them.
4. **Lock a compact system**:
   - 4-6 named colours with roles and a clear position: bold/saturated, moody/restrained, high-contrast/minimal, or another brief-specific choice
   - Display, body, and utility type roles with deliberate scale and weight choices
   - Spacing, radius, shadow, border, texture, and motion tokens
   - One signature element the page will be remembered by

Then build the chosen direction exactly. Bold maximalism and refined minimalism both work; the difference is whether every choice comes from the subject.

## Design Principles

- **Hero as thesis**: Open with the most characteristic thing in the subject's world: a tool, artifact, interaction, number, text treatment, image, or live demo. A big headline, stats row, and accent gradient is the default answer, not a design concept.
- **Typography as identity**: Avoid defaulting to Arial, Inter, Roboto, or system fonts unless the existing product requires them. Pair a characterful display role with a highly legible body role, and let type treatment carry personality.
- **Composition as a choice**: Use asymmetry, overlap, z-depth, full-bleed moments, dramatic scale jumps, dense rhythm, or negative space when they serve the content.
- **Structure as information**: Dividers, labels, badges, tabs, numbering, and grids must encode something true about the content. Do not add "01 / 02 / 03" markers unless the content is actually sequential.
- **Copy as interface**: Write real labels, states, examples, empty states, and errors. Specific plain copy beats clever filler.
- **Motion with hierarchy**: Use 1-2 meaningful motion moments, then keep the rest quiet. Always respect `prefers-reduced-motion`.
- **Restraint**: Spend boldness in one place. Cut decoration that does not make the product clearer or more memorable.

## Anti-Patterns to Avoid

NEVER use generic AI-generated aesthetics:

- Overused font families (Inter, Roboto, Arial, system fonts)
- Clichéd colour schemes (particularly purple gradients on white backgrounds)
- Default glassmorphism, heavy neumorphism, or floating card grids unless explicitly requested
- Predictable hero-plus-cards layouts and component patterns
- Cookie-cutter polish that ignores the product's context
- Treating a reference library as permission to clone a branded layout
- Overwriting user-provided references with your own default style
- Defaulting to warm cream plus serif plus terracotta, near-black plus acid accent, or broadsheet hairline editorial styling unless the brief earns it
- Lorem ipsum, vague marketing claims, fake dashboards, and placeholder charts

Instead, use distinctive type, a committed palette, a layout mechanic, and bespoke content details rooted in the brief. Check the chosen direction against obvious defaults for this task and revise anything that could fit any similar product. If the user shares screenshots or references, amplify their distinctive traits instead of averaging them out.

## Implementation Approach

If the project already has a framework, component library, or design system, preserve its structural conventions and push distinctiveness through content, tokens, composition, typography, and motion. Do not add dependencies for surface effects.

When writing CSS, keep selector specificity simple and predictable. Type selectors plus broad utility classes often cancel each other out around section spacing, buttons, and calls to action.

Finish with a polish pass:

- Check contrast, focus states, semantic HTML, keyboard flow, and screen-reader affordances
- Make sure the layout works on mobile and desktop with real content
- Keep animation cheap and intentional to protect performance
- Take screenshots when the environment supports it, then fix visible spacing, hierarchy, overflow, and alignment issues

Commit fully to the concept and make one justified decision that a cautious template would not make.
