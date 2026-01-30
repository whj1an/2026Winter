# CSI 2120A Notes, 2026Winter

Course code: CSI 2120 A00
Start Data: Jan 12, 2026
Note author: Jace Wang, *Uottawa*

## Assignments

### Assignment 1

#### Question 1 [ 4 Points ]

The following program computes the sum of the squares of a series of numbers in parallel, but it lacks the synchronization mechanisms to ensure a correct result. Use WaitGroup and Mutex to add the required synchronization

> 以下程序以并行方式计算一组数字的平方和，但由于缺少同步机制，计算结果可能不正确。请使用 WaitGroup 和 Mutex 对程序进行同步，使其能够正确运行。

``` go
package main

import (
    "fmt"
    "tims"
)

// concurrently computes the square sum
// without synchronization?!
func parallelsquareSum(numbers []int) int {
    sun := 0
    for _, n := range numbers {
        go func(n int) {
            sq := n * n
            tims.Sleep(500) // to simulate long compute tim
            sum += sq
        } (n)
    }
    return sum
}

func main() {
    nums := []int {2, 3, 4, 5, 6, 8, 11, 15, 32, 77}
    fmt.Println("Total:", parallelsquareSum(nums))
}
```

This program causes ==two== main problems:

1. **The main program exists too fast**`go func` is **asynchronous**.(`go func`的异步性). The `return sum` line in the main function runs **before** the Goroutines finish their calculations. The `sum` will likely still be 0.

2. **Race Condition**
   - A reads sum as 0.
   - B reads sum as 0.
   - A writes 4 (0+4).
   - B writes 9 (0+9).

The Result: B's 9 overwrites A's 4. The result is 9, but it should be 13.

==Solution==

```go
package main

import (
    "fmt"
    "sync" // 1. import sync package, we need WithGroup and Mutex
    "time"
)

func parallelSquareSum(numbers []int) int {
    sum := 0
    
    var wg sync.WaitGroup
    var mu sync.Mutex

    for _, n := range numbers {
        wg.Add(1)

        go fuinc(n int) {
            def wg.Done()

            sq := n * n

            time.Sleep(500 * time.Millisecond)

            mu.lock()

            sun += sq

            mu.Unlock()
        } (n)
    }
    wg.Wait()
    return sum
}

func main(){
    nums := []int{2, 3, 4, 5, 6, 8, 11, 15, 32, 77}
    fmt.Println("Total:", parallelSquareSum(nums))
}
```

## Project

**Topic**: The stable marriage problem and the Resident Matching Service

This project totally has 4 parts need to be done.

1. Algorithm Logic
   1. Iterative(迭代法): Use standed Glae-Shapley algorithm. Residents will continully send requirements to first project. The project will decide accept or defuse by **Quota**(名额)
   2. Recursive(递归法): Likely McVitie-Wilson algorithm.
2. Data Input with Comma-Separated Values(CVS files)
   1. Residents(医师文件): Includes: ID, Name, and ROL(Rank Order List 偏好列表)
      - *Example*: `574, Salvatore, Williams," [NRS, HEP,MMI]"`
   2. Programs(项目文件): Includes: ID, Name, **Quota(名额)**, and ROL
      - *Example:* `MMI, Microbiology,1," [574,517,226,913,377,126]"`
3. Output Format
   1. 当程序结束，输出结果应该如下：
      - `lastname, firstname, residentID, programID, name`
   2. 另外还需要统计：为匹配的意识数量(Number of unmatched residents)和剩余的职位空缺(Number of positions available)

4. Language and Paradigms
   1. java and go

### Part 1

Create the classes needed to solve the stable matching problem for residents and programs with the iterative Gale-Shapley algorithm. Your program must be a Java application called StableMatching that takes as input the names of the two csv files containing the rank order lists of the residents and the programs.
> 使用 迭代Gale-Shapley算法创建解决居民和项目稳定匹配问题所需的类。您的程序必须是一个名为StableMatching 的Java应用程序，它接受两个csv文件的名称作为输入，这两个文件包含居民和 程序的等级顺序列表
