---
title: Replicability of code in R and Python
layout: coursebook
---

This page records notes on replicability that would otherwise be buried in technical content.

Note that if you use them in an assessment, make sure that any activation instructions are given in either `README.md` or the appropriate project file.

## Replication in R

To install a package if it is not already installed, you can use (for the example `fs`):

```{r}
if (!require("fs")) install.packages("fs")
```

If you would prefer to use a `requirements.txt` like solution, instead create the file `requirementR.txt` file with the package information:

```
fs 1.4.1
data.table 1.11.4
```

Create an R script called `requirementsR.sh` containing the content:

```{r}
#!/usr/bin/bash
while IFS=" " read -r package version; 
do 
  Rscript -e "devtools::install_version('"$package"', version='"$version"')"; 
done < "requirementsR.txt"
```

Make it executable, and then install via:

```{bash}
./requirementsR.sh
```

See [stack overflow](https://stackoverflow.com/questions/54534153/install-r-packages-from-requirements-txt-file) for more details.

## Replication in Python

Python modules are often changing. I had to make several changes to get this code from 2018 to work in 2020. This highlights the importance of documenting the libraries and python version that were used to generate a particular output.

Python handles versioning with something called [requirements.txt](https://medium.com/@boscacci/why-and-how-to-make-a-requirements-txt-f329c685181e). I have done this for this project, using the recommended way to record the status of every package:

```{bash}
pip3 freeze > requirements.txt
```

This can then in theory be exactly replicated on your system using 

```{bash}
pip install -r requirements.txt
```

However, if we just do this, we may have all sorts of versioning problems if you and I have slightly different verisons of python. Instead, we create a **Virtual Environment**, in which we can install a specified set of packages and which we can do what we like with without messing up the rest of the system.

To do this, I followed the instructions to do this with [venv](https://janakiev.com/blog/jupyter-virtual-envs/)

```{bash}
python3 -m venv project0
```

This creates a new directory called `project0` in your working directory

```{bash}
source project0/bin/activate
jupyter-notebook # Run Jupyter-notebook in the virtual environment
```

When you are done, you tear-down the virtual environment with

```{bash}
deactivate
```

Requirements management can be done many ways and there are several tools to do it "better". The pip freeze approach is [considered harmful](https://medium.com/@tomagee/pip-freeze-requirements-txt-considered-harmful-f0bce66cf895). Alternatives include, for example, [pip-tools](https://github.com/jazzband/pip-tools/).
