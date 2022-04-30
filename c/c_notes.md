# C notes


## What happens when you have the same function name in two different files and one of them in not `static` ?

You might get a linking error saying that there are multiple definitions for that function. You can also see where the function was first defined in the compiler logs.


## Compile C using visual studio compiler on windows

Open developer command prompt (which gets installed as a part of Visual Studio).

```powershell
type> cl
type> cl main.c
type> main
```

[MSVC: walkthrough-compile-a-c-program-on-the-command-line](https://docs.microsoft.com/en-us/cpp/build/walkthrough-compile-a-c-program-on-the-command-line?view=msvc-170)


## A better way to write comparison statements

`(NULL == ptr)` instead of `(ptr == NULL)`

I remember one exam in which I had spent half an hour to spot this assignment instead of comparison error.  

People might forget to put `!` (or the extra `=` for equality, which is more difficult to spot) and do an assignment instead of a comparison.  

Putting the `NULL` in front eliminates the possiblity for the bug, since `NULL` is not a l-value (i.e. it can't be assigned to).


## Few ways to implement a function like `insertAtBeginningOfLinkedList()`

- If the head pointer is a global variable (i.e. accessible to all functions), we can just update that global variable and we don't need to either pass or return from the function.
- If the head pointer is not a global variable, then we should pass the head pointer in the function and also return the updated head pointer, as -
      - `head = insertAtBeginningOfLinkedList(head, data)`
- We can also pass the head pointer by reference and then we don't have to return the updated head, as - 
      -  `insertAtBeginningOfLinkedList(Node **head, int data)`
      -  since head (in `main()`) is already a pointer to `Node`, passing by reference can also be like `insertAtBeginningOfLinkedList(&head, data)`
      -  In order to get the head, we have to dereference it as `*head`, example, `if (*head != NULL) temp->next = *head;`


## Initialization of `struct`

If the data is a static or global variable, it is zero-filled by default, so just declare it `myStruct _m;`.  

If the data is a local variable or a heap-allocated zone, clear it with memset as:  

`memset(&_m, 0, sizeof(myStruct));`

Using `memset` for local structures is better, and it conveys better the fact that at runtime, something has to be done (while usually, global and static data can be understood as initialized at compile time, without any cost at runtime).  

` = {} ;` empty braces for initialization is a GNU extension.  

Note that in C99, a new way of initialization, called designated initialization can be used too:  

`myStruct _m1 = {.c2 = 0, .c1 = 1};`  


[stackoverflow: initializing-a-struct-to-0](https://stackoverflow.com/questions/11152160/initializing-a-struct-to-0)  


## Caution using `memset` to initialize: You can't `memset` an array correctly which is of the type other than 1 byte

```c
#include <stdio.h>
#include <string.h>

typedef enum
{
    ON,
    OFF,
    NONE,
    _AAA,
    _AAB,
    _AAC,
} MYENUM;

static MYENUM MyList[2][4];

int main(void)
{
    for (int i = 0; i < 4; i++)
    {
        printf("\n%d\n", MyList[0][i]);
    }
    memset(MyList[0], NONE, sizeof(MyList[0][0]) * 4);
    for (int i = 0; i < 4; i++)
    {
        printf("\n%d\n", MyList[0][i]);
    }
    printf("\n%d\n", sizeof(MYENUM));
    printf("\n%d\n", NONE);
    return 0;
}

/*
OUTPUT -


0

0

0

0

33686018

33686018

33686018

33686018

4

2

*/
```

`memset()` will set **each byte** to `NONE` (2) instead of **every 4 bytes**.  

`MYENUM` will be 4 bytes. So `MyList[0][0]` will be `0x02020202` instead of `0x00000002`.  

We should therefore, use a `for` loop if we want to set a non-zero value.  

[stackoverflow: memset-enum-array-values-not-setting-correctly-c](https://stackoverflow.com/questions/21357038/memset-enum-array-values-not-setting-correctly-c-c/21357071#21357071)  

Usually, it gives correct result if setting zero value.  

```c

#include <stdio.h>
#include <string.h>

int main(void)
{
    size_t bbb[3] = {2, 4, 5};
    memset(bbb, 0, sizeof(size_t));

    printf("sizeof size_t %d\n", sizeof(size_t));
    printf("sizeof bbb %d\n", sizeof(bbb));
    printf("%d\n", bbb[0]);
    printf("%d\n", bbb[1]);
    printf("%d\n", bbb[2]);
    printf("\n**************\n");

    memset(bbb, 0, sizeof(bbb));
    printf("%d\n", bbb[0]);
    printf("%d\n", bbb[1]);
    printf("%d\n", bbb[2]);

    return 0;
}

/*
OUTPUT -

sizeof size_t 8
sizeof bbb 24
0
4
5

**************
0
0
0

*/
```


## `memset`, `memcpy` and `memcmp`

`memcpy()` copies from one place to another. `memset()` just sets all pieces of memory to the same value.  

Example:  

`memset(str, '*', 50);`  

The above line sets the first 50 characters of the string str to `*` (or whatever the second argument of the `memset`).  

`memcpy(str2, str1, 50);`  

The above line copies the first 50 characters of `str1` to `str2`.  

It's worth pointing out that the `mem*()` functions do not know about string terminators. The second example above will do bad things if `str1` is shorter than 50 characters. It's only safe to use `mem*()` functions on string data when you have already validated the lengths involved.  

`memcmp()` (compares two blocks of memory) is in `<string.h>` in C. Use `man memcmp` (on terminal) to read description and to find in which header file it is declared.  

[stackoverflow: what-is-the-difference-between-memset-and-memcpy-in-c](https://stackoverflow.com/questions/1536006/what-is-the-difference-between-memset-and-memcpy-in-c) 


## Freeing a `NULL` pointer

The `free()` function cause the space pointed to by pointer `ptr` to be deallocated, that is, made available for further allocations. If the `ptr` is a `NULL` pointer, no action occurs.  

`ptr = NULL` ensures that even if you accidently call `free(ptr)`, your program won't segfault.  

This also means that there is no need to put `NULL` check before `free`ing, something like -

`if (ptr != NULL) free(ptr);` 

But once the `ptr` has been freed, it is a good practice to set `ptr = NULL`. So that you don't fall in the risk of double-freeing or dangling pointer access.  

Please note that although the C standard says it is a no-op, that doesn't mean that every C library handles it like that. There could be crashes for `free(NULL)`, so it's best to avoid calling the `free()` on a pointer which has been set to `NULL`.  

[stackoverflow: does-freeptr-where-ptr-is-null-corrupt-memory](https://stackoverflow.com/questions/1938735/does-freeptr-where-ptr-is-null-corrupt-memory)  


## Type casting for freeing

```c
const char *a = (const char *)malloc(3);
free(a); // this will be a warning
```

```plaintext
warning: passing argument 1 of 'free' discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
   31 |     free(a); // this will be a warning
      |          ^
In file included from <source>:3:
/usr/include/stdlib.h:565:25: note: expected 'void *' but argument is of type 'const char *'
  565 | extern void free (void *__ptr) __THROW;
```

Basically a C language problem. The signature of `free()` should have been `void free(const void *);`. Fixed in C++ with `delete`. You need to cast it to a non-const pointer; `free` takes a `void *`, not a `const void *`.  

`free(char *(a));`


## Hex, ASCII and decimal

```c
#include <stdio.h>
#include <string.h>

int main(void)
{
    char a[] = {0x42, 0x31, 0x30, 0x32};
    if(a[3] == '2')
    {
        printf("hex 0x32 is ascii '2', both of which are represented as the same char value\n");
    }
    printf("%s\n", a);
    if(0xff == 0xFF)
    {
        printf("true\n");
    }
    return 0;
}

/*
OUTPUT -

hex 0x32 is ascii '2', both of which are represented as the same char value
B102
true

*/
```


## Clockwise spiral rule

`const char *x`, x is a pointer to `const char`. The pointer can change but the contents of the thing (C-style string) being pointed to can not be changed.  

`char * const x`, x is a pointer to a `char`. The pointer can not be changed, the contents of the string can be changed. In other words, you can change the actual char, but not the pointer pointing to it.  

`const char *p` is a pointer to a `const char`.  
`char const *p` is a pointer to a `char const`.  

Since `const char` and `char const` are the same, it's the same thing.  `const` will apply to the symbol left of it, if there is none, then, to the symbol right to it.  

[David Anderson: Clockwise/Spiral Rule](http://c-faq.com/decl/spiral.anderson.html)  


## Free the variable that you are passing to a function that internally does `strdup`

`strdup()` will `malloc` a memory and reuturn the pointer of that (where it also copies the supplied C-style string). So, it is the responsibility of the caller function to `free` this memory after use.  


## Measuring C programs runtime on linux

```bash
$ time ./a.out
real    0m0.003s
user    0m0.000s
sys     0m0.004s
$
```

- Real, User and Sys process time statistics.
- One of these things is not like the other. Real refers to actual elapsed time. User and Sys refer to CPU time used only by the process.
- **Real** is wall clock time - time from start to finish of the call. This is all elapsed time including time slices used by other processes and time the process spends blocked (for example if it is waiting for I/O to complete).
- **User** is the amount of CPU time spent in user-mode code (outside the kernel) within the process. This is only actual CPU time used in executing the process. Other processes and time the process spends blocked do not count towards this figure.
- **Sys** is the amount of CPU time spent in the kernel within the process. This means executing CPU time spent in system calls within the kernel, as opposed to library code, which is still running in user-space. Like 'user', this is only CPU time used by the process. 
- **User+Sys** will tell you how much actual CPU time your process used. Note that this is across all CPUs, so if the process has multiple threads (and this process is running on a computer with more than one processor) it could potentially exceed the wall clock time reported by Real (which usually occurs). Note that in the output these figures include the User and Sys time of all child processes (and their descendants) as well when they could have been collected, e.g., by wait(2) or waitpid(2), although the underlying system calls return the statistics for the process and its children separately.  

[stackoverflow: what-do-real-user-and-sys-mean-in-the-output-of-time](https://stackoverflow.com/questions/556405/what-do-real-user-and-sys-mean-in-the-output-of-time1)  


## Variadic

```c
#include <stdio.h>
#include <stdarg.h>

int sum(int, ...);

int main(void)
{
    printf("Sum of 10, 20 and 30 = %d\n", sum(3, 10, 20, 30));
    printf("Sum of 4, 20, 25 and 30 = %d\n", sum(4, 4, 20, 25, 30));
    return 0;
}

int sum(int num_args, ...)
{
    int val = 0;
    va_list ap;
    int i;

    va_start(ap, num_args);
    for (i = 0; i < num_args; i++)
    {
        val += va_arg(ap, int);
    }
    va_end(ap);

    return val;
}

/*
OUTPUT -

Sum of 10, 20 and 30 = 60
Sum of 4, 20, 25 and 30 = 79

*/
```

The C library macro `void va_start(va_list ap, last_arg)` initializes `ap` variable to be used with the `va_arg` and `va_end` macros. The `last_arg` is the last known fixed argument being passed to the function i.e. the argument before the ellipsis. This macro must be called before using `va_arg` and `va_end`.  

Following is the declaration for `va_start()` macro.  

```c
void va_start(va_list ap, last_arg);
```

`ap` - This is the object of `va_list` and it will hold the information needed to retrieve the additional arguments with `va_arg`.  


## Function overloading not in C, cannot set default value for last parameter in function def in C

C does not allow default value to be set for a parameter(last parameter) in a function. However, there is a trick to achieve the same for on parameter using variadic function. Write a varargs function and manually fill in default values for arguments which the caller doesn't pass.  

Also, ther is no function overloading in C (but it is supported in Modern C, see C11).


## Printing byte (hex) values

```c
#include <stdio.h>
#include <string.h> // for memcmp

int main(void)
{
    char buff[3] = { 0, };
    snprintf(buff, 3, "%d", 10);
    printf("%s", buff);

    unsigned char *a = "\xF0";
    unsigned char b = 0xF0;

    if (memcmp(a, (unsigned char *)"\xF0", sizeof(unsigned char)) == 0)
    {
        printf("\nworks");
    }
    printf("\n%02X", b);
    printf("\n%02X", a);
    printf("\n%02X", a[0]);
    return 0;
}

/*
OUTPUT -

10
works
F0
40200A
F0

*/
```


## `char []` and `char *`

```c
#include <stdio.h>

int main(void)
{
    char a[] = "abcdefghij";

    printf("\nsizeof(a) = %d", sizeof(a));

    char *b = "abcdefghij";
    printf("\nsizeof(b) = %d", sizeof(b));
    printf("\nb[0] = '%c'", b[0]);
    printf("\nsizeof(b)/sizeof(b[0]) = %d", sizeof(b) / sizeof(b[0]));

    return 0;
}

/*
OUTPUT -

sizeof(a) = 11
sizeof(b) = 8
b[0] = 'a'
sizeof(b)/sizeof(b[0]) = 8

*/
```


## Checking memleak with `valgrind`

The below program (filename: strdup_memleak.c) is free of mem-leak.

```c
#include <stdio.h>
#include <string.h>
#include <malloc.h>

int main(void)
{
    char **arr = (char **)calloc(3, sizeof(char *));
    printf("\n%ld sizeof char *\n", sizeof(char *));

    arr[0] = strdup("apple");
    arr[1] = strdup("bye");
    arr[2] = "jo";

    free(arr[0]);
    free(arr[1]);
    free(arr);

    return 0;
}

/*
OUTPUT and method to run -

devpogi@Pavilion Downloads]$ gcc strdup_memleak.c 
[devpogi@Pavilion Downloads]$ ./a.out 

8 sizeof char *
[devpogi@Pavilion Downloads]$ valgrind --leak-check=yes ./a.out 
==13263== Memcheck, a memory error detector
==13263== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==13263== Using Valgrind-3.18.1 and LibVEX; rerun with -h for copyright info
==13263== Command: ./a.out
==13263== 

8 sizeof char *
==13263== 
==13263== HEAP SUMMARY:
==13263==     in use at exit: 0 bytes in 0 blocks
==13263==   total heap usage: 4 allocs, 4 frees, 1,058 bytes allocated
==13263== 
==13263== All heap blocks were freed -- no leaks are possible
==13263== 
==13263== For lists of detected and suppressed errors, rerun with: -s
==13263== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
[devpogi@Pavilion Downloads]$ 

*/

```


## libcheck header file and its compiled src file on linux

```bash
[devpogi@Pavilion ~]$ sudo pacman -S check

[devpogi@Pavilion ~]$ cd /usr/lib
[devpogi@Pavilion lib]$ ls | grep check
libcheck.so
libcheck.so.0
libcheck.so.0.15.2
[devpogi@Pavilion lib]$ 
[devpogi@Pavilion lib]$ cd ../include/
[devpogi@Pavilion include]$ pwd
/usr/include
[devpogi@Pavilion include]$ ls | grep check
check.h
[devpogi@Pavilion include]$ 

```

[stackoverflow: how-to-determine-if-platform-library-is-static-or-dynamic-from-autotools](https://stackoverflow.com/questions/45417496/how-to-determine-if-platform-library-is-static-or-dynamic-from-autotools)  


## `switch` only works on integral values, not pointers

```plaintest
error: switch quantity not an integer
error: pointers are not permitted as case values
```

`switch` statements operate on integral values only. That's why the error message is "switch quantity not an integer". It's not a technical limitation so much as it's outside the language syntax.  

`switch` is a generalization of a jump table. Jump tables are indexed with integers, not pointers. If your case labels are too spread out the compiler probably converts most or all of them to if/else. There's no benefit from using switch/case with non-integral labels instead of if/else.  

[stackoverflow: why-no-switch-on-pointers](https://stackoverflow.com/questions/2308323/why-no-switch-on-pointers)  


## Error: dereferencing pointer to incomplete type

```c
generic_linkedlist_node *hhhead = generic_linkedlist_get_head_node(generic_linkedlist_instance_obj);
// --snip--
if(hhhead)
{
    free(hhhead->data);
    /*
     * One of my functions calloc'ed it so I will have to free it.
     * It is not the responsibility of generic_linkedlist functions to free it.
     * The above line will show error dereferencing pointer to incomplete type 
     * because the compiler only knows that generic_linkedlist_node is a struct 
     * (typedef'ed in one of the generic_linkedlist header files).
     * Since the members of generic_linkedlist_node struct are "defined" 
     * in .c file and we include only the .h fle, 
     * so compiler won't have any account of 
     * what data members are present in generic_linkedlist_node.
     */
}
```

**NOTE: whoever allocates a memory should free it. It is not the responsibility of some other function to free. If one of "your" functions allocated it, then same/another of "your" functions should deallocate it.**  

Either define the `struct` (not just `typedef` it) in the `.h` file or have some methods in the `.c` file to return the data members.  

```c
static void myfunc(generic_linkedlist_node *node, void *arg)
{
    cstm_st_type *dddata = (cstm_st_type *)generic_linkedlist_get_data(node);
    
    /* hhhead->data is of generic void * type when the library function returns, 
     * but since we calloc'ed it as cstm_st_type, we type cast into it.
     */

    free(dddata->info);
    /* dddata->info was also calloc'ed from one of my functions.
     */

    free(dddata);
    /* dddata was also calloc'ed from one of my functions.
     */
}

generic_linkedlist_node *hhhead = generic_linkedlist_get_head_node(generic_linkedlist_instance_obj);
if(hhhead)
{
    generic_linkedlist_iterate_node(generic_linkedlist_instance_obj, hhhead, myfunc, NULL); 
    
    // second last argument is a callback function
    // last argument is the arguments passed to callback func
}
```


## `strcmp()` and `strncmp()`

```c
#include <stdio.h>
#include <string.h>

int main(void)
{
    char *a = "1";
    char *b = "150";
    if (strncmp(a, b, strlen(a)) == 0)
    {
        printf("WRONG ANSWER! The strings are not equal\n");
        printf("string a can be a substring of string b\n");
        printf("third arg should be the greater of two str len\n");
    }
    if (strcmp(a, b) == 0)
    {
        printf("CORRECT ANSWER!\n");
    }
    return 0;
}

/*
OUTPUT -

WRONG ANSWER! The strings are not equal
string a can be a substring of string b
third arg should be the greater of two str len

*/
```

Therefore, we should compare till `max(strlen(a), strlen(b))` .


## Why `typedef` can not be used with `static` ?

For example, the code below gives an error -   

`typedef static int INT2;`  


The static `keyword` is not part of the type, depending on the context it is a storage or scope specifier and has no influence whatsoever on the type. Therefore, it cannot be used as part of the type definition, which is why it is invalid here.  

A `typedef` is a type definition, i.e. you're saying 'this name' now refers to 'this type', the name you give must be an identifier as defined by the language standard, the type has to be a type specifier, i.e. an already named type, either base type or `typedef`'ed, a `struct`, `union`, or `enum` specifier, with possible type qualifiers, i.e. `const`, or `volatile`.  

The `static` keyword however does not change the type, it says something about the object, (in general, not in the OOP sense), example, it is a variable that is placed in the static storage, not the type.  

[stackoverflow: why-typedef-can-not-be-used-with-static](https://stackoverflow.com/questions/2218435/why-typedef-can-not-be-used-with-static)  


## Empty string

```c
#include <stdio.h>
#include <string.h>

int main(void)
{
    char *a = "";
    printf("%d\n", strlen(a));
    printf("%s_SUFFIX\n", a);
    return 0;
}

/*
OUTPUT -

0
_SUFFIX

*/
```


## Variably modified array at file scope

```c
#include <stdio.h>
#define N_VALS sizeof(values)/sizeof(values[0])
static int values[] = {1, 2 , 4, 5, 7};

static int n_values = sizeof(values)/sizeof(values[0]);

static int new_values[N_VALS];

static int other_values[n_values];

int main(int argc, char *argv[])
{
        return 0;
}

/* COMPILE ERROR

error: variably modified 'other_values' at file scope
    9 | static int other_values[n_values];
*/

```

The problem is for `other_values` not `new_values`. `sizeof` is calculated at compile time, but the value of the `n_values` is evaluated at the run time.

So if `a= 5;` then the value of `a` is evaluated at runtime?
Or the compiler substitutes it everywhere beforehand?
If it's not removed by the optimization phase of the compiler, yes it is evaluated at the runtime.
That means we shouldn't take that for granted. We can assume it is evaluated at runtime.


