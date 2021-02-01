---
title: Appendix 5 - Bluecrystal
layout: coursebook
---

Students on the [MSc Mathematics of Cybersecurity](https://www.bristol.ac.uk/study/postgraduate/2020/sci/msc-mathematics-of-cybersecurity/) have access to [bluecrystal phase 4](https://www.acrc.bris.ac.uk/acrc/phase4.htm). The process is as follows:
* The course organiser sets up a teaching project for the correct academic year.
* Students complete the [webform](https://www.acrc.bris.ac.uk/login-area/apply.cgi) to have their accounts activated. The required information is SURNAME, FIRSTNAME, USERNAME, EMAIL, and  PROJECT CODE (below).
  * For help we can contact [service-desk-hpc@bristol.ac.uk](mailto:service-desk-hpc@bristol.ac.uk)
* To log on follow the instructions [here](https://www.acrc.bris.ac.uk/protected/bc4-docs/access/index.html)
* You should create an ssh key and place it on BlueCrystal similarly to as you did for [GitHub ](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent), to enable password-less access.
  - You [add your public key to ~/.ssh/authorized_keys](https://linuxize.com/post/how-to-setup-passwordless-ssh-login/) on Bluecrystal
  - You can do this by copying files or pasting text into the file using a file editor.
  - This might require using a command-line editor.
* To connect from offsite, you will need to be on the University of Bristol [VPN](https://uob.sharepoint.com/sites/itservices/SitePages/vpn.aspx), or use [SEIS](https://seis.bristol.ac.uk/).

In Data Science Toolbox, we will be using this primarily for:
	* Large Compute Jobs;
	* GPU (Graphics Processing Unit) jobs, specifically for learning Neural Networks.

### Project details:

- Project: MATH023982
- Title : Data Science Toolbox - Cybersecurity Masters (correct year)

## Getting started

See my [HPC notes on Github](https://github.com/danjlawson/hpc-notes) for code.

* Start with the [Documentation](https://www.bristol.ac.uk/acrc/high-performance-computing/hpc-documentation-support-and-training/).
* This which has instructions to access [BC3 & BC4](https://www.acrc.bris.ac.uk/protected/hpc-docs/connecting/index.html) from Windows, Linux and Mac.
* It explains how to [copy files](https://www.acrc.bris.ac.uk/protected/hpc-docs/transferring_data/index.html) to and from the HPC.
* You add popular software (such as R, python, compilers, etc) using [Modules](https://www.acrc.bris.ac.uk/protected/hpc-docs/software/index.html). This makes getting things set up quite straightforward.
* The most important change is that you will *submit jobs* instead of running them manually. This is handled by a [scheduler](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/index.html), which is slightly different on BC3 vs 4.
* You do this by writing a [job submission script](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/serial.html). There are a couple of gotchas:
* The script needs to have access to any software. Do this by using the right modules, or having them in your PATH. I do this by adding the following to my `~/.bashrc` file, which lets me put any binaries I want to access in `~/bin`:
```{bash}
export PATH="$HOME/bin:$PATH"
```
  * You can set this up for yourself by `mkdir ~/bin` and then when you download or create a binary, put it there.
* You need your scripts to change to the correct directory themselves. Luckily the script knows where it was run from so make your first command:
  * On BC3 this is `cd "${PBS_O_WORKDIR}"`, on BC4 it is `cd "${SLURM_SUBMIT_DIR}"`.
* There much **not be any lines before the submission information**, comment or otherwise! So every script:
  * Must start with the "shebang" (`#!/bin/bash` which says what will run your job; stick with bash unless you know what you are doing!);
  * The following lines will be your `#PBS` (BC3) or `#SBATCH` (BC4) instructions;
  * Only then put your own code or comments. If comments, safest to separate with a blank comment line first.
* The most important class of parallel jobs are **embarrassingly parallel**. This means that they can run independently. Doing this is totally trivial with and [array job](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/array.html). You will set an *array index variable* (differently no BC3/4) in your script, which you should either use as:
  * Input to your script, or
  * an index for which of a predefined list of commands to run.
* If you want multiple cores per run (for example you are using python/R with a parallel package) then you simply request more cpus for each job. This is also the best way to ask for more memory! It is best to request simple fractions of what the nodes have. e.g. BC3 has many 16 core nodes. Using `ncpus:8` asks for half of a node, and should not use more than half of the memory.
* [GPU jobs](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/gpu.html) are pretty simple to run too: just ask for a gpu and request the gpu queue.
* It is good practice to output useful information such as the date and duration of the job, etc to stdout. See e.g. [variables](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/variables.html).

## Additional thoughts on the HPC

* When you logon, each time you get a new session. This can be annoying. There is a tool called `screen` (and another called `tmux`) that allows you to keep many terminals running.
  * You will need to choose a single server node to log on to.
  * screen takes some getting used to.
  * My setup is [.screenrc](https://raw.githubusercontent.com/danjlawson/hpc-notes/main/screen/dotscreenrc), which you put into `$HOME/.screenrc` (as it says in the header of the file.)
