package main

import (
	"fmt"
	"sync"
	"time"
)

// concurrently computes the square sum
// with proper synchronization
func parallelSquareSum(numbers []int) int {
	sum := 0

	var wg sync.WaitGroup
	var mu sync.Mutex

	for _, n := range numbers {
		wg.Add(1)

		go func(n int) {
			defer wg.Done()

			sq := n * n
			time.Sleep(500 * time.Millisecond)

			mu.Lock()
			sum += sq
			mu.Unlock()
		}(n)
	}

	wg.Wait()
	return sum
}

func main() {
	nums := []int{2, 3, 4, 5, 6, 8, 11, 15, 32, 77}
	fmt.Println("Total:", parallelSquareSum(nums))
}
