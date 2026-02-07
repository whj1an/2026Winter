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

## Labs
Just subbmitted one of three labs.

### Lab1

**Question 1**: Write a Go function that takes a parameter of type `float32` and returns two integer values. The **first integer** must be the floor value of the real number, and the **second integer** must be the ceciling value of that real number. Demonstrate that the function works correctly by calling it from a `main` function.

> 编写一个Go函数，接受float32类型的参数并返回两个整数值。**第一个整数**必须是实数的下限值，**第二个整数**必须是该实数的下限值。通过从“main”函数调用该函数来演示该函数的正确工作。

```go
package main

import "fmt"

func main() {

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

### Part 1 Java/OOP

Create the classes needed to solve the stable matching problem for residents and programs with the iterative Gale-Shapley algorithm. Your program must be a Java application called StableMatching that takes as input the names of the two csv files containing the rank order lists of the residents and the programs.
> 使用 迭代Gale-Shapley算法创建解决居民和项目稳定匹配问题所需的类。您的程序必须是一个名为StableMatching 的Java应用程序，它接受两个csv文件的名称作为输入，这两个文件包含居民和 程序的等级顺序列表

## Go Study

go语言为并发而生
主要结合课程内容进行go语言的学习，中英混合，默认已经掌握java，python以及部分C。如果需要更详细的笔记内容请参阅 [手册](https://www.topgoer.com/go%E5%9F%BA%E7%A1%80/)

### 1. Basics

Golang内置类型和函数
init函数和main函数
命令


#### 1.1 内置类型与函数

**值类型**:

```go
    bool
    int(32 or 64), int8, int16, int32, int64
    uint(32 or 64), uint8(byte), uint16, uint32, uint64
    float32, float64
    string
    complex64, complex128
    array    -- 固定长度的数组
```

**引用类型（pointer）**:

```go
    slice   -- 序列数组(最常用)
    map     -- 映射
    chan    -- 管道
```

**内置函数 inside functions**：

```go
    append          -- 用来追加元素到数组、slice中,返回修改后的数组、slice
    close           -- 主要用来关闭channel
    delete            -- 从map中删除key对应的value
    panic            -- 停止常规的goroutine  （panic和recover：用来做错误处理）
    recover         -- 允许程序定义goroutine的panic动作
    imag            -- 返回complex的实部   （complex、real imag：用于创建和操作复数）
    real            -- 返回complex的虚部
    make            -- 用来分配内存，返回Type本身(只能应用于slice, map, channel)
    new                -- 用来分配内存，主要用来分配值类型，比如int、struct。返回指向Type的指针
    cap                -- capacity是容量的意思，用于返回某个类型的最大容量（只能用于切片和 
    copy            -- 用于复制和连接slice，返回复制的数目
    len                -- 来求长度，比如string、array、slice、map、channel ，返回长度
    print、println     -- 底层打印函数，在部署环境中建议使用 fmt 包
```

**内置接口**：

```go
    type error interface { //只要实现了Error()函数，返回值为String的都实现了err接口

            Error()    String

    }
```

#### 1.2 Init函数和main函数

`init`函数 Function `init`

go语言中，`init`函数用于包package的初始化，该函数是go的一个特性。
特征如下：

> 1. init 函数是程序执行钱做包的初始化函数，例如包内部的变量等
> 2. 每个包里可以有 **多个** `init` 函数
> 3. 包的每个源文件也可以有多个`init`函数
> 4. 同一个包的`init`函数按照包导入的依赖关系决定该初始化函数的执行顺序
> 5. 不同包的`init`函数按照包导入依赖关系决定初始化函数的执行顺序
> 6. `init`函数不能被其他函数调用，而是在main函数执行前自动被调用

`main`函数

ex:

```go
package main

import "fmt"

func main() {
    //functions
}
```

#### 1.3 命令 commands

If you wanna run go in your terminal, you can check all the commands about go.

```bash
$go
Go is a tool for managing Go source code.

Usage:
    go command [arguments]

The commands are:

    build       compile packages and dependencies // 编译我们指定的远吗文件以及依赖包
    clean       remove object files // 删除执行其他命令时产生的一些文件和目录
    doc         show documentation for package or symbol
    env         print Go environment information // 打印go的环境信息
    bug         start a bug report
    fix         run go tool fix on packages
    fmt         run gofmt on package sources
    generate    generate Go files by processing source
    get         download and install packages and dependencies
    install     compile and install packages and dependencies
    list        list packages
    run         compile and run Go program
    test        test packages
    tool        run specified go tool
    version     print Go version
    vet         run go tool vet on packages // 检查go远吗中静态错误

Use "go help [command]" for more information about a command.

Additional help topices:

    c           calling between Go and C
    buildmode   description of build modes
    filetype    file types
    gopath      GOPATH environment variable
    environment environment variables
    importpath  import path syntax
    packages    description of package lists
    testflag    description of testing flags
    testfunc    description of testing functions

Use "go help [topic]" for more information about that topic.
```

### 2. In class Lecture Notes

A small Go program

```go
package main

import "fmt" // import a package
func main() {
    fmt.Println("Hello, 世界")
}
```

call a value:

```go
package main

import "fmt"

// 全局变量，并且只能用var关键词定义
// 全局变量不受是否“被用”限制
var program = "go"

func main() {
    // 先声明
    var name string
    // 再赋值
    name = "Tom"
    fmt.Println(name)

    // 声明属性并赋值
    var age int = 24
    // 直接赋值
    var gan = "man"
    fmt.Println(age, gan)

    // 声明并赋值
    yearOfNow := "2026"
    fmt.Println(yearOfNow)
}

```

Multiple return values:

```go
package main

import "fmt"

func main() {

    var s int
    var d int

    s, d = plusminus(7, 9)
    fmt.Printf("result = %d et %d", s, d)

    for i,j := 1,5 ; j < 100 ; i,j = i + 1, j + 5 {
        fmt.Printf("%d and %d", i, j)
    
    }
}
```
