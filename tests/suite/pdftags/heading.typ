--- heading-tags-basic pdftags ---
#set pdf(standard: "ua-1")
= Level 1
== Level 2
=== Level 3

--- heading-tags-first-is-not-level-1 pdftags ---
#set pdf(standard: "ua-1")
// Error: 1-11 PDF/UA-1 error: the first heading must be of level 1
== Level 2

--- heading-tags-non-consecutive-levels pdftags ---
#set pdf(standard: "ua-1")
= Level 1
// Error: 1-12 PDF/UA-1 error: skipped from heading level 1 to 3
// Hint: 1-12 heading levels must be consecutive
=== Level 3

--- heading-tags-complex pdftags ---
#set pdf(standard: "ua-1")
= Level 1
== Level 2
=== Level 3
=== Level 3
== Level 2
=== Level 3
==== Level 4
== Level 2
=== Level 3
=== Level 3
=== Level 3
= Level 1
== Level 2

--- heading-tags-empty pdftags ---
#set pdf(standard: "ua-1")
// Error: 1-2 PDF/UA-1 error: heading title is empty
=

--- heading-tags-context-body pdftags ---
#set pdf(standard: "ua-1")
// Error: 2-32 PDF/UA-1 error: heading title could not be determined
// Hint: 2-32 this seems to be caused by a context expression within the heading
// Hint: 2-32 consider wrapping the entire heading in a context expression instead
#heading(context [Hello there])


--- heading-tags-run-in pdftags ---
#set pdf(standard: "ua-1")
#show heading.where(level: 2): it => [#strong(it.body) ]
= Main heading
Normal paragraph.
== Run-in heading.
Following paragraph text.

--- heading-tags-run-in-boxed pdftags ---
#set pdf(standard: "ua-1")
#show heading.where(level: 2): it => [#box(strong(it.body)) ]
= Main heading
== Run-in heading.
Following paragraph text with #link("https://typst.app")[a link].

--- heading-tags-run-in-alone pdftags ---
#set pdf(standard: "ua-1")
#show heading.where(level: 2): it => it.body
= Main heading
== Run-in heading.

A separate paragraph.

--- heading-tags-run-in-middle pdftags ---
#set pdf(standard: "ua-1")
#show heading.where(level: 2): it => it.body
= Main heading
Before #heading(level: 2)[First.] Between #heading(level: 2)[Second.] After.

--- heading-tags-run-in-language pdftags ---
#set pdf(standard: "ua-1")
#show heading.where(level: 2): it => it.body
= Main heading
#text(lang: "de")[#heading(level: 2)[Überschrift.] Deutscher Absatz.]


--- heading-tags-run-in-numbered pdftags ---
#set pdf(standard: "ua-1")
#set heading(numbering: "1.1")
#show heading.where(level: 2): it => [
  #context counter(heading).display(it.numbering) #it.body.
]
= Main heading
== Numbered heading <run-in>
Following text referring to @run-in.

--- heading-tags-run-in-containers pdftags ---
#set pdf(standard: "ua-1")
#show heading.where(level: 2): it => it.body
= Main heading
- #heading(level: 2)[List heading.] List body.
#table(columns: 1, [#heading(level: 2)[Cell heading.] Cell body.])

--- heading-tags-run-in-wrapping pdftags ---
#set pdf(standard: "ua-1")
#set page(width: 160pt, height: 160pt, margin: 15pt)
#show heading.where(level: 2): it => strong(it.body)
= Main heading
== A longer inline heading that wraps across lines.
#lorem(50)
