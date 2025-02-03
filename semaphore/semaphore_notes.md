# Understanding semaphore, mutex and condition variable 

> in producer consumer scenario

## Read the manual pages

```txt
SEM_INIT(3)                                   Linux Programmer's Manual                                   SEM_INIT(3)

NAME
       sem_init - initialize an unnamed semaphore

SYNOPSIS
       #include <semaphore.h>

       int sem_init(sem_t *sem, int pshared, unsigned int value);

       Link with -pthread.

DESCRIPTION
       sem_init()  initializes  the unnamed semaphore at the address pointed to by sem.  The value argument specifies
       the initial value for the semaphore.

       The pshared argument indicates whether this semaphore is to be shared between the threads of a process, or be‐
       tween processes.

       If  pshared  has the value 0, then the semaphore is shared between the threads of a process, and should be lo‐
       cated at some address that is visible to all threads (e.g., a global variable, or a variable allocated dynami‐
       cally on the heap).

       If  pshared  is  nonzero, then the semaphore is shared between processes, and should be located in a region of
       shared memory (see shm_open(3), mmap(2), and shmget(2)).  (Since a child created by fork(2) inherits its  par‐
       ent's  memory  mappings, it can also access the semaphore.)  Any process that can access the shared memory re‐
       gion can operate on the semaphore using sem_post(3), sem_wait(3), and so on.

       Initializing a semaphore that has already been initialized results in undefined behavior.

RETURN VALUE
       sem_init() returns 0 on success; on error, -1 is returned, and errno is set to indicate the error.

ERRORS
       EINVAL value exceeds SEM_VALUE_MAX.
```


## Understand more by [chats with Claude AI](https://claude.ai/chat/2ca255f1-2caf-45b3-8c02-3b4d3c8b4cfe)

Excerpts 

- A semaphore is a synchronization primitive used in concurrent programming to control access to shared resources. Think of it like a pool of permits - threads must acquire a permit before accessing the resource and release it when done.

```python
from threading import Semaphore
# Create a semaphore with 3 permits
printer_sem = Semaphore(3)
```

- In this example, the semaphore controls access to printers. Only 3 threads can print simultaneously - if a 4th thread tries to print, it will be blocked until one of the active threads releases its permit.
- They maintain a counter that gets decremented on acquire() and incremented on release()
- If the counter is zero, acquire() blocks until another thread calls release()
- They're commonly used for resource pools, producer-consumer scenarios, and limiting concurrency, where you don't care which thread accesses the resource, just how many can access it simultaneously.

## Binary mutex vs Semaphore

- The three acquire() calls will all succeed because there were initially 3 permits available. The fourth call would block (wait indefinitely) because there are no permits left. The thread would only continue when another thread calls release() to return a permit to the semaphore. This is one of the key differences between semaphores and locks/mutexes - **you can acquire a semaphore multiple times (up to its initial value) without releasing in between**, whereas with a lock you can only acquire it once before needing to release it.
- Unlike mutexes which are binary (locked/unlocked), **semaphores can allow multiple threads to access the resource simultaneously.**

## Re-entrant mutex vs Semaphore

- **A reentrant mutex (also called a recursive mutex) in C allows the same thread to lock the mutex multiple times** without deadlocking. This is different from a regular mutex, which would deadlock if the same thread tried to lock it twice without an intervening unlock.
- Reentrant mutex: The thread **must release the lock the same number of times** it acquired it
- **In case of reentrant mutex, other threads still cannot acquire the lock while it's held**
- Reentrant mutex: The mutex keeps a count of how many times it's been locked
- **Reentrant mutex: useful for recursive algorithms** or when functions that lock the mutex might call each other
- Differences b/w reentrant mutex and semaphore

| Basis             | Reentrant mutex                                                                                  | Semaphore                                                                                 |
|-------------------|--------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| Owner tracking    | Reentrant mutex remembers which thread owns it and only allows that same thread to re-acquire it | Semaphore doesn't track ownership - any thread can take available permits                 |
| Release behavior  | Reentrant mutex must be unlocked by the same thread that locked it                               | Semaphore's release() can be called by any thread, not just the one that called acquire() |
| Counter semantics | Reentrant mutex's counter tracks how many times the owning thread has locked it                  | Semaphore's counter tracks how many total permits are available to any thread             |

- There are two main ways to create a semaphore:
    - Named Semaphores (sys V style) using `sem_open()`
    - Unnamed Semaphores (process-private) using `sem_init()`
- The key difference is that **named semaphores persist in the system and can be accessed by different processes using the same name**, while unnamed semaphores exist only in memory and are typically used between threads or related processes that can share memory
- What's the initial value in sem_init? Does it tell us how many permits are allowed? Yes, **the initial value in sem_init specifies exactly how many permits are initially available** in the semaphore. It's like pre-loading the semaphore with that many "tokens" or "permits".

## Condition variable vs Semaphore | [chats with Claude AI](https://claude.ai/chat/b25438ff-a2c3-4905-8e25-0720ca6b6926)

**Version 1 | my code**
> My version 1 of reactor pattern code blocks if I send the events in succession without `sleep` in between. See commit [9fc755b042163a33a006ef893b22c475dace0a82](https://github.com/devprabal/reactor/commit/9fc755b042163a33a006ef893b22c475dace0a82)

```c
bool reactor_send(ReactorEvent event)
{
    mtx_lock(&queue_lock);
    if(q_idx >= 10) {
        for(int i = 1; i < 10; i++){
            //// drop the earliest event
            simple_queue[i-1] = simple_queue[i];
        }
        q_idx = 9;
    }
    simple_queue[q_idx] = event;
    q_idx++;
    mtx_unlock(&queue_lock);
    mtx_unlock(&event_lock);
    return true;
}

int task_function(void* arg)
{
    while(task_run_status) {
        DBG;
        mtx_lock(&event_lock);
        if(task_run_status == false) {
            break;
        }
        mtx_lock(&queue_lock);
        if(q_idx > 0) {
            ReactorEvent event = simple_queue[0];
            for(int i = 1; i < q_idx; i++){
                simple_queue[i-1] = simple_queue[i];
            }
            q_idx--;
            DBG;
            printf("\nPrabal's debug: event data = %s\n", event.data);
        }
        mtx_unlock(&queue_lock);
    }
    return 0;
}

```

**Version 2 | by AI**

- Improved synchronization using cond variable for efficient event notification
- Removed the problematic event_lock
- Consumer thread now sleeps when queue is empty


```c
bool reactor_send(ReactorEvent event) {
    mtx_lock(&queue_lock);
    bool result = enqueue_event(&event_queue, event);
    cnd_signal(&queue_cond);
    mtx_unlock(&queue_lock);
    return result;
}

int task_function(void* arg) {
    while (task_run_status) {
        ReactorEvent event;
        bool has_event = false;
        
        mtx_lock(&queue_lock);
        while (queue_is_empty(&event_queue) && task_run_status) {
            cnd_wait(&queue_cond, &queue_lock);
        }
        
        if (task_run_status) {
            has_event = dequeue_event(&event_queue, &event);
        }
        mtx_unlock(&queue_lock);
        
        if (has_event) {
            printf("\nProcessing event: %s\n", event.data);
        }
    }
    return 0;
}
```

**Version 3 | by AI**

- Can we not use semaphore to signal instead of conditional variable?
- Yes, we can use semaphores instead of condition variables. **Semaphores are particularly well-suited for this producer-consumer scenario**. 

```c
bool reactor_send(ReactorEvent event) {
    mtx_lock(&queue_lock);
    bool result = enqueue_event(&event_queue, event);
    mtx_unlock(&queue_lock);
    
    // Signal that new event is available
    if (result) {
        sem_post(&queue_sem);
    }
    return result;
}

int task_function(void* arg) {
    while (task_run_status) {
        ReactorEvent event;
        bool has_event = false;
        
        // Wait for event to be available
        if (sem_wait(&queue_sem) != 0) {
            // Handle error
            continue;
        }
        
        if (!task_run_status) {
            break;
        }
        
        mtx_lock(&queue_lock);
        has_event = dequeue_event(&event_queue, &event);
        mtx_unlock(&queue_lock);
        
        if (has_event) {
            printf("\nProcessing event: %s\n", event.data);
        }
    }
    return 0;
}
```
- Semaphores naturally fit the producer-consumer pattern
- No need for explicit condition checking in a while loop
- `sem_wait()` automatically blocks until an event is available
- `sem_post()` signals the availability of new events
- Less lock contention since mutex is only held for queue operations
- **No spurious wakeups compared to condition variables**
- It's a counting semaphore, so it keeps track of exactly how many events are available
