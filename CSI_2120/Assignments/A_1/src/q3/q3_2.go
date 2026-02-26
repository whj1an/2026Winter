package main

import (
	"context"
	"fmt"
	"math"
	"math/rand"
	"sync"
	"time"
)

// -------------------- Prime helpers --------------------

// isPrime checks if v is prime.
// Important: v < 2 is NOT prime.
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
	// Only test odd divisors up to sqrt(v)
	sq := int64(math.Sqrt(float64(v)))
	for i := int64(3); i <= sq; i += 2 {
		if v%i == 0 {
			return false
		}
	}
	return true
}

// getPrime returns a random prime p such that 0 <= p < maxValue.
// Each worker should use its own rng to avoid data races and contention.
func getPrime(rng *rand.Rand, maxValue int64) int64 {
	for {
		n := rng.Int63n(maxValue)
		if isPrime(n) {
			return n
		}
	}
}

// -------------------- Special prime search (cancellable) --------------------

// getSpecialPrimeCtx tries up to nTrials attempts to find a prime ending with "pattern".
// It can be cancelled via ctx (timeout or manual cancel).
func getSpecialPrimeCtx(ctx context.Context, rng *rand.Rand, pattern int64, maxValue int64, nTrials int) (int64, bool) {
	// Basic guards (avoid meaningless input)
	if pattern <= 0 || maxValue <= 2 || nTrials <= 0 {
		return 0, false
	}

	// Compute div = 10^(digits of pattern)
	// Example: pattern=1111 -> div=10000
	var div int64
	for div = 10; pattern/div != 0; div *= 10 {
		// empty on purpose
	}

	for i := 0; i < nTrials; i++ {
		// Check cancellation frequently
		select {
		case <-ctx.Done():
			return 0, false
		default:
			// continue
		}

		n := getPrime(rng, maxValue)
		if n%div == pattern {
			return n, true
		}
	}
	return 0, false
}

// -------------------- Concurrent solution (threads) --------------------

// worker keeps searching special primes and sends them to results.
// It stops when ctx is cancelled.
func worker(
	ctx context.Context,
	wg *sync.WaitGroup,
	workerID int,
	pattern int64,
	maxV int64,
	trials int,
	results chan<- int64,
) {
	defer wg.Done()

	// Create a worker-local RNG (thread-safe because not shared)
	seed := time.Now().UnixNano() + int64(workerID)*1_000_000
	rng := rand.New(rand.NewSource(seed))

	for {
		// Stop if cancelled
		select {
		case <-ctx.Done():
			return
		default:
			// keep working
		}

		// Try to find ONE special prime in "trials" attempts
		n, ok := getSpecialPrimeCtx(ctx, rng, pattern, maxV, trials)
		if ok {
			// Send result unless we got cancelled
			select {
			case results <- n:
				// sent successfully
			case <-ctx.Done():
				return
			}
		}
		// If not found in trials, loop and try again.
	}
}

func main() {
	fmt.Println("Solution WITH threads (concurrent workers).")

	// Parameters from your screenshot
	var pattern int64 = 1111
	var maxV int64 = 100000000000 // 1e11
	var trials int = 1000
	var nPrimes int = 4

	// Worker count: usually set to CPU cores or a small multiple.
	// You can tune this value (e.g., 4, 8, 16).
	workers := 8

	start := time.Now()

	// Global timeout: stop everything after 10 minutes
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Minute)
	defer cancel()

	results := make(chan int64, 32) // buffered so workers don’t block too much
	var wg sync.WaitGroup

	// Start workers
	wg.Add(workers)
	for i := 0; i < workers; i++ {
		go worker(ctx, &wg, i, pattern, maxV, trials, results)
	}

	// Collector: gather unique special primes until we have nPrimes or timeout
	sp := make([]int64, 0, nPrimes)
	seen := make(map[int64]bool)

collectLoop:
	for len(sp) < nPrimes {
		select {
		case <-ctx.Done():
			// Timeout reached
			break collectLoop

		case n := <-results:
			// Deduplicate in case two workers find same prime
			if !seen[n] {
				seen[n] = true
				sp = append(sp, n)

				// If enough primes found, cancel workers immediately
				if len(sp) >= nPrimes {
					cancel()
					break collectLoop
				}
			}
		}
	}

	// Wait for workers to exit
	wg.Wait()
	end := time.Now()

	fmt.Println("Special prime numbers are:", sp)
	fmt.Println("End of program.", end.Sub(start))
}
