package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"

	"csi2120/a1/internal/mathx"
)

// createSpecialPrimeStream is one worker goroutine.
//
// What it does:
// - Repeatedly tries to find ONE "special prime" that ends with the given pattern.
// - If it finds one, it writes it to the shared "result" channel.
// - It keeps looping until the "stop" channel is closed.
//
// Why we need stop channel:
//   - The main goroutine will close(stop) once it collected enough primes (4),
//     or if timeout happens, so that all workers can exit cleanly.
func createSpecialPrimeStream(
	result chan<- int64, // shared channel: all workers send to this same channel
	wg *sync.WaitGroup, // waitgroup to allow main to wait for worker exit
	stop <-chan bool, // closed to signal worker to stop
	pattern int64, // suffix pattern, e.g. 1111
	maxV int64, // upper bound for random prime generation
	trials int, // max number of attempts per "search round"
	workerID int, // used to create different RNG seeds
) {
	// Mark this worker as done when it returns
	defer wg.Done()

	// IMPORTANT:
	// Each worker must have its own RNG instance.
	// Using the global rand in multiple goroutines is possible but often causes lock contention
	// and can become a bottleneck; separate RNG per worker improves throughput.
	seed := time.Now().UnixNano() + int64(workerID)*1_000_000
	rng := rand.New(rand.NewSource(seed))

	for {
		// First, check if we were asked to stop.
		// Using select with default makes this check non-blocking.
		select {
		case <-stop:
			return
		default:
			// continue working
		}

		// Try to find ONE special prime within "trials" attempts.
		// If not found, ok==false and we just loop again (another round).
		n, ok := mathx.GetSpecialPrime(rng, pattern, maxV, trials)
		if ok {
			// Send the special prime to the shared channel.
			// BUT: we must also stop quickly if stop is closed (avoid blocking forever).
			select {
			case result <- n:
				// sent successfully
			case <-stop:
				// main requested stop
				return
			}
		}
	}
}

// runOnce runs the concurrent search ONCE, and returns how many seconds it took.
//
// Requirements satisfied here:
// - Start "nThreads" workers.
// - All workers write to the same "result" channel.
// - Collect exactly "nPrimes" UNIQUE primes (deduplicate).
// - Stop all workers as soon as collected enough results.
// - Add a 10-minute timeout to guarantee termination.
func runOnce(nThreads int, pattern int64, maxV int64, trials int, nPrimes int) float64 {
	start := time.Now()

	// stop is closed to stop all workers.
	stop := make(chan bool)

	// result is the shared channel where ALL workers send found primes.
	// Use buffering to reduce blocking, especially when many workers find results quickly.
	result := make(chan int64, 64)

	// Start workers
	var wg sync.WaitGroup
	wg.Add(nThreads)

	for i := 0; i < nThreads; i++ {
		go createSpecialPrimeStream(result, &wg, stop, pattern, maxV, trials, i)
	}

	// We must collect nPrimes UNIQUE results.
	// Use a map to deduplicate (two workers may find the same prime).
	found := make([]int64, 0, nPrimes)
	seen := make(map[int64]bool)

	// 10-minute timeout (as per assignment screenshot)
	timer := time.NewTimer(10 * time.Minute)
	defer timer.Stop()

	// Collect until enough primes OR timeout
collectLoop:
	for len(found) < nPrimes {
		select {
		case <-timer.C:
			// Timeout reached: stop collecting.
			break collectLoop

		case n := <-result:
			// Deduplicate before counting
			if !seen[n] {
				seen[n] = true
				found = append(found, n)
			}
		}
	}

	// Signal all workers to stop and wait for them to exit.
	// IMPORTANT: Do NOT close(result). If a worker sends while result is closed, it will panic.
	close(stop)
	wg.Wait()

	// Optionally print found primes for debugging:
	// fmt.Println("Found primes:", found)

	return time.Since(start).Seconds()
}

func main() {
	fmt.Println("Q3: Concurrent special primes benchmark (all threads send to the same channel).")

	// Parameters from the assignment screenshot
	pattern := int64(1111)
	maxV := int64(100000000000) // 1e11
	trials := 1000
	nPrimes := 4

	// Thread counts required by the assignment
	threadCounts := []int{1, 2, 4, 8, 16, 32}

	// Run each configuration 10 times and average
	runsPerConfig := 10

	fmt.Println("Threads | Avg Time (s)")
	fmt.Println("----------------------")

	for _, threads := range threadCounts {
		total := 0.0

		for run := 0; run < runsPerConfig; run++ {
			elapsed := runOnce(threads, pattern, maxV, trials, nPrimes)
			total += elapsed
		}

		avg := total / float64(runsPerConfig)
		fmt.Printf("%7d | %.6f\n", threads, avg)
	}

	fmt.Println("\nCopy this table into a document and export to PDF for submission.")
}
