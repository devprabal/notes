# `clang-format` notes

[clang-format](https://clang.llvm.org/docs/ClangFormat.html) is an auto code formatter. I use it for C/C++ projects.


## Different linux PCs, different `clang-format` versions 

Some options for fomatting specified in `.clang-format` file don't work for versions 10 and below. Most of the linux PCs use Ubuntu which packages this software based on Ubuntu OS version. And even the latest Ubuntu OS version might not include the latest `clang-format` software version. Thus the options in the format file will be *unrecognized* when running on a system which has older `clang-format` software.

**Solution:** docker

I came across a well maintained, frequently updated, permissive Apache 2.0 licensed docker image [xianpengshen/clang-tools](https://hub.docker.com/r/xianpengshen/clang-tools) which has all the latest versions of `clang-format` (versions 17, 18, etc.).


**Format 1 file -**

```bash
docker run --volume $PWD:/src --user $UID xianpengshen/clang-tools:18 clang-format -i list.c
```

Notes -  

- `--volume` -> lets docker to access your filesystem
- `$PWD:/src` -> I don't understand this part
- `--user $UID` -> If you don't specify this then the file after the formatting changes will have changed ownership (that of `root` user). You won't be able to make further changes to the file created as `root` user unless you run `sudo chown [...]`. This option keeps the current user of the system as the owner of the file.
- `xianpengshen/clang-tools:18` -> use version 18 for clang-format from this docker image. It will pull the image if not found on your system. And since we already use tizenrt docker image to build our code, therefore, I assume that docker is already installed and your USER is in docker group or you have sudo rights.
- `-i` -> change the file inplace instead of outputting on stdout.
- Use version 18 to detect `.clang-format-ignore` file. I don't know why but I couldn't achieve it using version 17, although it should be achievable.


**Format all files (`.c`, `.cpp` and `.h`) recursively from current directory -**

```bash
find . -name "*.cpp" -o -name "*.c" -o -name "*.h" | xargs -I {} docker run --volume $PWD:/src --user $UID xianpengshen/clang-tools:17 clang-format -i {}
```

- partially taken from [a blog post](https://learn.adafruit.com/the-well-automated-arduino-library/formatting-with-clang-format)
- partially taken from [stackoverflow](https://stackoverflow.com/questions/74195381/how-to-avoid-changing-ownership-of-every-file-in-a-volume-when-starting-a-docker)


## Local vs on github? (via CI)

The above method is local-only usage. You can do it, but you will often forget it. Therefore, we need a bot to do it. However, it should not do it for all the commits because otherwise it will be hectic to `git pull` everytime after `git push` on one branch. So, I would like to run it only on PRs.

## github 'Actions' workflow bots

- [clang-format-lint](https://github.com/marketplace/actions/clang-format-lint) -> runs clang-format on files
- [add-commit](https://github.com/marketplace/actions/add-commit) -> commits the result

**Sample PR on my public github repo** -  

https://github.com/devprabal/small-linklist/pull/9

In this PR, see the github workflow file, the `.clang-format` file and `.clang-format-ignore` file.


## Pitfalls

- [screen width size - 80 vs 120?](https://stackoverflow.com/questions/578059/studies-on-optimal-code-width)
- [clang-format still doesn't have good support for formatting initialization of elements of an array of struct](https://stackoverflow.com/questions/75802704/clang-format-always-indent-struct-initiallizers)
one workaround this is to mark that code part for skip-formatting -  

```c
// clang-format off
my_struct array[] = { {.member1 = something1, .member2 = something2, }, {.member1 = otherthing1, .member2 = otherthing2, },  };
// clang-format on
```

- [use trailing comma to get array initialization formatting](https://github.com/llvm/llvm-project/issues/61533)

## Unexplored areas

- [git hooks? (formatting when committing)](https://github.com/audiohacked/git-clang-format)
- [Not clang-format? another tool - astyle?](https://astyle.sourceforge.net/)
