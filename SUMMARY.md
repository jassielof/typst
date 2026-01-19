# Summary for variable fonts support for typst

At most, the important axis are:

- weight
- italic
- slant
- and optical size

So we should focus on them, rather full fledged support for all possible axes, we could make a tracking issue for it, with subissues for each possible axis as necessities arise.

## Axis definitions

### Weight (wght)

Properties:

- Default: 400
- Min: 1
- Max: 1000
- Step: 1

> Adjust the style from lighter to bolder in typographic color, by varying stroke weights, spacing and kerning, and other aspects of the type. This typically changes overall width, and so may be used in conjunction with Width and Grade axes.

### Italic (ital)

Properties:

- Default: 0
- Min: 0
- Max: 1
- Step: 1

Basically a toggle (binary) axis, either the font is upright (0) or italic (1).

> Adjust the style from roman to italic. This can be provided as a continuous range within a single font file, like most axes, or as a toggle between two roman and italic files that form a family as a pair.

### Optical size (opsz)

Properties:

- Default: 14
- Min: 5
- Max: 1200
- Step: 0.1

> Adapt the style to specific text sizes. At smaller sizes, letters typically become optimized for more legibility. At larger sizes, optimized for headlines, with more extreme weights and widths. In CSS this axis is activated automatically when it is available.

### Slant (slnt)

Properties:

- Default: 0
- Min: -90
- Max: 90
- Step: 1

> Adjust the style from upright to slanted. Negative values produce right-leaning forms, also known to typographers as an 'oblique' style. Positive values produce left-leaning forms, also called a 'backslanted' or 'reverse oblique' style.

## References

- [Axis definitions from Google Fonts](https://fonts.google.com/variablefonts#axis-definitions)
- <https://github.com/yeslogic/allsorts-tools/blob/master/src/subset.rs>
- <https://github.com/yeslogic/allsorts/releases/tag/v0.15.0>

### Related issues and comments

#### [Support variable fonts](https://github.com/typst/typst/issues/185)

No relevan information, just user request to support it. It's the main issue to support variable fonts.

#### [variable fonts in Flutter](https://github.com/flutter/flutter/issues/33709)

```md
Oh there's 2 more things, which might not be relevant to flutter, but maybe are more relevant to flutter than a typical design app...

Flutter developers and end users of flutter apps will need a easy way to know what's actually available in each VF family; that's because they will often be constructing UIs for end users to set axes values, as much as they will set axes values within the apps own code itself.
eg How to obtain a dict of axes in each variable font family (which can be more than 1 TTF file, despite a lot of oversimplification in docs that "a VF is lots of font files turned into 1 file", especially 2, one roman and one Italic) and their tags, labels, min/default/max values, and flags, which are all in the font files fvar tables.

A nuance here is that axes have a bit mask of flags, and the only one defined so far is "HIDDEN", which isn't meant to mean "inaccessible to users" but rather "shown on request", like from some progressive disclosure or preference UI.

At a high level, there's 3 benefits to VFs: to compress, to express, and to finesse. Compress is as stated nicely by @srix55 above, to use a bunch of weight styles in a smaller file-size disk representation by run time instantiation of those weights. Express is where the maker user slides the slider or dials the dial or whatever to find just the right value of the axis that expresses their intent, which could be just a very specific weight like 427, or some FUNK or WONK axis to whatever value they feel like, and typically it's clearly visible to anyone what the charge was. Finesse is like opsz or GRAD where the value is set indirectly, based on the context of the text (like font size or dark mode) and are often very subtle adjustments.

So, with this understanding, it may be that some axes are intended for indirect use, or direct but infrequent use, and are best left out of the axes controls shown to every user, always, but rather only shown to users who somehow indicated they do want to see every axis in the font.

It would be nice if flutter made that information also easily available to developers so they can do the right things when exposing axes to their end users.

I guess there may already be such a getter method for font features, and as above a separate and similar method for variations would be great. If there isn't already that for features, that's also necessary, since axes can trigger features and control of both is necessary in that case. The Frances and Recursive fonts demo this.

There is at least 3 "axis registry" data sets, one from ISO MPEG Open Font Format, which is fed mainly by the next one, the Microsoft OpenType Specification which actually has a website version of the spec and is almost always in sync with the first; and the Google Fonts one at GitHub.com/GoogleFonts/axisregistry , which is a superset of, although not directly derivative from, the others.
These provide additional contextual information about axes, like longer descriptions that explain an axis, typical interesting instance locations, etc.

This is similar to the above, being about providing convenience methods for app developers to expose the full depth of facilities offered by VFs.
```

```md
For context, fonts.google.com has updated 100s of font families to be variable fonts, including the # 2 most popular family Open Sans - and the previous "Open Sans Condensed" family is no longer listed (although the CSS API serves it so existing users aren't effected) because those styles are now available in the Width (wdth) axis.

I also kindly note that in comments above and eg #67688 (comment) there's a conflation between OpenType features (aalt, cwsh, ss01, etc) and OpenType variations (wght, wdth, WONK, GRAD, etc); features are binary toggles, introduced in the late 90s, and variations are continuous ranges introduced in 2019 - and reaching mass adoption in 2022. The underlying libraries (freetype, harfbuzz) that processes them, that Dart/Flutter depend on, treat them rather separately.

The FontFeature() method would perhaps be only appropriate for features, while a new FontVariation() method may be more appropriate. This would mirror the CSS properties font-feature-settings and font-variation-settings. Although, I also note that those properties are poorly designed for actually cascading (see eg https://web.dev/variable-fonts/#font-variation-settings-inheritance).

An equivalent/superior to the CSS property font-optical-sizing: auto is also strongly desirable for Flutter; I say superior because again that CSS property was poorly designed and a improvement proposal is at w3c/csswg-drafts#4430 (and Chrome has had bugs with this, see eg crbug.com/1305237)

Finally, CSS underspecifies how "outline stroking" and semi-opaque overlapping glyphs should work, and variable fonts exacerbate this - since they make overlapping contours, intra-glyph, very common; inter-glyph overlaps are also common and not consistently handled. While glyph overlaps were always allowed in the TrueType specification (since late 80s...) the PostScript font specs disallowed them, and many TTFs were made as derived from PS fonts, such that much software does not correctly handle them. https://jsbin.com/xewuzew demos some issues in current browsers with this.

So, to implement full support for variable fonts, I recommend Flutter have those 4 things:

- a way to set variable font axes values with inheritance
- by default, when the opsz axis exists in a font, set the value to the font size, and allow a ratio override, plus override via the above axis value sette. (Ideally the auto value is resolved to physical Points, 1/72nd of an inch, although I am recommending that ideal as a partisan and recognize there are other positions on what value to use; but the key idea is that it is set based on font size)
- correctly render semi-opaque text
- correctly render outline-stroked text
```

### Related projects

#### LaurenzV closed PR

Main initial attempt for supporting variable fonts in typst, but closed due to:

```md
> This PR is still in-progress and aims to add some initial support for variable fonts. Initial because the aim is not to give the user full control over setting custom variation coordinates (this could be good future work, but probably makes more sense to implement in conjunction with the planned `font` object). The aim is to automatically select a correct instance based on the `wght` (font weight), `wdth` (font stretch), and `ital`/`slnt` (italic) axes, which I think should over 95%+ of the use cases.
>
> It also adds support for embedding CFF2 fonts in PDFs by converting them to a TTF font, which is not the best approach (better would be to convert to CFF), but it should do the job. CFF2 fonts are pretty rare ([less than 1% of variable fonts](https://almanac.httparchive.org/en/2024/fonts#variable-fonts)), but based on past issues it seems like some systems do use some CFF2-based Noto fonts, so this is definitely worth fixing.
>
> Fixes #185 (tracking support for specifying variable font axes is probably worth opening a new issue for).
>
> Example:
>
> ```
> #for (font, d_text) in (
>     ("Cantarell", "I love using variable fonts!"),
>     ("Noto Sans CJK SC", "我太喜欢使用可变字体了!"),
>     ("Roboto", "I love using variable fonts!"),
> ) {
>     [= #font]
>     for i in range(100, 900, step: 100) {
>         text(weight: i, font: font)[#d_text \ ]
>     }
> }
> ```
>
> Result: [test.pdf](https://github.com/user-attachments/files/21813827/test.pdf)
>
> TODOs:
>
> * Properly hook up the `wdth` and `slant`/`italic` axes.
> * Bulk test with maany fonts to ensure it works as expected.
> * Fix or find a workaround for the `pixglyph` bug that makes CFF2 fonts render as black rectangles in PNG export.
> * Investigate whether the code leads to regressions in SVG rendering, where variable fonts are currently not supported.
> * Add test cases
> * Clean up code + documentation

```md

It's located as a closed PR and submodule in `./modules/typst-laurenzv-variable-fonts`.

#### All sort crate

Located in `./modules/allsorts`, as a git submodule for reference, since they have a working variable font implementation.

##### All sorts tools repository

Located in `./modules/allsorts-tools` also as a git submodule for reference, since it has usage examples and extra tools.

#### Typst own subsetter (my fork for testing and development purposes, synced with upstream)

Forked and also as submodule for reference and possible editing/testing since it's in charge of font subsetting in typst.

Located in `./modules/typst-subsetter`.
