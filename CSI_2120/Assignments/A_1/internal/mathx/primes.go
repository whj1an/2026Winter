package mathx

import (
	"math"
	"math/rand"
)

// IsPrime checks whether v is a prime number.
//
// Important correctness rules:
// - v < 2 is NOT prime (0 and 1 are not prime).
// - 2 is prime.
// - Even numbers > 2 are not prime.
// - We only test divisors up to sqrt(v).
func IsPrime(v int64) bool {
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
	limit := int64(math.Sqrt(float64(v)))
	for d := int64(3); d <= limit; d += 2 {
		if v%d == 0 {
			return false
		}
	}
	return true
}

// GetPrime returns a random prime p such that 0 <= p < maxValue.
//
// We pass rng as a parameter so each goroutine can have its own
// random generator (this reduces lock contention and avoids data races).
func GetPrime(rng *rand.Rand, maxValue int64) int64 {
	for {
		n := rng.Int63n(maxValue)
		if IsPrime(n) {
			return n
		}
	}
}

// GetSpecialPrime tries to find a special prime that ends with suffix "pattern".
// It tries at most nTrials attempts.
//
// Return values:
// - (prime, true)  if found within nTrials
// - (0, false)     if not found
//
// Example:
// pattern=1111 means we want primes ending with "...1111".
func GetSpecialPrime(rng *rand.Rand, pattern int64, maxValue int64, nTrials int) (int64, bool) {
	// Basic input guards
	if pattern <= 0 || maxValue <= 2 || nTrials <= 0 {
		return 0, false
	}

	// Compute div = 10^(number of digits in pattern)
	// Example: pattern=1111 -> div=10000
	var div int64
	for div = 10; pattern/div != 0; div *= 10 {
		// Intentionally empty: div is updated in the loop header.
	}

	// Try nTrials times
	for i := 0; i < nTrials; i++ {
		n := GetPrime(rng, maxValue)

		// n%div extracts the last k digits (k = digits(pattern)).
		// If equal, suffix matches.
		if n%div == pattern {
			return n, true
		}
	}

	return 0, false
}
