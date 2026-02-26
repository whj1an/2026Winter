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
