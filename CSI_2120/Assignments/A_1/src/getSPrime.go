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

	if pattern <= 0 {
		return 0, false
	}
	if maxValue <= 2 {
		return 0, false
	}
	// If pattern is >= maxValue, you cannot find a number < maxValue

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
// FIX:
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

	// Example
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
