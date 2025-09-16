---
title: Assessments
layout: coursebook
---

# Assessment Overview

There are **two** types of assessments:

* **Group Assessments** are each around a month long, allowing a deep-delve into a specific area of Data Science. They make up a total of 60% of the course mark (two, each worth 30%).
* **Individual Portfolios** are whole-semester activities, individually undertaken to explore areas of data science covered by the lecture material in greater depth. Portfolios make up remaining 40% of the course.

* Formative Assessments (that do not contribute to grade):
  - [Assessment 0]({{ site.data.assessment0.url }}) (Due Week 3)
  - [Portfolio 0]({{ site.data.individualassessment0.url }}) (Due Week 3)
    - Including the short Questions for [Block 01](coursebook/01.md).
* Summative Group Assessments: total 60% (each 30%)
  - [Assessment 1: Supervised Prediction]({{ site.data.assessment1.url }}) (First group assessment)
  - [Assessment 2: Data at Scale]({{ site.data.assessment2.url }}) (Second group assessment)
* Individual Portfolios: total 40% 
  - (80%) [Individual Portfolio: Statistical Machine Learning]({{ site.data.individualassessment1.url }})
  - (20%) The short Questions for Block 02-11 (see below).

The Assessments are together in the Individual Portfolio, but are also linked separately for reference from the appropriate Block of the [timetable](timetable.md):

* [Portfolio Block 02]( {{ site.data.block02.portfolio.url }} )
* [Portfolio Block 03]( {{ site.data.block03.portfolio.url }} )
* [Portfolio Block 04]( {{ site.data.block04.portfolio.url }} )
* [Portfolio Block 05]( {{ site.data.block05.portfolio.url }} )
* [Portfolio Block 06]( {{ site.data.block06.portfolio.url }} )
* [Portfolio Block 07]( {{ site.data.block07.portfolio.url }} )
* [Portfolio Block 08]( {{ site.data.block08.portfolio.url }} )
* [Portfolio Block 09]( {{ site.data.block09.portfolio.url }} )
* [Portfolio Block 10]( {{ site.data.block10.portfolio.url }} )
* [Portfolio Block 11]( {{ site.data.block11.portfolio.url }} )

## Guidance on Individual Portfolios

The Portfolio is assessed for blocks 2-11. Block 1 is marked similarly but is formative, i.e. does not contribute to your mark. The deadline is in assessment preparation week of TB1. In each block contains two activities: 

1. (20%) Multiple choice questions submitted via Noteable (log in via Blackboard). These should be straightforward, either direct from your notes or with simple experiments you can conduct as extensions of the Workshop.
2. (80%) Long-form reflective questions that should require a deeper understanding of the course material and may require you to undertake further reading or experimentation.

You may take the multiple-choice component at any time and it is recommended that you do this when you work through the Workshop content. The long-form content is submitted at the end of the course, and you are recommended to make a first draft/note form attempt when you first see the content, and reflect back on it in a finessing stage during the examination preparation time (in lieu of an exam).

### Length and format of long-form portfolio

Your Portfolio should give a **one-page** answer to one question of your choice from 5 Blocks (2-11). Therefore the whole Portfolio is only 5 pages long. However:

* The goal is not to make you undertake a length-finessing exercise. If the content you provide appears as if it would fit on one page after such an exercise, you can submit is anyway. **There is a strict limit of 8 pages** for the portfolio content, with answers that are clearly too long being be penalised.
* You can however submit **Supporting Evidence** as an appendix to the portfolio. It will not be directly assessed but may be used as evidence to support your claims, i.e. any statements you make with supporting evidence will be more favourably interpreted, but if your statements are carefully given and correct the evidence is not essential. This is not limited. Appropriate content is RMarkdown files knitted to pdf, Jupyter Notebooks, etc.

### Workshop Questions submitted by Noteable

* Submitted via Noteable via [Blackboard](https://www.ole.bris.ac.uk/ultra/courses/_255714_1/cl/outline):
	* Go to the Data Science Toolbox blackboard page
	* Select Noteable
	* Select **R with stan** as your "personal notebook server" and press "Start"
	* Go to "Assignments"
	* Select **BlockXX** and press "Fetch"
	* Click **BlockXX>** which opens up a drop down containing the only assignment, **BlockXX**. Select this.
	* The assignment opens in Jupyter. Complete the worksheet. When you are done, **save** and return to the Assignments tab. Press **validate**, and when it is successful, press **submit**.
* You **can** work in groups on these questions, as long as you discuss why you believe your choices. The goal is to learn. You will not receive the answers.

## Guidance on Group Assessments

There is a complete [Example Assessment](https://github.com/dsbristol/dst_example_project).

Undertaking a group project online is a difficult process that requires care and planning. Help for planning your project is given in [Block 1](coursebook/01.md), and includes:

* **1.3.3 Workshop Lecture on Assessments**, listed completely in [Block 01](coursebook/01.md).
* The [Example Group Assessment](https://github.com/dsbristol/dst_example_project), which you should go over carefully.
* [Appendix 1: Preparation List](coursebook/appendix1-prep.md).
* [Appendix 2: Replicability](appendix2-replicability.md), which explains how to make your project run reliably on others' computers.
* [Appendix 3: GitHub](appendix3-github.md), which explains how to use GitHub.
* [Appendix 5: Bluecrystal](coursebook/appendix5-bluecrystal.md), which is our High Performance Computing Infrastructure.
* The [Equity Formula](/dst/assets/assessments/equityshare.nb.html) for redistributing marks.

The individual assessment instructions has significant guidance. These extra thoughts give context.

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
