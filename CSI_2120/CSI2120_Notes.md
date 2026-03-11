---
title: "CSI2120 Notes"
author: "Jace Wang"
date: "2026-01-12"

output:
  pdf_document:
    toc: true
    toc_depth: 3
    number_sections: true
---

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

            sum += sq

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

#### Question 2

a) This code is a module that repeatedly ccalls a function. It stops when a message is sent to the `stop` channel. We want to add another stopping condition: the module should also terminate is its output channle is not read for a period of 2 seconds. *Hint: this can be done using `time.After` function*

> a) 此代码是一个模块，它会反复调用一个函数。当向停止通道发送消息时，该模块会停止运行。我们还想添加另一个停止条件：该模块还应在其输出通道未在 2 秒内被读取时终止运行。提示：这可以通过使用 `time.After` 函数来实现。

Code:

```go
func repearFct (wg *sync.WaitGroup, stop <- chan bool, fct func() int) <-chan int {
  intStram := make(chan int)
  
  go func() {
    defer func() {wg.Done()}()
    defer close(intStream)
    
    for {
      select {
      	case <-stop:
        	fmt.Printf("\nFin de repeat (%d)... \n", count)
        	return
        case intStream <- fct():
      }
    }
  }()
  return intStream
}
```

==Solution==: 最直接的办法就是在select方法中加入一个`tmie.After(2*time.Second)`，也就是只要两秒钟内一致发送无法成功，timeout就会触发并推出`goroutine`

```go
package main

import (
  "fmt"
  "sync"
  "time"
)

func repeatFct(wg *sync.WaitGroup, stop <-chan bool, fct func() int) <-chan int {
  intStream := make(chan int)

  wg.Add(1)
  go func() {
    // 确保 goroutine 退出时：1) WaitGroup 计数减 1，2) 关闭输出通道
    defer wg.Done()
    defer close(intStream)

    for {
      select {
        case <-stop:
        // 收到 stop 信号，立即退出
        fmt.Println("repeatFct: stopped by stop signal")
        return

        // 只有当“有人正在读取 intStream”时，这个发送分支才会被选中
        case intStream <- fct():
        // 成功发送一个值后继续循环
        // （这里不需要做额外处理）

        case <-time.After(2 * time.Second):
        // 2 秒内一直无法发送（通常意味着没人读 intStream），就退出
        fmt.Println("repeatFct: stopped because output not read for 2s")
        return
      }
    }
  }()

  return intStream
}
```

b) With the moudle in a), create a pipeline made of three concurrent stages that will generatee random *Harshad numbers*. A fan-out of three *Harshad filters* is applied at the last stage. Instead of sending the *Harshad numbers* to an output channel, the three filters insert the found numbers to a common queue data structure passed to each filter (see the signature below). Use this pipeline to generate 200 random numbers; only the Harshad numbers are inserted into the queue. Once the pipeline terminates, the content of the queue is displayed by the `main` function/

```go
func filter(wg *sync.WaitGroup, stop <- chan bool,
           inputIntstream <- chan int,
            filter func(int) bool,
           outputQueue *Queue)
```

![image-20260219122850243](./assets/CSI2120_Notes/image-20260219122850243.png)

==Solution==:

**Stage 1**：`repeatFct`（不断产生随机数，带 stop + 2s 输出无人读自动停止，来自 a)）

**Stage 2**：`takeN`（只取前 200 个随机数，然后触发 stop，让整个 pipeline 收敛结束）

**Stage 3**：`fan-out × 3 filters`（三个并发 Harshad filter，从同一个输入流读；**命中则写入同一个共享 Queue**，不再输出到 channel)

最后 `main` 等待所有 goroutine 结束，然后打印 Queue 内容

```go
package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

// -------------------- Queue (thread-safe) --------------------

type Queue struct {
	mu   sync.Mutex
	data []int
}

// Enqueue 将一个元素加入队尾（加锁，避免多个 filter 并发写入导致 data race
func (q *Queue) Enqueue(x int) {
	q.mu.Lock()
	defer q.mu.Unlock()
	q.data = append(q.data, x)
}

// Snapshot 复制当前内容用于最后打印（避免打印时被并发修改）。
func (q *Queue) Snapshot() []int {
	q.mu.Lock()
	defer q.mu.Unlock()

	cp := make([]int, len(q.data))
	copy(cp, q.data)
	return cp
}

//
// -------------------- a) repeatFct (with 2s not-read stop) --------------------
//

// repeatFct 不断调用 fct() 生成 int 并尝试发送到输出通道。
// 停止条件：
// 1。 stop 通道收到信号
// 2。输出通道 2 秒都没有被读取（导致发送一直无法成功）
func repeatFct(wg *sync.WaitGroup, stop <-chan bool, fct func() int) <-chan int {
	intStream := make(chan int)

	wg.Add(1)
	go func() {
		defer wg.Done()
		defer close(intStream)

		for {
			select {
			case <-stop:
				// 外部请求停止
				return

			case intStream <- fct():
				// 成功发送一个值，继续循环
				// 注意：如果没人读，这个 case 不会被选中

			case <-time.After(2 * time.Second):
				// 2 秒内都无法完成发送（通常表示没人读），停止
				return
			}
		}
	}()

	return intStream
}

//
// -------------------- Stage 2: takeN --------------------
//

// takeN 从 input 读取最多 n 个数，并发送到输出。
// 当读取到 n 个后：
// - 关闭 output
// - 通过 stopOnce safely close(stopCh)，整个 pipeline stops
func takeN(
	wg *sync.WaitGroup,
	input <-chan int,
	n int,
	stopCh chan bool,
	stopOnce *sync.Once,
) <-chan int {
	out := make(chan int)

	wg.Add(1)
	go func() {
		defer wg.Done()
		defer close(out)

		count := 0
		for v := range input {
			out <- v
			count++
			if count >= n {
				stopOnce.Do(func() { close(stopCh) })
				return
			}
		}

		// 如果 input 提前关闭，避免 goroutine 虚空挂载
		stopOnce.Do(func() { close(stopCh) })
	}()

	return out
}

//
// -------------------- Stage 3: filter (fan-out x3) --------------------
//

// filter：从 inputIntStream 读取整数。
// 如果 filterFunc(v) 为真，把 v 放进 outputQueue。
func filter(
	wg *sync.WaitGroup,
	stop <-chan bool,
	inputIntStream <-chan int,
	filterFunc func(int) bool,
	outputQueue *Queue,
) {
	wg.Add(1)
	go func() {
		defer wg.Done()

		for {
			select {
			case <-stop:
				// 收到 stop，退出
				return

			case v, ok := <-inputIntStream:
				// 没有更多数据了，也退出
				if !ok {
					return
				}

				if filterFunc(v) {
					// 符合条件就写入共享队列
					outputQueue.Enqueue(v)
				}
			}
		}
	}()
}

//
// -------------------- Harshad helper --------------------
//

// sumDigits 计算十进制各位数字和
func sumDigits(n int) int {
	if n < 0 {
		n = -n
	}
	s := 0
	for n > 0 {
		s += n % 10
		n /= 10
	}
	return s
}

// isHarshad 判断是否 Harshad number
func isHarshad(n int) bool {
	if n <= 0 {
		return false
	}
	s := sumDigits(n)
	if s == 0 {
		return false
	}
	return n%s == 0
}

//
// -------------------- main: build pipeline --------------------
//

func main() {
	// WaitGroup 用来等待所有 goroutine 退出
	var wg sync.WaitGroup

	// stopCh 是全局停止信号（用 close(stopCh) 广播）
	stopCh := make(chan bool)

	// stopOnce 确保 stopCh 只会 close 一次，否则 panic
	var stopOnce sync.Once

	// 共享队列：三个 filter 都会往里写
	q := &Queue{}

	// 随机数种子（保证每次运行不一样）
	rand.Seed(time.Now().UnixNano())

	// Stage 1: repeatFct -> 产生随机数
	// 这里随机范围你可以按作业要求调整，我先给 1..1_000_000
	stage1 := repeatFct(&wg, stopCh, func() int {
		return rand.Intn(1_000_000) + 1
	})

	// Stage 2: takeN -> 只取 200 个随机数，然后触发 stop
	stage2 := takeN(&wg, stage1, 200, stopCh, &stopOnce)

	// Stage 3: fan-out 3 filters (concurrent)
	// 三个 filter 从同一个 stage2 输入流读，谁抢到算谁的（典型 fan-out）。
	filter(&wg, stopCh, stage2, isHarshad, q)
	filter(&wg, stopCh, stage2, isHarshad, q)
	filter(&wg, stopCh, stage2, isHarshad, q)

	// 等待所有 goroutine 结束
	wg.Wait()

	// 打印队列内容
	result := q.Snapshot()
	fmt.Printf("Total Harshad numbers found (from 200 random ints): %d\n", len(result))
	fmt.Println(result)
}

```

#### Question 3

The following function generates prime numbers that terminates by a given speccial pattern. A maximum number of trials is specified such that the function terminates even if the special prime cannot be found.

> 下面的函数生成以给定的特定模式结束的素数。指定一个最大试验次数，即使找不到特殊素数，函数也会终止。

```go
// a special prime is a prime number that ends
// with the specified pattern sequence
// after nTrials the function returns with a false error code
package main

import (
	"math"
	"math/rand"
)

func getSpecialPrime(pattern int64, maxValue int64, nTrials int) (int64, bool) {
	var div int64
	for div = 10; pattern/div != 0; div *= 10 {

	}
	for i := 0; i < nTrials; i++ {
		n := getPrime(maxValue)
		if n%div == pattern {
			return n, true // special prime found
		}
	}
	return 0, false // we failed to find a special prime
}

// checks if it is a prime number
func isPrime(v int64) bool {
	sq := int64(math.Sqrt(float64(v))) + 1
	var i int64
	for i = 2; i < sq; i++ {
		if v%i == 0 {
			return false
		}
	}
	return true
}

// returns a prime number
func getPrime(maxValue int64) int64 {
	for {
		n := rand.Int63n(maxValue)
		if isPrime(n) {
			return n
		}
	}
}

```

==Solution==:

```go
package main

import (
	"fmt"
	"math"
	"math/rand"
	"time"
)

// getSpecialPrime tries to find a "special prime":
// a prime number that ends with the decimal suffix "pattern".
// It tries at most nTrials times, then returns (0, false) if not found.
func getSpecialPrime(pattern int64, maxValue int64, nTrials int) (int64, bool) {
	// -------- Basic input validation (avoid nonsense cases) --------
	// pattern should be positive in this definition (suffix pattern).
	if pattern <= 0 {
		return 0, false
	}
	// maxValue must be large enough to generate primes.
	// If maxValue <= 2, there are no primes in [0, maxValue).
	if maxValue <= 2 {
		return 0, false
	}
	// If pattern is >= maxValue, you cannot find a number < maxValue
	// whose suffix equals pattern (because the whole number would need to be >= pattern).
	// (Strictly, a longer number could end with pattern, but it's still < maxValue,
	// so this is only impossible when maxValue is too small to allow suffix match.
	// We keep it as a conservative guard: if maxValue <= pattern, it's impossible.)
	if maxValue <= pattern {
		return 0, false
	}

	// -------- Compute div = 10^(number of digits of pattern) --------
	// Example: pattern=37 -> div=100; pattern=502 -> div=1000
	var div int64
	for div = 10; pattern/div != 0; div *= 10 {
		// empty body: we only update div
	}

	// -------- Try up to nTrials random primes --------
	for i := 0; i < nTrials; i++ {
		n := getPrime(maxValue)

		// Check if n ends with pattern (suffix match)
		if n%div == pattern {
			return n, true
		}
	}

	// Failed after nTrials attempts
	return 0, false
}

// isPrime checks whether v is a prime number.
//
// IMPORTANT FIX:
// - v < 2 is NOT prime.
// - Only test divisors up to sqrt(v).
func isPrime(v int64) bool {
	if v < 2 {
		return false
	}
	if v == 2 {
		return true
	}
	if v%2 == 0 {
		return false
	}

	// Only check odd divisors up to sqrt(v)
	sq := int64(math.Sqrt(float64(v)))
	for i := int64(3); i <= sq; i += 2 {
		if v%i == 0 {
			return false
		}
	}
	return true
}

// getPrime returns a random prime p such that 0 <= p < maxValue.
// It keeps sampling until it hits a prime.
func getPrime(maxValue int64) int64 {
	for {
		n := rand.Int63n(maxValue)
		if isPrime(n) {
			return n
		}
	}
}

func main() {
	// Seed the RNG so each run is different
	rand.Seed(time.Now().UnixNano())

	// Example parameters (you can change these in your report/testing)
	var (
		pattern  int64 = 37
		maxValue int64 = 1_000_000
		nTrials        = 100_000
	)

	n, ok := getSpecialPrime(pattern, maxValue, nTrials)
	if ok {
		fmt.Printf("Found special prime ending with %d: %d\n", pattern, n)
	} else {
		fmt.Printf("Failed to find a special prime ending with %d after %d trials.\n", pattern, nTrials)
	}
}

```

The function performs at most nTrials attempts. Each attempt generates a random integer in `[0, maxValue)` and keeps it only if it is prime. It then checks whether the last k decimal digits of the prime match the given pattern by using `n % 10^k == pattern`. If found, it returns `(n, true)`; otherwise, after nTrials it returns `(0, false)`.

---

## Labs

Submit one of three labs.

### Lab1

#### Question 1

Write a Go function that takes a parameter of type `float32` and returns two integer values. The **first integer** must be the floor value of the real number, and the **second integer** must be the ceciling value of that real number. Demonstrate that the function works correctly by calling it from a `main` function.

> 编写一个Go函数，接受float32类型的参数并返回两个整数值。**第一个整数**必须是实数的下限值，**第二个整数**必须是该实数的下限值。通过从“main”函数调用该函数来演示该函数的正确工作。

Solution:

```go
package main

import (
    "math"
)

func floorCeil32(x float32) ( int, int ) {
    xf := float64(x)

    floorVal := math.Floor(xf)
    ceilVal := math.Ceil(xf)

    return int(floorVal), int(ceilVal)
}
```

#### Question 2

 Write a function that removes all negative numbers from a slice of integers. The function must return a new slice containing only the *positive numbers*. Ensure that the returned slice has the same capacity as the original slice. Demonstrate that the function works correctly by calling it from a `main`function
> 编写一个函数，用于从整数切片中移除所有负数。该函数必须返回一个新的切片，其中仅包含*正数*。确保返回的切片与原始切片具有相同的容量。通过在 `main` 函数中调用该函数来证明该函数运行正常。

Solution:

```go
package main
// Haojian Wang
func keepPositives ( nums []int ) []int {
    result := make([]int, 0, cap(nums))

    for _, v := range nums {
        if v > 0 {
            result = append(result, v)
        }
    }
    return result
}
```

#### Question 3

Below is a binary tree containing instances of type `Point`, inserted in an arbitrary order (this is not a binary search tree).
I. Write a method that prints the contents of this tree using a post-order traversal.
II.Write a method `find(x, y)` that determins whether a given point is present anywhere in the tree.
III. Create an interface `PointSearcher` that specifies the `find` method.
IV. Test your methods using the `main` function on the next page, and ensure that your program produces the expected output shown.

> 给你一个不是 BST（插入顺序任意）的二叉树，节点里存 Point{x,y}。
> 你要实现四件事：
> I. postorder()：用后序遍历打印整棵树内容（Left → Right → Root）。  ￼
> II. find(x,y)：在整棵树里查找是否存在该点（因为不是 BST，必须可能遍历左右子树）。
> III. 定义接口 PointSearcher：只规定 find(x,y) 方法。
> IV. 用题目给的 main 测试，并输出与示例一致。

Solution:

```go
package main

import "fmt"

type Point struct {
    x int
    y int
}

type PtTree struct {
    pt Point
    left, right *PtTree
}

func (t *PtTree) postorder() {
    if t == nil {
        return
    }

    t.left.postorder()

    t.right.postorder()

    fmt. Printf("(%d,%d) ", t.pt.x, t.pt.y)
}

func (t *PtTree) find(x, y int) bool{
    if t == nil {
        return false
    }

    if t.pt.x == x && t.pt.y == y{
        return true
    }

    return t.left.find(x, y) || t.right.find(x, y)
}

type PointSearcher interface{
    find(x, y int) bool
}
```

---

### Lab 2

Prolog

#### Q 1

*Given the following facts*





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

### Part 1 Java/OOP Stable Matching (Java)

Create the classes needed to solve the stable matching problem for residents and programs with the iterative Gale-Shapley algorithm. Your program must be a Java application called StableMatching that takes as input the names of the two csv files containing the rank order lists of the residents and the programs.
> 使用 迭代Gale-Shapley算法创建解决居民和项目稳定匹配问题所需的类。您的程序必须是一个名为StableMatching 的Java应用程序，它接受两个csv文件的名称作为输入，这两个文件包含居民和 程序的等级顺序列表

This document walks through the four Java files that implement the **Gale–Shapley** (applicant-proposing) stable matching algorithm for residents and programs. Each section is split by method or logical block, with a short explanation before the code. Code and comments are unchanged from the source files.

---

#### 1. StableMatching.java

This is the **entry point**. It parses command-line arguments, builds a `GaleShapley` instance, loads the CSV data, runs the matching algorithm, and writes the results. Any I/O or number-format error is caught and printed to stderr.

---

##### 1.1 Package and imports

**Explanation:** The class lives in package `part1` and only needs `IOException` for the `main` method’s checked exceptions.

```java
package part1;

/**
 * Student Name: Haojian Wang
 * Student Number: 300411829
 * CSI 2120 - Project Part 1
 */

import java.io.IOException;
```

---

##### 1.2 main(String[] args)

**Explanation:** `main` checks that at least two arguments (residents CSV and programs CSV) are provided; the third argument is optional and defaults to `"output.txt"`. It then instantiates `GaleShapley`, calls `loadResidents` and `loadPrograms`, runs `runMatching()`, and finally `writeResults(outputFile)`. Exceptions are caught so that I/O errors, number-format errors, and any other failure are reported without crashing the JVM.

```java
public class StableMatching {
    public static void main(String[] args) {
        if ( args.length < 2 ) {
            System.out.println("Usage: java part1.StableMatching <residents.csv> <programs.csv> [output.txt]");
            return;
        }

        String residentsFile = args[0];
        String programsFile = args[1];

        String outputFile = ( args.length >= 3 ) ? args[2] :"output.txt";

        try {
            GaleShapley gs = new GaleShapley();
            gs.loadResidents(residentsFile);
            gs.loadPrograms(programsFile);

            // Run iterative Gale–Shapley algorithm
            gs.runMatching();

            // Write required output file + print required summary lines
            gs.writeResults(outputFile);

        } catch (IOException e) {
            System.err.println("I/O Error: " + e.getMessage());
        } catch (NumberFormatException e) {
            System.err.println("Number Format Error: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("Unexpected Error: " + e.getMessage());
        }
    }
}
```

---

#### 2. Resident.java

The **Resident** class represents one applicant (resident). It stores identity and rank-order list (ROL) of programs, the current match (if any), and an index used to iterate over the ROL during the algorithm. All methods used by the Gale–Shapley loop are defined here.

---

##### 2.1 Package, imports, and class fields

**Explanation:** Each resident has an ID, first name, last name, and a ROL of program IDs (strings). The current match is held as a `Program` reference and a `matchedRank` (that resident’s rank in that program’s list; -1 if unmatched). `nextProposalIndex` is the index of the next program in `rol` that this resident will propose to in the iterative algorithm.

```java
package part1;

/*
 * Student Name: Haojian Wang
 * Student Number: 300411829
 */

import java.util.Arrays;

public class Resident {

    // ========== Profs' ==========
    private int residentID;
    private String firstname;
    private String lastname;

    // Resident（program IDs），例如 ["NRS","HEP","MMI"] ???
    private String[] rol;

    // if 匹配到的 Program；else 未匹配则为 null
    private Program matchedProgram;

    // resident 在 matchedProgram 的 ROL 中的排名（数值越小越好），未匹配可用 -1
    private int matchedRank;

    // ========== Assistance ==========
    // 记录这个 resident 下一次要向 rol 的第几个 program 提案
    // mark this resident as for next which program will be chosen for rol
    private int nextProposalIndex;
```

---

##### 2.2 Constructor

**Explanation:** The constructor sets ID and name and leaves ROL unset (to be set later via `setROL`). It initializes the resident as unmatched (`matchedProgram = null`, `matchedRank = -1`) and sets `nextProposalIndex = 0` so the first proposal will be to `rol[0]` once the ROL is set.

```java
    public Resident(int id, String fname, String lname) {
        this.residentID = id;
        this.firstname = fname;
        this.lastname = lname;

        // 初始状态：未匹配 Initial States
        this.matchedProgram = null;
        this.matchedRank = -1;

        // 初始从 rol[0] 开始提案 Start rol[0]
        this.nextProposalIndex = 0;
    }
```

---

##### 2.3 setROL(String[] rol)

**Explanation:** Called after reading the resident from CSV. It stores the rank-order list of program IDs so that later `nextProgramToPropose()` can walk through them in order.

```java
    // 设置 ROL（从 CSV 读出来后调用）ROL Setter, used after reading CSV
    public void setROL(String[] rol) {
        this.rol = rol;
    }
```

---

##### 2.4 Getters and setters

**Explanation:** Standard accessors for resident ID, name, ROL, and match state. `setMatchedProgram` and `setMatchedRank` are used by programs when they accept or update a resident’s match.

```java
    // ================== getters / setters ==================

    public int getResidentID() {
        return residentID;
    }

    public String getFirstname() {
        return firstname;
    }

    public String getLastname() {
        return lastname;
    }

    public String[] getRol() {
        return rol;
    }

    public Program getMatchedProgram() {
        return matchedProgram;
    }

    public int getMatchedRank() {
        return matchedRank;
    }

    public void setMatchedProgram(Program p) {
        this.matchedProgram = p;
    }

    public void setMatchedRank(int rank) {
        this.matchedRank = rank;
    }
```

---

##### 2.5 hasMoreProposals()

**Explanation:** Used by the Gale–Shapley driver to see if this resident still has programs left to propose to. Returns true when `rol` is set and `nextProposalIndex` has not reached the end of the array.

```java
    // ========== 迭代 Gale–Shapley ==========
    // Additional
    // if programs, resident continues
    public boolean hasMoreProposals() {
        return rol != null && nextProposalIndex < rol.length;
    }
```

---

##### 2.6 nextProgramToPropose()

**Explanation:** Returns the next program ID in the resident’s ROL and advances the internal index. If there are no more programs to propose to, it returns null. The driver uses this to get the next program and then calls that program’s `addResident`.

```java
    // 取出下一所要申请的 programID，并把指针往后移动
    // if no 可申请的，return null
    public String nextProgramToPropose() {
        if (!hasMoreProposals()) {
            return null;
        }
        String programID = rol[nextProposalIndex];
        nextProposalIndex++;
        return programID;
    }
```

---

##### 2.7 unmatch()

**Explanation:** Called when a program evicts this resident (e.g. because a more preferred resident was accepted). It clears the match so the resident is “available” again and can be re-queued to propose to the next program on their list.

```java
    // 当 resident 被 program 踢出时：取消匹配（回到 available 状态）
    public void unmatch() {
        this.matchedProgram = null;
        this.matchedRank = -1;
    }
```

---

##### 2.8 isMatched()

**Explanation:** Convenience method for the driver and output logic: true if this resident currently holds a program (matchedProgram is not null).

```java
    // 判断是否已经匹配 case for whether has been chosen
    public boolean isMatched() {
        return matchedProgram != null;
    }
```

---

##### 2.9 toString()

**Explanation:** Provides a short string for debugging: resident ID, name, and the ROL array so you can inspect state in logs or an IDE.

```java
    // string representation
    @Override
    public String toString() {
        return "[" + residentID + "]: " + firstname + " " + lastname
                + " ROL=" + (rol == null ? "null" : Arrays.toString(rol));
    }
}
```

---

#### 3. Program.java

The **Program** class represents one residency program. It has a quota, a rank-order list of resident IDs, and a list of currently matched residents. It exposes methods to check membership and rank in the ROL, to find the least preferred current match, and to accept or reject a proposing resident (possibly evicting someone). The inner class `AddResult` bundles the decision and any evicted resident.

---

##### 3.1 Package, imports, and class fields

**Explanation:** Each program has an ID, name, and quota. `rol` is the full preference list (resident IDs in order). `matchedResidents` is the list of residents currently held. `rankMap` is built from `rol` so we can answer “what is this resident’s rank?” in O(1) and “is this resident in our ROL?” without scanning the array.

```java
package part1;

// Project CSI2120/CSI2520
// Winter 2026
// Robert Laganiere, uottawa.ca


/**
 * Student Name: Haojian Wang
 * Student Number: 300411829
 */

import java.util.ArrayList;
import java.util.HashMap;

// this is the (incomplete) Program class
public class Program {
	
	private String programID;
	private String name;
	private int quota;
	private int[] rol;
	
    private ArrayList<Resident> matchedResidents;

    private HashMap<Integer, Integer> rankMap;
```

---

##### 3.2 Constructor

**Explanation:** Initializes ID, name, and quota. Allocates empty lists for matched residents and for the rank map; the rank map is filled when `setROL` is called.

```java
    public Program(String id, String n, int q) {
	
		this.programID= id;
		this.name= n;
		this.quota= q;

        this.matchedResidents= new ArrayList<>();
        this.rankMap= new HashMap<>();
	}
```

---

##### 3.3 setROL(int[] rol)

**Explanation:** Sets the program’s preference list and rebuilds `rankMap` so that each resident ID maps to its 0-based index in the ROL. Lower index means more preferred. This is used by `rank()` and `member()` during the matching loop.

```java
    // the rol in order of preference, build rankMap
	public void setROL(int[] rol) {
		this.rol= rol;

        // residentID -> rank
        rankMap.clear();
        for (int i = 0; i < rol.length; i++) {
            rankMap.put(rol[i], i);

        }
	}
```

---

##### 3.4 Getters

**Explanation:** Standard accessors so the driver and output code can read the program’s quota, name, ID, and the list of currently matched residents.

```java
    // =========== getters ===========

    public int getQuota() {
        return quota;
    }

    public String getName() {
        return name;
    }

    public String getProgramID() {
        return programID;
    }

    public ArrayList<Resident> getMatchedResidents() {
        return matchedResidents;
    }
```

---

##### 3.5 member(int residentID)

**Explanation:** Returns whether the given resident ID appears in this program’s ROL. Used by `addResident` to reject residents the program did not rank.

```java
    // ------------------------------------------------

    // member(residentID): resident 是否在该 program 的 ROL 中
    public boolean member(int residentID) {
        return rankMap.containsKey(residentID);
    }
```

---

##### 3.6 rank(int residentID)

**Explanation:** Returns the 0-based rank of the resident in this program’s ROL (lower is more preferred). Returns -1 if the resident is not in the ROL. Used when comparing the proposing resident to the current worst match.

```java
    // rank(residentID): 返回 resident 在 program ROL 的排名；不在则 -1
    public int rank(int residentID) {
        Integer r = rankMap.get(residentID);
        return (r == null) ? -1 : r;
    }
```

---

##### 3.7 leastPreferred()

**Explanation:** Among the residents currently in `matchedResidents`, returns the one with the **highest** (worst) rank in this program’s ROL. Used when the program is full and we need to decide whether to evict someone in favour of the new proposer.

```java
    // leastPreferred(): 返回当前 matchedResidents 中 program 最不喜欢的那位
    // "最不喜欢"= rank 最大（数字越大代表越靠后）
    public Resident leastPreferred() {
        if (matchedResidents.isEmpty()) {
            return null;
        }

        Resident worst = matchedResidents.get(0);
        for (Resident r : matchedResidents) {
            if (r.getMatchedRank() > worst.getMatchedRank()) {
                worst = r;
            }
        }
        return worst;
    }
```

---

##### 3.8 addResident(Resident resident)

**Explanation:** Implements the program’s decision when a resident proposes. (1) If the resident is not in the program’s ROL, reject and return not accepted, no eviction. (2) If the program is below quota, accept the resident and update their match state; return accepted, no eviction. (3) If at quota, compare the new resident’s rank to the current worst; if the new resident is strictly better, evict the worst (call `unmatch()` on them), add the new resident, and return accepted with the evicted resident. (4) Otherwise reject. The return value is an `AddResult` so the driver can both see whether the proposer was accepted and who (if anyone) to re-queue.

```java
    // ---------------------------------------
    /*
     * addResident(resident):
     *  - 若 program 不认识这个 resident（不在 program ROL），直接拒绝（return false）
     *  - 若未满 quota：接收
     *  - 若已满 quota：若更喜欢新 resident，则替换 leastPreferred
     *
     * 为了方便 GaleShapley 驱动循环，这里返回 "被踢出的 resident"（若没有踢人则返回 null）。
     * 如果新 resident 被拒绝，也返回 null，但会通过 boolean 告知是否接收。
     */
    public AddResult addResident(Resident resident) {

        int rid = resident.getResidentID();

        // 1) if 不在 program ROL 里，return
        if (!member(rid)) {
            return new AddResult(false, null);
        }

        // 计算该 resident 在 program ROL 的 rank, lees -> good
        int newRank = rank(rid);

        // 2) if 还没满 quota，do
        if (matchedResidents.size() < quota) {
            matchedResidents.add(resident);

            // refresh resident 的匹配信息
            resident.setMatchedProgram(this);
            resident.setMatchedRank(newRank);

            return new AddResult(true, null);
        }

        // 3) if 已满 quota：看是否比当前最差者更好 which one is batter
        Resident worst = leastPreferred();
        if (worst == null) {
            // 理论上不会发生（因为 size>=quota>=1)
            return new AddResult(false, null);
        }

        // 如果新 resident rank 更小 => program 更喜欢新的人
        if (newRank < worst.getMatchedRank()) {

            // 替换：把 worst 踢掉
            matchedResidents.remove(worst);
            worst.unmatch(); // 被踢出后变为 available

            // 接收新 resident
            matchedResidents.add(resident);
            resident.setMatchedProgram(this);
            resident.setMatchedRank(newRank);

            return new AddResult(true, worst);
        }

        // 4) 否则拒绝新 resident
        return new AddResult(false, null);
    }
```

---

##### 3.9 AddResult (inner class)

**Explanation:** A small value object used as the return type of `addResident`. It carries whether the proposer was accepted and, if someone was evicted, that resident. The driver uses this to add the evicted resident back to the queue when applicable.

```java
    // 用于把"接收与否 + 被踢出的人"一起返回（非 static）
    public class AddResult {
        private boolean accepted;
        private Resident evicted;

        public AddResult(boolean accepted, Resident evicted) {
            this.accepted = accepted;
            this.evicted = evicted;
        }

        public boolean isAccepted() {
            return accepted;
        }

        public Resident getEvicted() {
            return evicted;
        }
    }
```

---

##### 3.10 toString()

**Explanation:** Debug string: program ID, name, quota, and length of the ROL.

```java
    // string representation
    @Override
	public String toString() {
      
       return "["+programID+"]: "+name+" {"+ quota+ "}" +" ("+rol.length+")";	  
	}
}
```

---

#### 4. GaleShapley.java

This class **owns** the resident and program maps, **loads** them from CSV via `readResidents` and `readPrograms`, **runs** the iterative Gale–Shapley algorithm in `runMatching()`, and **writes** the required output file and summary lines in `writeResults`. It is the central driver for Part 1.

---

##### 4.1 Package, imports, and class fields

**Explanation:** Two maps: residents by ID (Integer) and programs by ID (String). The constructor and getters are straightforward; the real work is in the private readers and the public `loadResidents`/`loadPrograms`/`runMatching`/`writeResults` methods.

```java
package part1;

// Project CSI2120/CSI2520
// Winter 2026
// Robert Laganiere, uottawa.ca

import java.io.*;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;

// this is the (incomplete) class that will generate the resident and program maps
public class GaleShapley {

	private HashMap<Integer,Resident> residents;
	private HashMap<String,Program> programs;

    // create two hash map for residents and programs
    public GaleShapley() {
        residents = new HashMap<>();
        programs = new HashMap<>();
    }
    //Residents getter
    public HashMap<Integer,Resident> getResidents() {
        return residents;
    }
    // Programs getter
    public HashMap<String,Program> getPrograms() {
        return programs;
    }
```

---

##### 4.2 loadResidents and loadPrograms

**Explanation:** Public entry points that delegate to the private CSV readers. They allow the caller (e.g. `StableMatching.main`) to load both files and let the reader methods throw `IOException` or `NumberFormatException` if the format is wrong.

```java
    public void loadResidents(String filename) throws IOException, NumberFormatException {
        readResidents(filename);
    }

    public void loadPrograms(String filename) throws IOException, NumberFormatException {
        readPrograms(filename);
    }
```

---

##### 4.3 readResidents(String residentsFilename)

**Explanation:** Opens the residents CSV and skips the header. For each data line it parses, in order: resident ID (up to first comma), first name, last name, then the quoted program list (e.g. `"NRS,HEP,MMI"`). It constructs a `Resident`, sets the ROL via `setROL`, and puts the resident into the `residents` map. Parsing is done with index arithmetic and `substring`/`split`; invalid lines or missing fields cause an `IOException` or `NumberFormatException`.

```java
    // =========== CVS 读取 READERS START=========
	// Reads the residents csv file
	// It populates the residents HashMap
    private void readResidents(String residentsFilename) throws IOException,
													NumberFormatException {

        String line;
		residents= new HashMap<Integer,Resident>();
		BufferedReader br = new BufferedReader(new FileReader(residentsFilename));

		int residentID;
		String firstname;
		String lastname;
		String plist;
		String[] rol;

		// Read each line from the CSV file
		line = br.readLine(); // skipping first line
		while ((line = br.readLine()) != null && line.length() > 0) {

			int split;
			int i;

			// extracts the resident ID
			for (split=0; split < line.length(); split++) {
				if (line.charAt(split) == ',') {
					break;
				}
			}
			if (split > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			residentID= Integer.parseInt(line.substring(0,split));
			split++;

			// extracts the resident firstname
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				}
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			firstname= line.substring(split,i);
			split= i+1;

			// extracts the resident lastname
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				}
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			lastname= line.substring(split,i);
			split= i+1;

			Resident resident= new Resident(residentID,firstname,lastname);

			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == '"') {
					break;
				}
			}

			// extracts the program list
			plist= line.substring(i+2,line.length()-2);
			String delimiter = ","; // Assuming values are separated by commas
			rol = plist.split(delimiter);

			resident.setROL(rol);

			residents.put(residentID,resident);
		}
        // Important: close the file
        br.close();
    }
```

---

##### 4.4 readPrograms(String programsFilename)

**Explanation:** Same idea as `readResidents` but for the programs file. Each line gives program ID, name, quota, and a quoted list of resident IDs. A `Program` is created, its ROL is set with `setROL(rol)` (which builds the rank map), and the program is put into the `programs` map. The reader closes the file when done.

```java
	// Reads the programs csv file
	// It populates the programs HashMap
    private void readPrograms(String programsFilename) throws IOException,
													NumberFormatException {

        String line;
		programs= new HashMap<String,Program>();
		BufferedReader br = new BufferedReader(new FileReader(programsFilename));

		String programID;
		String name;
		int quota;
		String rlist;
		int[] rol;

		// Read each line from the CSV file
		line = br.readLine(); // skipping first line
		while ((line = br.readLine()) != null && line.length() > 0) {

			int split;
			int i;

			// extracts the program ID
			for (split=0; split < line.length(); split++) {
				if (line.charAt(split) == ',') {
					break;
				}
			}
			if (split > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);


			programID= line.substring(0,split);
			split++;

			// extracts the program name
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				}
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			name= line.substring(split,i);
			split= i+1;

			// extracts the program quota
			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == ',') {
					break;
				}
			}
			if (i > line.length()-2)
				throw new IOException("Error: Invalid line format: " + line);

			quota= Integer.parseInt(line.substring(split,i));
			split= i+1;

			Program program= new Program(programID,name,quota);

			for (i= split ; i < line.length(); i++) {
				if (line.charAt(i) == '"') {
					break;
				}
			}

			// extracts the resident list
			rlist= line.substring(i+2,line.length()-2);
			String delimiter = ","; // Assuming values are separated by commas
			String[] rol_string = rlist.split(delimiter);
			rol= new int[rol_string.length];
			for (int j=0; j<rol_string.length; j++) {

				rol[j]= Integer.parseInt(rol_string[j]);
			}

			program.setROL(rol);

			programs.put(programID,program);
		}
        // Important: close the file
        br.close();
    }
    // ============ CVS 读取 READERS OVER ==========
```

---

##### 4.5 runMatching()

**Explanation:** This implements the **iterative applicant-proposing Gale–Shapley** algorithm. A queue holds residents who are still “available” (unmatched and with more programs to propose to). Initially all such residents are enqueued. The main loop repeatedly takes a resident from the front; if they are already matched (e.g. re-queued after being evicted and then matched again), skip. Otherwise, in an inner loop, the resident proposes to the next program on their list (skipping unknown program IDs). The program’s `addResident` is called; if the result is accepted, any evicted resident (if non-null and still having proposals) is added to the back of the queue, and we break out of the inner loop. If the resident is still unmatched but has more proposals, they are re-queued so they will propose again in a later round. The process continues until the queue is empty.

```java
    public void runMatching() {
        // Queue of available residents (unmatched + still have programs to propose to)
        ArrayDeque<Resident> queue = new ArrayDeque<>();

        // Initialize: all residents start unmatched
        for (Resident r : residents.values()) {
            if (r.hasMoreProposals()) {
                queue.add(r);
            }
        }

        // Iterative applicant-proposing Gale–Shapley
        while (!queue.isEmpty()) {

            Resident r = queue.removeFirst();

            // If already matched (can happen if added twice), skip
            if (r.isMatched()) {
                continue;
            }

            // Propose until accepted or resident exhausts their ROL
            while (r.hasMoreProposals() && !r.isMatched()) {

                String programID = r.nextProgramToPropose();

                // 如果居民列出一个未知的程序id，跳过
                // If resident listed an unknown programID, skip
                Program p = programs.get(programID);
                if (p == null) {
                    continue;
                }

                // 到此一游 Oo
                // Program decides accept/reject/evict based on its ROL and quota
                Program.AddResult result = p.addResident(r);

                if (result.isAccepted()) {
                    // If someone was evicted, they become available again
                    Resident evicted = result.getEvicted();
                    if (evicted != null && evicted.hasMoreProposals()) {
                        queue.addLast(evicted);
                    }
                    break; // r is matched now
                }
            }

            // If still unmatched but can still propose (rare), re-queue
            if (!r.isMatched() && r.hasMoreProposals()) {
                queue.addLast(r);
            }
        }
    }
```

---

##### 4.6 writeResults(String outputFilename)

**Explanation:** Builds the required output file and summary lines. It collects all residents, sorts them by last name then first name (case-insensitive) for readability. It counts unmatched residents and available positions (sum over programs of quota minus current matches). It writes the header line and one row per resident: lastname, firstname, residentID, and either `XXX,NOT_MATCHED` or the matched program’s ID and name. Then it appends the two summary lines to the file and also prints them to the console. The file is closed when done.

```java
    /**
     * Writes the required output file and prints the required summary lines.
     * Output columns:
     * lastname,firstname,residentID,programID,name
     *
     * Unmatched residents must use:
     * programID=XXX, name=NOT_MATCHED
     * damn...
     */
    public void writeResults(String outputFilename) throws IOException {

        ArrayList<Resident> allResidents = new ArrayList<>(residents.values());

        // Sorting is not required, but makes output easier to read
        allResidents.sort(new Comparator<Resident>() {
            @Override
            public int compare(Resident a, Resident b) {
                int c = a.getLastname().compareToIgnoreCase(b.getLastname());
                if (c != 0) return c;
                return a.getFirstname().compareToIgnoreCase(b.getFirstname());
            }
        });

        int unmatchedCount = 0;
        int availablePositions = 0;

        // Total remaining positions across all programs
        for (Program p : programs.values()) {
            availablePositions += (p.getQuota() - p.getMatchedResidents().size());
        }

        BufferedWriter bw = new BufferedWriter(new FileWriter(outputFilename));

        // Header
        bw.write("lastname,firstname,residentID,programID,name");
        bw.newLine();

        // Rows
        for (Resident r : allResidents) {
            if (!r.isMatched()) {
                unmatchedCount++;
                bw.write(r.getLastname() + "," + r.getFirstname() + "," + r.getResidentID() + ",XXX,NOT_MATCHED");
            } else {
                Program p = r.getMatchedProgram();
                bw.write(r.getLastname() + "," + r.getFirstname() + "," + r.getResidentID() + "," + p.getProgramID() + "," + p.getName());
            }
            bw.newLine();
        }

        // Required summary lines (also print to console)
        String line1 = "Number of unmatched residents: " + unmatchedCount;
        String line2 = "Number of positions available: " + availablePositions;

        System.out.println(line1);
        System.out.println(line2);

        // Also append to file (useful for submission)
        bw.write(line1);
        bw.newLine();
        bw.write(line2);
        bw.newLine();

        bw.close();
    }

}
```

---

#### Summary

| File             | Role                                                                 |
|------------------|----------------------------------------------------------------------|
| **StableMatching** | Entry point: CLI, load data, run matching, write results; catches exceptions. |
| **Resident**       | One applicant: ID, name, ROL, match state, next-proposal index; methods for the driver. |
| **Program**        | One program: quota, ROL, matched list, rank map; accept/reject/evict via `addResident`; `AddResult` inner class. |
| **GaleShapley**    | Maps, CSV readers, iterative Gale–Shapley loop, and output writer.  |

The flow is: **StableMatching.main** → **GaleShapley** (load → runMatching → writeResults). **runMatching** uses a queue of residents and repeatedly has them propose via **Resident.nextProgramToPropose**; **Program.addResident** decides accept/reject/evict and returns an **AddResult** so evicted residents can be re-queued.


### Part 2 — Stable Matching (Go)

#### Project structure

Part 2’s Go implementation has two programs: **sequential** (single-threaded) and **concurrent**. Both use the McVitie–Wilson recursive algorithm; the concurrent version uses goroutines and Mutex, while the sequential version uses only plain function calls.

```
Project/
├── java/
│   └── src/
│       └── part1/
│           ├── GaleShapley.java
│           ├── Program.java
│           ├── Resident.java
│           └── StableMatching.java
└── go/
    ├── sequential/
    │   └── main.go    # single-threaded: no goroutines, no Mutex
    └── concurrent/
        └── main.go    # concurrent: every offer is a goroutine; Mutex protects shared data
```

---

#### 1. Concurrent version — `go/concurrent/main.go`

---

##### 1.1 Package and imports (concurrent)

**Explanation:** The program uses package `main`. The concurrent version imports `sync` (Mutex, WaitGroup) and `time` (timing); the rest are for file/string handling (`bufio`, `os`, `strings`, `strconv`) and output/sorting (`fmt`, `sort`).

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)
```

---

##### 1.2 Data types: Resident and Program (concurrent)

**Explanation:**  
- **Resident:** Holds the resident’s ID, name, rank-order list `rol`, current match `matchedProgram`, and the next index to propose to `nextIdx`. The concurrent version uses `mu sync.Mutex` to guard `nextIdx` and `matchedProgram` so multiple goroutines do not modify the same resident at once.  
- **Program:** Holds the program’s ID, name, quota `nPositions`, preference list `rol`, and currently selected residents `selectedResidents`. `rankCache` is a read-only map from residentID to rank index for O(1) preference comparison. `mu` guards `selectedResidents`.

```go
// Resident holds one applicant's data and current match state.
type Resident struct {
	residentID     int
	firstname      string
	lastname       string
	rol            []string   // preferred program IDs, index 0 = most preferred
	matchedProgram string     // "" means unmatched
	nextIdx        int        // next program index to propose to in rol
	mu             sync.Mutex // guards nextIdx and matchedProgram
}

// Program holds one residency program's data and current match state.
type Program struct {
	programID         string
	name              string
	nPositions        int
	rol               []int       // preferred resident IDs
	selectedResidents []int       // IDs of currently matched residents
	rankCache         map[int]int // residentID -> rank index; read-only after loading
	mu                sync.Mutex  // guards selectedResidents
}
```

---

##### 1.3 Program helper methods (concurrent)

**Explanation:**  
- **member:** Returns whether the resident is in the program’s preference list (read-only `rankCache`, no lock needed).  
- **rank:** Returns the 0-based rank of the resident in the program’s ROL; lower index means more preferred; returns -1 if not found.  
- **leastPreferred:** Among currently selected residents, returns the one the program likes least (highest rank index). **Must be called with `p.mu` held.**  
- **removeResident:** Removes a resident ID from `selectedResidents` using swap-with-last for O(1) removal. **Must be called with `p.mu` held.**

```go
func (p *Program) member(residentID int) bool {
	_, ok := p.rankCache[residentID]
	return ok
}

func (p *Program) rank(residentID int) int {
	if r, ok := p.rankCache[residentID]; ok {
		return r
	}
	return -1
}

func (p *Program) leastPreferred() int {
	if len(p.selectedResidents) == 0 {
		return -1
	}
	worst := p.selectedResidents[0]
	worstRank := p.rank(worst)
	for _, rid := range p.selectedResidents {
		if p.rank(rid) > worstRank {
			worstRank = p.rank(rid)
			worst = rid
		}
	}
	return worst
}

func (p *Program) removeResident(rid int) {
	for i, id := range p.selectedResidents {
		if id == rid {
			last := len(p.selectedResidents) - 1
			p.selectedResidents[i] = p.selectedResidents[last]
			p.selectedResidents = p.selectedResidents[:last]
			return
		}
	}
}
```

---

##### 1.4 McVitie–Wilson: offer (concurrent)

**Explanation:** In the concurrent version, **every call to `offer` runs inside a goroutine**. The caller runs `wg.Add(1)` before `go offer(...)`, and `offer` uses `defer wg.Done()` at the top so the counter is decremented on every return path.  
Logic: lock the resident and read `nextIdx` and `rol`; if the ROL is exhausted set `matchedProgram = ""` and return; otherwise take the current program `pid`, increment `nextIdx`, **then unlock** (to avoid deadlock when entering `evaluate`), and call `evaluate(rid, pid, ...)`.

```go
func offer(rid int, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup) {
	defer wg.Done()

	r := residents[rid]

	r.mu.Lock()
	if r.nextIdx >= len(r.rol) {
		r.matchedProgram = ""
		r.mu.Unlock()
		return
	}
	pid := r.rol[r.nextIdx]
	r.nextIdx++
	r.mu.Unlock()

	evaluate(rid, pid, residents, programs, wg)
}
```

---

##### 1.5 McVitie–Wilson: evaluate (concurrent)

**Explanation:** Handles the three cases when resident `rid` applies to program `pid`.  
- **Case 1:** Program did not rank `rid` → reject; `wg.Add(1); go offer(rid, ...)` so the resident tries the next choice.  
- **Case 2:** Program has space → accept `rid`, update `selectedResidents` and `rid`’s `matchedProgram`, then return.  
- **Case 3:** Program is full. If the program prefers `rid` over the current worst match `lp`, displace `lp`, update both sides’ state, **release the program lock first**, then `go offer(lp, ...)`; otherwise reject `rid`, **release the lock**, then `go offer(rid, ...)`.  
Convention: never acquire a Program lock while holding a Resident lock; release the Program lock before spawning a new goroutine so locks are not held across goroutine boundaries.

```go
func evaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup) {
	r := residents[rid]
	p := programs[pid]

	if !p.member(rid) {
		wg.Add(1)
		go offer(rid, residents, programs, wg)
		return
	}

	p.mu.Lock()

	if len(p.selectedResidents) < p.nPositions {
		p.selectedResidents = append(p.selectedResidents, rid)
		r.mu.Lock()
		r.matchedProgram = pid
		r.mu.Unlock()
		p.mu.Unlock()
		return
	}

	lp := p.leastPreferred()

	if p.rank(rid) < p.rank(lp) {
		p.removeResident(lp)
		p.selectedResidents = append(p.selectedResidents, rid)
		r.mu.Lock()
		r.matchedProgram = pid
		r.mu.Unlock()
		lpRes := residents[lp]
		lpRes.mu.Lock()
		lpRes.matchedProgram = ""
		lpRes.mu.Unlock()
		p.mu.Unlock()
		wg.Add(1)
		go offer(lp, residents, programs, wg)
	} else {
		p.mu.Unlock()
		wg.Add(1)
		go offer(rid, residents, programs, wg)
	}
}
```

---

##### 1.6 CSV parsing, loading, output, and main (concurrent)

**Explanation:**  
- **splitCSVLine:** Splits a line on commas but ignores commas inside quotes (e.g. `"[NRS,HEP,MMI]"` is one field).  
- **parseStringList / parseIntList:** Parse `"[NRS,HEP,MMI]"` and `"[574,517,226]"` into `[]string` and `[]int`.  
- **loadResidents / loadPrograms:** Read CSV, skip header, build Resident/Program per row; Program precomputes `rankCache`. Use `scanner.Buffer` for large files.  
- **printResults:** Sort by lastname then firstname and print in the required format; then print unmatched count and open positions.  
- **main:** Check CLI args, load data (not timed), then `start := time.Now()`, for each resident `wg.Add(1); go offer(...)`, `wg.Wait()`, `end := time.Now()`, then print results and `Execution time` (printing is excluded from the timed section).

```go
func splitCSVLine(line string) []string {
	var fields []string
	var current strings.Builder
	inQuotes := false
	for _, c := range line {
		switch {
		case c == '"':
			inQuotes = !inQuotes
		case c == ',' && !inQuotes:
			fields = append(fields, current.String())
			current.Reset()
		default:
			current.WriteRune(c)
		}
	}
	fields = append(fields, current.String())
	return fields
}

func parseStringList(s string) []string {
	s = strings.Trim(s, "[] \t")
	if s == "" {
		return []string{}
	}
	parts := strings.Split(s, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		t := strings.TrimSpace(p)
		if t != "" {
			result = append(result, t)
		}
	}
	return result
}

func parseIntList(s string) []int {
	s = strings.Trim(s, "[] \t")
	if s == "" {
		return []int{}
	}
	parts := strings.Split(s, ",")
	result := make([]int, 0, len(parts))
	for _, p := range parts {
		t := strings.TrimSpace(p)
		if t == "" {
			continue
		}
		n, err := strconv.Atoi(t)
		if err == nil {
			result = append(result, n)
		}
	}
	return result
}

func loadResidents(filename string) (map[int]*Resident, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	residents := make(map[int]*Resident)
	scanner := bufio.NewScanner(f)
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)
	firstLine := true
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if firstLine {
			firstLine = false
			continue
		}
		if line == "" {
			continue
		}
		fields := splitCSVLine(line)
		if len(fields) < 4 {
			continue
		}
		id, err := strconv.Atoi(strings.TrimSpace(fields[0]))
		if err != nil {
			continue
		}
		residents[id] = &Resident{
			residentID: id,
			firstname:  strings.TrimSpace(fields[1]),
			lastname:   strings.TrimSpace(fields[2]),
			rol:        parseStringList(fields[3]),
			nextIdx:    0,
		}
	}
	return residents, scanner.Err()
}

func loadPrograms(filename string) (map[string]*Program, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	programs := make(map[string]*Program)
	scanner := bufio.NewScanner(f)
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)
	firstLine := true
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if firstLine {
			firstLine = false
			continue
		}
		if line == "" {
			continue
		}
		fields := splitCSVLine(line)
		if len(fields) < 4 {
			continue
		}
		id := strings.TrimSpace(fields[0])
		name := strings.TrimSpace(fields[1])
		quota, err := strconv.Atoi(strings.TrimSpace(fields[2]))
		if err != nil {
			continue
		}
		rolInts := parseIntList(fields[3])
		cache := make(map[int]int, len(rolInts))
		for i, rid := range rolInts {
			cache[rid] = i
		}
		programs[id] = &Program{
			programID:         id,
			name:              name,
			nPositions:        quota,
			rol:               rolInts,
			selectedResidents: []int{},
			rankCache:         cache,
		}
	}
	return programs, scanner.Err()
}

func printResults(residents map[int]*Resident, programs map[string]*Program) {
	list := make([]*Resident, 0, len(residents))
	for _, r := range residents {
		list = append(list, r)
	}
	sort.Slice(list, func(i, j int) bool {
		if list[i].lastname != list[j].lastname {
			return list[i].lastname < list[j].lastname
		}
		return list[i].firstname < list[j].firstname
	})
	fmt.Println("lastname,firstname,residentID,programID,name")
	unmatchedCount := 0
	for _, r := range list {
		if r.matchedProgram == "" {
			fmt.Printf("%s,%s,%d,XXX,NOT_MATCHED\n", r.lastname, r.firstname, r.residentID)
			unmatchedCount++
		} else {
			p := programs[r.matchedProgram]
			fmt.Printf("%s,%s,%d,%s,%s\n", r.lastname, r.firstname, r.residentID, p.programID, p.name)
		}
	}
	openPositions := 0
	for _, p := range programs {
		openPositions += p.nPositions - len(p.selectedResidents)
	}
	fmt.Printf("Number of unmatched residents: %d\n", unmatchedCount)
	fmt.Printf("Number of positions available: %d\n", openPositions)
}

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintln(os.Stderr, "Usage: go run main.go <residentsFile> <programsFile>")
		os.Exit(1)
	}
	residents, err := loadResidents(os.Args[1])
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error loading residents:", err)
		os.Exit(1)
	}
	programs, err := loadPrograms(os.Args[2])
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error loading programs:", err)
		os.Exit(1)
	}
	start := time.Now()
	var wg sync.WaitGroup
	for id := range residents {
		wg.Add(1)
		go offer(id, residents, programs, &wg)
	}
	wg.Wait()
	end := time.Now()
	printResults(residents, programs)
	fmt.Printf("\nExecution time: %s\n", end.Sub(start))
}
```

---

#### 2. Sequential version — `go/sequential/main.go`

---

##### 2.1 Package and imports (sequential)

**Explanation:** The sequential version does not import `sync` (no Mutex or WaitGroup); it only uses `time` for timing. The rest is the same as the concurrent version for file I/O, string parsing, and output.

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
	"time"
)
```

---

##### 2.2 Data types: Resident and Program (sequential)

**Explanation:** Same logical fields as the concurrent version but **no `mu sync.Mutex`**. With a single thread, only one `offer`/`evaluate` runs at a time, so there is no concurrent write and no locks are needed.

```go
type Resident struct {
	residentID     int
	firstname      string
	lastname       string
	rol            []string
	matchedProgram string
	nextIdx        int
}

type Program struct {
	programID         string
	name              string
	nPositions        int
	rol               []int
	selectedResidents []int
	rankCache         map[int]int
}
```

---

##### 2.3 Program helper methods (sequential)

**Explanation:** Same as concurrent: `member` and `rank` only read `rankCache`; `leastPreferred` finds the worst-ranked among selected residents; `removeResident` uses swap-with-last for O(1) removal. No locking is needed in the sequential version.

```go
func (p *Program) member(residentID int) bool {
	_, ok := p.rankCache[residentID]
	return ok
}

func (p *Program) rank(residentID int) int {
	if r, ok := p.rankCache[residentID]; ok {
		return r
	}
	return -1
}

func (p *Program) leastPreferred() int {
	if len(p.selectedResidents) == 0 {
		return -1
	}
	worst := p.selectedResidents[0]
	worstRank := p.rank(worst)
	for _, rid := range p.selectedResidents {
		if p.rank(rid) > worstRank {
			worstRank = p.rank(rid)
			worst = rid
		}
	}
	return worst
}

func (p *Program) removeResident(rid int) {
	for i, id := range p.selectedResidents {
		if id == rid {
			last := len(p.selectedResidents) - 1
			p.selectedResidents[i] = p.selectedResidents[last]
			p.selectedResidents = p.selectedResidents[:last]
			return
		}
	}
}
```

---

##### 2.4 McVitie–Wilson: offer (sequential)

**Explanation:** Same logic as the concurrent version but **no WaitGroup** and **direct call** to `evaluate` (no goroutine). If the ROL is exhausted, set `matchedProgram = ""` and return; otherwise take the current program, increment `nextIdx`, then call `evaluate(rid, pid, residents, programs)` (no `wg` argument).

```go
func offer(rid int, residents map[int]*Resident, programs map[string]*Program) {
	r := residents[rid]

	if r.nextIdx >= len(r.rol) {
		r.matchedProgram = ""
		return
	}

	pid := r.rol[r.nextIdx]
	r.nextIdx++

	evaluate(rid, pid, residents, programs)
}
```

---

##### 2.5 McVitie–Wilson: evaluate (sequential)

**Explanation:** The three cases are the same as in the concurrent version, but every “try next” is a **direct call** to `offer(...)` instead of `go offer(...)`. Case 1: `offer(rid, ...)`; Case 3a: update state then `offer(lp, ...)`; Case 3b: `offer(rid, ...)`. No locks and no `wg.Add(1)`.

```go
func evaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program) {
	r := residents[rid]
	p := programs[pid]

	if !p.member(rid) {
		offer(rid, residents, programs)
		return
	}

	if len(p.selectedResidents) < p.nPositions {
		p.selectedResidents = append(p.selectedResidents, rid)
		r.matchedProgram = pid
		return
	}

	lp := p.leastPreferred()

	if p.rank(rid) < p.rank(lp) {
		p.removeResident(lp)
		p.selectedResidents = append(p.selectedResidents, rid)
		r.matchedProgram = pid
		residents[lp].matchedProgram = ""
		offer(lp, residents, programs)
	} else {
		offer(rid, residents, programs)
	}
}
```

---

##### 2.6 CSV parsing, loading, output, and main (sequential)

**Explanation:** `splitCSVLine`, `parseStringList`, `parseIntList`, `loadResidents`, `loadPrograms`, and `printResults` are the same as in the concurrent version (types simply have no `mu`). **main** differs: no `wg`; it calls `offer` sequentially with `for id := range residents { offer(id, residents, programs) }`, then stops the timer and prints results and execution time.

```go
func splitCSVLine(line string) []string {
	var fields []string
	var current strings.Builder
	inQuotes := false
	for _, c := range line {
		switch {
		case c == '"':
			inQuotes = !inQuotes
		case c == ',' && !inQuotes:
			fields = append(fields, current.String())
			current.Reset()
		default:
			current.WriteRune(c)
		}
	}
	fields = append(fields, current.String())
	return fields
}

func parseStringList(s string) []string {
	s = strings.Trim(s, "[] \t")
	if s == "" {
		return []string{}
	}
	parts := strings.Split(s, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		t := strings.TrimSpace(p)
		if t != "" {
			result = append(result, t)
		}
	}
	return result
}

func parseIntList(s string) []int {
	s = strings.Trim(s, "[] \t")
	if s == "" {
		return []int{}
	}
	parts := strings.Split(s, ",")
	result := make([]int, 0, len(parts))
	for _, p := range parts {
		t := strings.TrimSpace(p)
		if t == "" {
			continue
		}
		n, err := strconv.Atoi(t)
		if err == nil {
			result = append(result, n)
		}
	}
	return result
}

func loadResidents(filename string) (map[int]*Resident, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	residents := make(map[int]*Resident)
	scanner := bufio.NewScanner(f)
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)
	firstLine := true
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if firstLine {
			firstLine = false
			continue
		}
		if line == "" {
			continue
		}
		fields := splitCSVLine(line)
		if len(fields) < 4 {
			continue
		}
		id, err := strconv.Atoi(strings.TrimSpace(fields[0]))
		if err != nil {
			continue
		}
		residents[id] = &Resident{
			residentID: id,
			firstname:  strings.TrimSpace(fields[1]),
			lastname:   strings.TrimSpace(fields[2]),
			rol:        parseStringList(fields[3]),
			nextIdx:    0,
		}
	}
	return residents, scanner.Err()
}

func loadPrograms(filename string) (map[string]*Program, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	programs := make(map[string]*Program)
	scanner := bufio.NewScanner(f)
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)
	firstLine := true
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if firstLine {
			firstLine = false
			continue
		}
		if line == "" {
			continue
		}
		fields := splitCSVLine(line)
		if len(fields) < 4 {
			continue
		}
		id := strings.TrimSpace(fields[0])
		name := strings.TrimSpace(fields[1])
		quota, err := strconv.Atoi(strings.TrimSpace(fields[2]))
		if err != nil {
			continue
		}
		rolInts := parseIntList(fields[3])
		cache := make(map[int]int, len(rolInts))
		for i, rid := range rolInts {
			cache[rid] = i
		}
		programs[id] = &Program{
			programID:         id,
			name:              name,
			nPositions:        quota,
			rol:               rolInts,
			selectedResidents: []int{},
			rankCache:         cache,
		}
	}
	return programs, scanner.Err()
}

func printResults(residents map[int]*Resident, programs map[string]*Program) {
	list := make([]*Resident, 0, len(residents))
	for _, r := range residents {
		list = append(list, r)
	}
	sort.Slice(list, func(i, j int) bool {
		if list[i].lastname != list[j].lastname {
			return list[i].lastname < list[j].lastname
		}
		return list[i].firstname < list[j].firstname
	})
	fmt.Println("lastname,firstname,residentID,programID,name")
	unmatchedCount := 0
	for _, r := range list {
		if r.matchedProgram == "" {
			fmt.Printf("%s,%s,%d,XXX,NOT_MATCHED\n", r.lastname, r.firstname, r.residentID)
			unmatchedCount++
		} else {
			p := programs[r.matchedProgram]
			fmt.Printf("%s,%s,%d,%s,%s\n", r.lastname, r.firstname, r.residentID, p.programID, p.name)
		}
	}
	openPositions := 0
	for _, p := range programs {
		openPositions += p.nPositions - len(p.selectedResidents)
	}
	fmt.Printf("Number of unmatched residents: %d\n", unmatchedCount)
	fmt.Printf("Number of positions available: %d\n", openPositions)
}

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintln(os.Stderr, "Usage: go run main.go <residentsFile> <programsFile>")
		os.Exit(1)
	}
	residents, err := loadResidents(os.Args[1])
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error loading residents:", err)
		os.Exit(1)
	}
	programs, err := loadPrograms(os.Args[2])
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error loading programs:", err)
		os.Exit(1)
	}
	start := time.Now()
	for id := range residents {
		offer(id, residents, programs)
	}
	end := time.Now()
	printResults(residents, programs)
	fmt.Printf("\nExecution time: %s\n", end.Sub(start))
}
```

---

==Summary==

| Aspect        | Concurrent                              | Sequential                 |
|---------------|-----------------------------------------|----------------------------|
| offer calls   | Every call is `go offer(...)` with `wg` | Direct `offer(...)`       |
| Shared data   | Resident / Program protected by Mutex   | No locks; single-threaded  |
| Imports       | Includes `sync`, `time`                 | Includes `time`, no `sync` |
| Algorithm     | Same McVitie–Wilson offer/evaluate      | Same                       |
| CSV / output  | Same as sequential                      | Same as concurrent         |

The two versions differ only in concurrency and locking; the algorithm and I/O/output format are the same. On large inputs the concurrent version is expected to be faster.

### Part 3

### Part 4
