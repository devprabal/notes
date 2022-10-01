# Git Notes


## Common commands

```git
git help <command>
git help branch

git config --global core.autocrlf input

git show HEAD
git show HEAD^
git show HEAD~
git show HEAD~3
git show ed23ab

git ls-tree HEAD
git ls-tree HEAD^
git ls-tree HEAD mydir/

git log --author="prabal"
git log --grep="notes"
git log small-linklist/src/
git log 3ed12f..HEAD

git log --oneline --decorate --graph --all

git diff master..other_branch
git diff other_branch..master
git diff 63d2344..52acfe2
git diff
```

`git log -p`  
shows all (diff) what was changed in each of the commits, `p` (patch)  

`git log --stat`  
show only which files changed in all commits  

`git log -3 --stat`  
shows only which files changed in the previous 3 commits  

`git show 1efdff small-linklist/src/node.c`  
shows what was changed in this file in this commit id  

`git branch`  
list of branches  

`git branch <new_branch_name>`  
creates a new branch from the tip of the current branch, but does not switch to it  

`git checkout <pre_existing_branch_name>`  
switches to that branch  

`git checkout -b <new_branch_name>`  
creates a new branch (from the tip of the current branch) and switches to it.  

The **HEAD** is a pointer pointing to the place (commit) from where new commits will be made.  

`cat .git/HEAD` can be used to show the branch which the HEAD points to now.   

`ls -la .git/refs/heads` can be used to show what all branches the **HEAD** has the reference of.  
The directory contains a listing of all te branches -   

```bash
devp@IdeaPad:/mnt/d/github/small-linklist$ ls -la .git/refs/heads

total 0 
drwxrwxrwx 1 devp devp 4096 Apr 30 13:35 .
drwxrwxrwx 1 devp devp 4096 Apr 30 13:35 ..
-rwxrwxrwx 1 devp devp   41 Apr 30 13:35 main
```

The contents of each of these files is the commit to which the **HEAD** would point when switched to that branch.  

```bash
devp@IdeaPad:/mnt/d/github/small-linklist$ cat .git/refs/heads/main

89810c8b078dfa35872a6617bc5a2e22a6ee5deb 

devp@IdeaPad:/mnt/d/github/small-linklist$ git log -1

commit 89810c8b078dfa35872a6617bc5a2e22a6ee5deb (HEAD -> main, origin/main, origin/HEAD)
Author: devprabal <ghjxvnjd@gmail.com>
Date:   Fri Apr 29 22:45:37 2022 +0530

    init gcov, lcov support
```

If there are uncommit changes in a branch and we are trying to switch to another branch, then we can switch if the changes are untracked or if the changes do not conflict. Else, we will need to either commit changes, discard the changes (`git checkout --` those files), or `git stash` those files.  

`git branch --merged`  
shows that this branch already has the commits of which other branches  

`git branch --no-merged`  


`git branch -m <new_branch_name>`   
changes (or moves) the currently checked-out branch to a new name.  
CAUTION: may cause extra workarounds when other users are already working on the old name of branch.  

`git branch -d <branch_to_delete>`  
First, checkout to another branch before deleting this branch. This command will complain if the changes are not merged in any other branch (`-D` to force delete).  
Returns the HEAD commit-id of the deleted branch.  


## configure PS1

```bash
export PS1='\w $(tput setaf 3)$(__git_ps1 "(%s)") $(tput sgr0)> '
```

`__git_ps1` is a fuction provided by `git-prompt.sh` file which can be found at [github.com/git](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh)  

[git-completion.bash](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash) file can also be installed similarly.  


## Create a branch using git command line

First, you must create your branch locally  

```git
git checkout -b your_branch
```

After that, you can work locally in your branch. When you are ready to share the branch, push it. The next command pushes the branch to the remote repository origin and tracks it.  

```git
git push -u origin your_branch
```

Teammates can reach your branch by doing:  

```git
git fetch
git chekcout origin/your_branch
```

You can continue working in the branch and pushing whenever you want without passing arguments to git push (argument-less git push will push the local `master` to remote `master`, local `your_branch` to remote `your_branch`, etc.)  

[stackoverflow: how-do-i-create-a-remote-git-branch](https://stackoverflow.com/questions/1519006/how-do-i-create-a-remote-git-branch)  


## `bash \r not found`

Change git core autocrlf to input and re-clone the repo.  

[stackoverflow: env-bash-r-no-such-file-or-directory](https://stackoverflow.com/questions/29045140/env-bash-r-no-such-file-or-directory)  


## Line endings CRLF and LF

If the project is cloned on linux (LF) server and we open it to edit in VSCode on Windows (CRLF), then we might do -   

```git
git config --global core.autocrlf true
```

in both git bash (Windows) and on linux build server.  

If you want to know what file this config is saved in, you can run the command:  `git config --global --edit`  

[stackoverflow: how-to-change-line-ending-settings](https://stackoverflow.com/questions/10418975/how-to-change-line-ending-settings)  


## Checkout a github PR locally to test/edit/resolve-merge-conflicts

```git
git fetch origin pull/<PR_ID>/head:<new_branch_name>
```

Then checkout to `new_branch_name`  

[stackoverflow: how-can-i-check-out-a-github-pull-request-with-git](https://stackoverflow.com/questions/27567846/how-can-i-check-out-a-github-pull-request-with-git)  


## Pusing a local branch to remote

```git
git push -u origin <new_branch_name>
```


## Moving histories from one repo to another

Problem:   
There is a new repo B and an old repo A. I want to have all commits from A into B preserving the commit history (`git log` should show me commit history)  

Solution:   
- Go into B ('git clone git@github.com: devpogi/B.git`)  
- `git checkout B_new_branchname`  
- Add remote for repo A (`git remote add repAorigin git@github.com:devpogi/A.git`)  
- `git fetch repoAorigin`  
- `git merge repoAorigin/master --allow-unrelated-histories`  
- Might introduce a merge conflict  
- Resolve the conflict and make a commit   
- `git push`  

[stackoverflow: moving-git-repository-content-to-another-repository-preserving-history](https://stackoverflow.com/questions/17371150/moving-git-repository-content-to-another-repository-preserving-history)  

[stackoverflow: how-to-handle-fix-git-add-add-conflicts](https://stackoverflow.com/questions/19475387/how-to-handle-fix-git-add-add-conflicts)  


## `git patch`

If you haven't yet committed the changed, then:  

```git
git diff > mychanges.patch
```

But it might be possible that there are several untracked (new) files which won't be in your git diff output. So, one way to do a patch is to stage everything for a new commit (`git add` each file, or just `git add .`) but don't do the commit yet, and then run:  

```git
git diff --cached > mychanges.patch
```

You can later apply the patch as:  

```git
git paply mychanges.patch
```

[blogpost: create-a-git-patch-from-the-uncommitted-changes-in-the-current-working-directory](https://newbedev.com/create-a-git-patch-from-the-uncommitted-changes-in-the-current-working-directory)  


## Patch files

If you need to send the patch file via mail, there is a better built-in way to do this in git using `git format-patch` command.  

The patch file generated will include subject, author, etc, additional information traditionally used in UNIX-like mail-patching.  

If you need top `n` commits from a specific commit-sha in the patch file - `git format-patch -n commit-sha`  

example -   
```git
git format-patch -1 HEAD
```

This will generate a file like `0001-commit-message.patch`  

To apply this patch, use a series of steps -   
- `git apply --stat 0001-commit-message.patch` (*shows stats*)  
- `git apply --check 0001-commit-message.patch` (*checks for error before applying*)  
- `git am < 0001-commit-message.patch` (*applies the patch, you will see the commit appear in `git log`*)  
