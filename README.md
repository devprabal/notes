# devpogi notes

*My learnings on various subjects.*

## List

- [brave_browser](brave_browser/brave_browser_notes.md)
- [c](c/c_notes.md)
- [clang-format](clang-format/clang-format_notes.md)
- [code_review](code_review/code_review_notes.md)
- [counting-numbers-en-ko-hi](counting-numbers-en-ko-hi/counting-numbers-en-ko-hi_notes.md)
- [cpp](cpp/cpp_notes.md)
- [git](git/git_notes.md)
- [linux](linux/linux_notes.md)
- [my_code_repos](my_code_repos/my_code_repos_notes.md)
- [rpi](rpi/rpi_notes.md)
- [semaphore](semaphore/semaphore_notes.md)
- [vim](vim/vim_notes.md)
- [windows](windows/windows_notes.md)

## How to build this repo?

```bash
docker build -t notes-builder .
docker run --rm -i -v "$PWD":/app notes-builder make
```

## How to add new docs?

Suppose you want to add a new notes dir (say) - `kawaii_tech`.  
Then this dir (`kawaii_tech`) should have the following structure and mandatory files (notice the naming of the files too) -  

    `kawaii_tech/kawaii_tech_notes.md` (your notes in Markdown format)  

Now in the `Makefile` (of the project's root dir) add this dir to `DIRS_UNSORTED` variable

