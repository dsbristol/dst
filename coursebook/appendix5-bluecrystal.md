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
* GPU (Graphics Processing Unit) jobs, specifically for learning Neural Networks;
* Access to software for parallel computing.

### Project details:

- Project: MATH027744
- Title : Data Science Toolbox - Cybersecurity Masters (correct year)

## Getting started

See my [HPC notes on Github](https://github.com/danjlawson/hpc-notes) for code.

* Start with the [Documentation](https://www.bristol.ac.uk/acrc/high-performance-computing/hpc-documentation-support-and-training/).
* This which has instructions to access [BC4](https://www.acrc.bris.ac.uk/protected/hpc-docs/connecting/index.html) from Windows, Linux and Mac.
* It explains how to [copy files](https://www.acrc.bris.ac.uk/protected/hpc-docs/transferring_data/index.html) to and from the HPC.
* You add popular software (such as R, python, compilers, etc) using [Modules](https://www.acrc.bris.ac.uk/protected/hpc-docs/software/index.html). This makes getting things set up quite straightforward.
* The most important change is that you will *submit jobs* instead of running them manually. This is handled by a [scheduler](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/index.html).
* You do this by writing a [job submission script](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/serial.html).

There are a couple of gotchas:
* The script needs to have access to any software. Do this by using the right modules, or having them in your PATH. I do this by adding the following to my `~/.bashrc` file, which lets me put any binaries I want to access in `~/bin`:
```{bash}
export PATH="$HOME/bin:$PATH"
```
  * You can set this up for yourself by `mkdir ~/bin` and then when you download or create a binary, put it there.
* You need your scripts to change to the correct directory themselves. Luckily the script knows where it was run from so make your first command:
  * On BC4 it is `cd "${SLURM_SUBMIT_DIR}"`.
* There much **not be any lines before the submission information**, comment or otherwise! So every script:
  * Must start with the "shebang" (`#!/bin/bash` which says what will run your job; stick with bash unless you know what you are doing!);
  * The following lines will be your `#SBATCH` instructions, for example:
```{bash}
#SBATCH --job-name=test-job-name
#SBATCH --partition=test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=0-1:00:00
#SBATCH --mem=1000M
#SBATCH --error=.log/error.txt
#SBATCH --output=.log/log.txtexport
```
  * Only then put your own code or comments. If comments, safest to separate with a blank comment line first.
* The most important class of parallel jobs are **embarrassingly parallel**. This means that they can run independently. Doing this is totally trivial with and [array job](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/array.html). You will set an *array index variable* in your script, which you should either use as:
```{bash}
#SBATCH --array=100-109
echo i="${SLURM_ARRAY_TASK_ID}"
```
  * Then as input to your script, e.g. `./run_cmd.py $i` or
  * an index for which of a predefined list of commands to run.
  * I've already done the work making this simple [with some helper scripts](https://github.com/danjlawson/hpc-notes).
* If you want multiple cores per run (for example you are using python/R with a parallel package) then you simply request more cpus for each job. This is also the best way to ask for more memory! It is best to request simple fractions of what the nodes have. e.g. BC4 has many 24 core nodes. Using `ncpus:8` asks for one third of a node, and should not use more than one third of the memory.
* [GPU jobs](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/gpu.html) are pretty simple to run too: just ask for a gpu and request the gpu queue.
* It is good practice to output useful information such as the date and duration of the job, etc to stdout. See e.g. [variables](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/variables.html).

## Additional thoughts on the HPC

* When you logon, each time you get a new session. This can be annoying. There is a tool called `screen` (and another called `tmux`) that allows you to keep many terminals running.
  * You will need to choose a single server node to log on to.
  * screen takes some getting used to.
  * My setup is [.screenrc](https://raw.githubusercontent.com/danjlawson/hpc-notes/main/screen/dotscreenrc), which you put into `$HOME/.screenrc` (as it says in the header of the file.)

### Bluecrystal Keras and Tensorflow

1. To get a version of anaconda that works with Tensorflow **on BlueCrystal Phase4**:
```{sh}
module load languages/anaconda2/5.3.1.tensorflow-1.12
```
Or on **BluePebble**:
```{sh}
module load lang/python/anaconda/3.9.7-2021.12-tensorflow.2.7.0
```
You can add this to your `.bashrc` file so that this is always loaded for you.
2. To install tensorflow and all dependencies, we need to make a [conda environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html) for it.
Note that you need to do these commands separately as some require interactive confirmation.
```{sh}
conda init ## Required to make conda happy on the nodes
conda create -y -n tf-env
conda activate tf-env
conda install tensorflow keras ipython pandas scikit-learn
 ## NB By default there is no interactive python!
  ## You can install anything else and it will be placed in the appropriate place by conda
```
3. You will then need to write a script that will complete your desired task.
However, note that **bluecrystal phase 4** or **bluepebble** are most easily configurable to run **Tensorflow** GPU jobs.
    * You can do this interactively by using `srun -i` as noted in my [HPC notes](https://github.com/danjlawson/hpc-notes); see the [GPU Jobs documentation](https://www.acrc.bris.ac.uk/protected/hpc-docs/scheduler/gpu.html). 
	* For an interactive testing environment with one core for one hour:`srun --nodes=1 --ntasks-per-node=1 --time=01:00:00 --pty bash -i`).
	* To request an interactive session with 16 cores for 60 hours: `srun --nodes=1 --ntasks-per-node=16 --time=60:00:00 --pty bash -i` .
	* In my interactive session, the following got things working:
```{sh}
conda init ## Required to make conda happy on the nodes
source ~/.bashrc ## Required to load what conda init just did
conda activate tf-env ## Gets us into our GPU environment
ipython3
```
    * I was then able to run ipython interactively on the compute node:
```{python}
from keras.models import Sequential
from keras.layers import Dense
import numpy as np
np.random.seed(7)
import requests
url = 'https://raw.githubusercontent.com/jbrownlee/Datasets/master/pima-indians-diabetes.data.csv?raw=true'
r = requests.get(url, allow_redirects=True)
open('pima-indians-diabetes.data.csv', 'wb').write(r.content)
dataset = np.loadtxt("pima-indians-diabetes.data.csv", delimiter=",")
X = dataset[:,0:8]
Y = dataset[:,8]
  # create model
model = Sequential()
model.add(Dense(12, input_dim=8, activation='relu'))
model.add(Dense(8, activation='relu'))
model.add(Dense(1, activation='sigmoid'))
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
model.fit(X, Y, epochs=150, batch_size=10)
```
    * Remember that to exit this environment you use `conda deactivate`.
    * You can even configure `jupyter notebook` to allow you to access it remotely, but this is non-trivial.
4. Some further thoughts on `conda`:
    * If you followed the instructions above, the environment content was placed in `~/.conda/envs/tf-env`. You can set this manually.
    * We can ensure that we all get the same environment by creating a file that describes it completely.
```{sh}
conda env export > tf-env.yml
```
    * This can be passed into conda create using `conda create -f tf-env.yml`
	* You can easily run the provided [python script](09.md) as a job, which is the recommended way to get large runs done.
