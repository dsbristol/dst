---
title: Appendix 4 - Github
layout: coursebook
---

# Git, GitHub, GitHub Desktop

Git 

## Get a GitHub Account and required software

To get going on GitHub you need to:

1. Make an account at [github.com](https://github.com/).
2. For Windows users:
   - Choose a good text editor; [Notepad++](https://notepad-plus-plus.org/downloads/) is good, as is [Atom](https://atom.io/). You should **not** use Notepad (it messes up line endings).
   - Create a working command line, using [Git for Windows](https://gitforwindows.org/).
	 - There are several options it will ask you about. Select your text editor; use the OpenSSL library and "Checkout as-is, commit Unix-style line endings", MinTTY, and other defaults.
3. Install [GitHub Desktop](https://desktop.github.com/). There are many places to look for help, including the very good [GitHub official Docs](https://docs.github.com/en/desktop), and [Desktop-Specific tutorials](https://www.softwaretestinghelp.com/github-desktop-tutorial/) and [Git background](https://swcarpentry.github.io/git-novice/).
4. Set up an [ssh key](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh) and add it to your account. This allows passwordless access and is essential for hassle-free operation.


## Create a Repository for an Assessment

To create an assessment project, one of your team must:

1. Create a [Repository](https://docs.github.com/en/enterprise/2.15/user/articles/create-a-repo) for your project. You can either do this:
   a. Create from [scratch](https://docs.github.com/en/enterprise/2.15/user/articles/create-a-repo);
   b. By [forking](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) a previous repository, such as the [Example Assessment](https://github.com/dsbristol/dst_example_project).
2. Grant read and write access to your group by [Inviting Collaborators](https://docs.github.com/en/github/setting-up-and-managing-your-github-user-account/inviting-collaborators-to-a-personal-repository).
3. Finally, each Group Member then needs to [Add the Repository to their GitHub Desktop](https://docs.github.com/en/desktop/contributing-and-collaborating-using-github-desktop/cloning-a-repository-from-github-to-github-desktop).

## Working on a Project

To use your GitHub Collaboration Space, you need to:

1. Make changes to your project, as you would normally.
2. Press `Fetch Origin` to get any changes to the repository from your collaborators.
3. Resolve and conflicts that arise.
4. Commit your changes to your current branch; typically `Master`, by selecting Changes->Commit to Master. Remember to give a useful description of the changes.
5. `Push Origin` to add your changes to the remote repository for others to fetch.

## Working practices for an easy life

You are free to use the full functionality of GitHub. However, to have an easy experience for non-Git experts, I have the following advise:

1. Always `Fetch Origin` before starting work! This limits the amount of conflicts.
2. Don't worry about [branches](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell). They are very useful but require a strong understanding of git.
3. Instead, structure your work to limit conflicts by:
   a. Having your own `scratch space` - A folder given by your name - that only you edit.
   b. Follow good practice of file naming: use `data/raw` for raw data that is immutable (won't change). Use `data/processed` for transient data, and `data/output` for immutable outputs, should you have them.
   c. Where practical, do not commit intermediate content, but instead commit the code that generates that content and have your Group run your code if they want the content. Make this easy for them!
   d. For your report and for data generation, again minimise conflicts by working on separate files. This will not always be possible so:
	   i) **Plan your work and report structure** together!
	   ii) Where possible, do this synchronously via e.g. Teams and share your screen.
	   iii) Otherwise agree a messaging platform and let everyone know if you are making a change that affects them.
4. Resolve conflicts as they occur and before they get out of hand.

## Conflicts: When things go wrong

Conflicts are inevitable. Some are easy to resolve with [GitHub Desktop](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/resolving-a-merge-conflict-on-github). When things go wrong:

1. Try not to push your edits to master, until you've resolved the problem!
2. Consider if you only need to keep the `Origin` copy, or the `Master`. If so, do.
3. You can always create a backup of your local version, delete the files in question, check them back out, and then merge manually.
   a. I do this by manually copying the files, `checkout <file>` to get the `Master` version of them, then merging with [Meld](https://meldmerge.org/) or [KDiff3](https://invent.kde.org/sdk/kdiff3).
   b. You sometimes need some rather obtuse commands to reset the git repository to the right state.
3. Google the problem. You are not the first!
4. A "nuclear" option exists in creating a second, clean copy of the repository, and manually updating that until it is correct.
5. Some references for issues:
   a. [Atlassian merge conflicts](https://www.atlassian.com/git/tutorials/using-branches/merge-conflicts)
   b. [GitHub Command-line merge conflicts](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/resolving-a-merge-conflict-using-the-command-line)
   c. [Oh Shit, Git](https://ohshitgit.com/)

## Deeper Git

There is no need to use GitHub Desktop; for some things you need **command line git** and it allows you work effectively on a remote server, such as [BlueCrystal](appendix5-bluecrystal.md). There are many resources including:

* [Chrys Woods' Git Tutorial](https://chryswoods.com/beginning_git/index.html) - Chrys provides this tutorial to students and staff at the University of Bristol. I highly recommend going through it to understand Git more deeply.
  * He also covers more advanced usage in [Python and Data](http://chryswoods.com/python_and_data/index.html).
* [swcarpentry](http://swcarpentry.github.io/git-novice/) is another excellent resource with descriptions at several layers of complexity.
  * Which notes that [Rstudio has integrated Git functionality](https://swcarpentry.github.io/git-novice/14-supplemental-rstudio/index.html). You are welcome to use this, but don't become reliant as it will not help you for Python usage.

Some video tutorials:

* [GitHub Desktop Quick Intro For Windows](https://www.youtube.com/watch?v=77W2JSL7-r8)
* [Learn Git in 20 minutes](https://www.youtube.com/watch?v=Y9XZQO1n_7c)

## Command Line Git for Noteable

You **can use Git** when using Jupyter Notebook via Noteable. To do this you need to become familiar with Command Line Git; see the references in **Deeper Git** above. The process is:

[](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)

1. Start **Jupyter Hub** by going to the Data Science Toolbox on **Blackboard** and selecting **Noteable**.
2. Select **"R with Stan"**. This creates an instance that includes **Python 3 and R**. Press **Start**.
3. Select the **"New"** button from the top right and select **"Terminal"**.
4. You are now at a Linux Command Line prompt. You then need to **setup GitHub** to use your GitHub Account:
```{sh}
git config --global user.name "Your Name" # Replace with your name
git config --global user.email "myemail@host.com" # Replace with your GitHub email address
```
5. Now you need to [generate a GitHub Access Token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token). This is like a limited password. You must give this access token the required permissions. I would recommend:
   * Making a token specifically for Noteable, with a suitable name;
   * Allowing full access to the **repo** but nothing else;
   * Saving this access token somewhere secure.
5. You are now ready to **clone your project**. This is done via the `git clone` command. We need to know the repository that you want. Go to [GitHub`](www.github.com), navigate to your project and select **Code**. You need to choose **HTTPS** mode as SSH is not currently supported on Noteable. You can then press the **copy to clipboard icon** to give you a link, which you can past into the command line. You will take the last part of this to make the following command that additionally contains your username and access token:
```{sh}
git clone https://username:accesstoken@github.com/projectuser/project.git
```
for example (with a fake access token):
```{sh}
git clone https://dsbristol:1234123412341234@github.com/dsbristol/dst_example_project.git
```
Remember that:
	* `username` is your own GitHub username;
	* `accesstoken` is the access token you created for this above;
	* `projectuser` is the owner of the project;
	* `project` is the name of the project.

7. You can now make changes and commit them as normal. For example:
```{sh}
cd dst_example_project
emacs README.md ## Make some changes
git status
git add -u
git commit -m "I made some changes from Noteable"
```

### Notes :

* Noteable should be secure enough to store an access token, though some might have concerns about security. If you are worried, you can instead ask it to [cache your password](https://www.phys.uconn.edu/~rozman/Courses/P2200_15F/downloads/github-caching_password_in_git.pdf):
```{sh}
git config --global credential.helper cache
```
* It is possible to modify a Git repository you already created to use your details, a new password, etc. You do this by editing the `.git/config` file in your repository. There are many online resources explaining this.

## Git is Evil! Make it go away!

This is a collaborative process and I am always open to suggestions. If you have a good option, discuss it with me.

I can imagine a few options:

* OneDrive/GoogleDrive/Dropbox: None of these are designed for co-creation of content alone. You will have a miserable experience.
* [Google Colab](colab.research.google.com/) or [alternatives](https://www.kaggle.com/getting-started/99185), specifically that let all collaborators edit the same document, live. All of these options should support dumping your project into a GitHub Repository, so feel free to try.
* We expect a better collaboration tool to be provided by the University soon. 
