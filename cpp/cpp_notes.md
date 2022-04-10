# C++ notes


## Custom compare function for custom objects

```cpp
// using custom compare function for custom objects in priority_queue

#include <iostream>
#include <queue>
using namespace std;

struct Node
{
    int a;
    int b;
};

bool compare(const Node &n, const Node &m)
{
    if (n.a < m.a)
        return true;
    else if (n.a == m.a)
    {
        if (n.b < m.b)
            return true;
    }
    return false;
}

priority_queue<Node, vector<Node>, decltype(&compare)> buff(compare);

int main()
{
    Node arr[] = {{2, 3}, {2, 4}, {2, 1}, {3, 1}, {3, 5}, {1, 3}, {1, 4}, {1, 0}};
    for (int i = 0; i < sizeof(arr) / sizeof(arr[0]); i++)
    {
        buff.push(arr[i]);
    }
    while (!buff.empty())
    {
        cout << "{" << buff.top().a << "," << buff.top().b << "}\n";
        buff.pop();
    }
    return 0;
}

/*
OUTPUT -

{3,5}
{3,1}
{2,4}
{2,3}
{2,1}
{1,4}
{1,3}
{1,0}

*/
```


## Optimization: reserve the size of hash table

```cpp
#define SIZE_OF_HASH_TABLE 20000
unordered_map<string, int> mymap;
mymap.reserve(SIZE_OF_HASH_TABLE);
```

This reserves the size of the hash table so that re-hashing doesn't occur for at least till `SIZE_OF_HASH_TABLE` number of elememts. 


