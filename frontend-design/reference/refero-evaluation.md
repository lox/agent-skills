# Refero Evaluation

Use this reference when testing whether `frontend-design` responds well to strong visual references instead of collapsing into the same polished default.

## Goal

Check two things:

- Refero-conditioned outputs should change meaningfully in typography, palette, composition, density, and mood.
- The skill should reinterpret references for the new product instead of copying a branded layout.

## Fixed Style Set

Use a stable set of Refero styles so revisions are comparable over time:

- Minimal Design
- Editorial Type
- Playful Canvas
- Premium Design
- High Contrast
- Soft Gradients

If the style library changes, swap in nearby equivalents and keep the set stable for future runs.

## Test Loop

Run one product brief through the same sequence:

1. Baseline run with no visual reference.
2. One run per Refero style.
3. One combined run with a Refero style plus one non-digital reference such as a poster movement, film, building, magazine, or industrial object.

Use the same brief each time. Example brief:

```text
Design a landing page for an independent architecture studio. It should feel premium, memorable, and editorial rather than like a SaaS marketing site.
```

## Prompt Template

```text
Use $frontend-design.

Project brief:
Design a landing page for an independent architecture studio. It should feel premium, memorable, and editorial rather than like a SaaS marketing site.

Reference input:
Use the Refero style "Editorial Type" as a reference source. Extract palette, typography, spacing rhythm, component density, and interaction cues. Reinterpret those traits for this product rather than copying the source layout.
```

For the combined run, append one non-digital reference:

```text
Also draw from 1970s Swiss posters for type rhythm and negative-space discipline.
```

## Scorecard

Score each output against these questions:

- Did the palette change meaningfully from the baseline?
- Did the typography pairing and hierarchy change meaningfully from the baseline?
- Did the layout composition or density change meaningfully from the baseline?
- Is there a clear signature hook tied to the reference instead of a generic flourish?
- Does the output still fit the product brief and content?
- Does it avoid cloning a recognizable branded layout?
- Does it avoid the skill's anti-patterns such as card-grid drift, safe font defaults, and purple-gradient SaaS styling?

## Good Signs

- Different Refero styles produce clearly different layout logic, not just different colors.
- The model names or implies extracted cues such as density, rhythm, and interaction character.
- The combined run feels more original than the Refero-only run.
- The work still looks intentional when reduced-motion, responsive, and accessibility constraints are applied.

## Failure Modes

- Every run collapses to the same hero-plus-cards structure.
- The only differences are palette swaps or surface effects.
- The output copies a source layout too closely.
- The model ignores the reference and falls back to its usual font and spacing habits.
- The combined run becomes noisy instead of more distinctive.

## How To Use Results

If outputs still converge, tighten the skill in one of these places:

- Strengthen `Reference Inputs` if the model is not extracting enough from the reference.
- Strengthen `Signature Hook` if the work is tasteful but forgettable.
- Strengthen `Spatial Composition` if the work keeps returning to safe layouts.
- Strengthen anti-patterns if the same defaults keep reappearing.
