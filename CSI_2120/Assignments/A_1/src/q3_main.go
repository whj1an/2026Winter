package main

import (
	"fmt"
	"sync"
	"time"
)

func createSpecialPrimeStream(
	result chan<- int64,
	wg *sync.WaitGroup,
	stop <-chan bool,
	pattern int64,
	maxV int64,
	trials int,
) {
	defer wg.Done()

	for {
		select {
		case <-stop:
			return
		default:
			n, ok := getSpecialPrime(pattern, maxV, trials)
			if ok {
				result <- n
			}
		}
	}
}

func main() {

	pattern := int64(1111)
	maxV := int64(100000000000)
	trials := 1000
	nPrimes := 4

	threadCounts := []int{1, 2, 4, 8, 16, 32}

	for _, nThreads := range threadCounts {

		var totalTime float64

		for run := 0; run < 10; run++ {

			start := time.Now()

			stop := make(chan bool)
			result := make(chan int64)

			var wg sync.WaitGroup
			wg.Add(nThreads)

			for i := 0; i < nThreads; i++ {
				go createSpecialPrimeStream(result, &wg, stop, pattern, maxV, trials)
			}

			sp := make([]int64, 0, nPrimes)
			seen := make(map[int64]bool)

			for len(sp) < nPrimes {
				n := <-result
				if !seen[n] {
					seen[n] = true
					sp = append(sp, n)
				}
			}

			close(stop) // tell all threads to stop
			wg.Wait()   // wait for all goroutines

			elapsed := time.Since(start).Seconds()
			totalTime += elapsed
		}

		avg := totalTime / 10.0
		fmt.Printf("Threads: %d | Avg Time: %.4f s\n", nThreads, avg)
	}
}
