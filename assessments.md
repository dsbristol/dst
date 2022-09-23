---
title: Assessments
layout: coursebook
---

# Assessment Overview

There are **two** types of assessments:

* **Group Assessments** are are approx two-month long, allowing a deep-delve into a specific area of Data Science applied to Cyber Security. They make up a total of 60% of the course mark (each 20%).
* **Individual Portfolios** are whole-semester activities, individually undertaken to explore areas of data science covered by the lecture material in greater depth. They make up a total of 40% of the course make (each 20%).

The [Assessment List](coursebook/appendix2-assessments.md) lists each assessment, which are released in the appropriate Block of the [timetable](timetable.md).

Undertaking a group project online is a difficult process that requires care and planning. Help for planning your project is given in [Block 1](coursebook/01.md), and includes:

* **1.3.3 Workshop Lecture on Assessments**, listed completely in [Block 01](coursebook/01.md).
* The [Example Assessment](https://github.com/dsbristol/dst_example_project), which you should go over carefully.
* [Appendix 1: Preparation List](coursebook/appendix1-prep.md).
* [Appendix 3: Replicability](coursebook/appendix3-replicability.md), which explains how to make your project run reliably on others' computers.
* [Appendix 4: GitHub](coursebook/appendix4-github.md), which explains how to use GitHub.
* [Appendix 5: Bluecrystal](coursebook/appendix5-bluecrystal.md), which is our High Performance Computing Infrastructure, essential for later Assessments.
* The [Equity Formula](/dst/assets/assessments/equityshare.nb.html) for redistributing marks where a different equity is agreed.

## Guidance on Group Assessments

The individual assessment instructions has significant guidance. This is extra thoughts that are less directly relevant but give context.

### Comment on Markdown reflections:

The PDF versions of the example reflections are created using [Pandoc](https://pandoc.org/) and it is trivial:

```{sh}
pandoc -o RachelR_Reflection.pdf RachelR_Reflection.md 
```

[Markdown](https://www.markdownguide.org/extended-syntax/) is an acceptable format, though PDF looks nicer. Referencing is important but don't overdo it; you might use footers `[^ref1]`, or just place simple labels without worrying about Markdown format at all (label2).

`[^ref1]: Lawson D, An Example Reference, 2020.`

(label2): Lawson D, A Second Example Reference without Markup, 2020.

### Comment on Report formats:

It is completely fine to present a well commented Rmd or ipynb file. You are welcome to try to generate a beautiful PDF in which all of the results are knitted together, but it can be awkward if content is fundamentally separated. Yes, you can create a PDF from each file and merge the PDF, and doing so once is educational, but it isn't the point of DST.

**Please commit your final output**. It is generally considered bad practice to commit transient content to your repository. This would include the Jupyter Notebook with all of the content competed, and the html output of Rmd. However, for the purposes of generating a one-off assessed report, it is safest to do this, though best only for your final commit. 

This is because it is possible that I cannot run your code, for a good reason or a bad, and therefore I want to see what the output should be.

Why is transient content bad? You repository will get bigger and take longer to process as the whole history of everything that you've generated is stored. Text files compress very nicely for this content, but binary objects such as images and data, hidden inside html or ipynb files, compress badly.

### Comment on data:

Don't commit very large datasets to GitHub, and don't commit modestly large ones unless necessary (and try not to duplicate them). There are file size limits, but it is inefficient. Try to use a different data sharing solution, such as OneDrive, for such data.
