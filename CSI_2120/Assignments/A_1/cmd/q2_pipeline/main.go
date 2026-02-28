package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"

	"csi2120/a1/internal/ds"
	"csi2120/a1/internal/mathx"
	"csi2120/a1/internal/pipeline"
)

// Q2 Pipeline structure:
//
// Stage 1: RepeatFct (random int generator)   -> channel A
// Stage 2: TakeN (take exactly 200)           -> channel B
// Stage 3: Fan-out 3 Filters (Harshad)        -> shared Queue
//
// After termination, main prints the Queue content.
func main() {
	// WaitGroup waits for all goroutines created by pipeline stages
	var wg sync.WaitGroup

	// stopCh is a broadcast stop signal: close(stopCh) stops everyone
	stopCh := make(chan bool)

	// stopOnce guarantees stopCh is closed only once
	var stopOnce sync.Once

	// Shared queue where all filters insert matched Harshad numbers
	q := &ds.Queue{}

	// Seed RNG so results differ each run
	rand.Seed(time.Now().UnixNano())

	// Stage 1: generate random integers (range can be adjusted)
	stage1 := pipeline.RepeatFct(&wg, stopCh, func() int {
		// Random range: 1..1_000_000
		return rand.Intn(1_000_000) + 1
	})

	// Stage 2: take exactly 200 numbers, then stop pipeline
	stage2 := pipeline.TakeN(&wg, stage1, 200, stopCh, &stopOnce)

	// Stage 3: fan-out 3 concurrent filters reading from the same channel
	// Note: fan-out means each value is consumed by exactly ONE filter (worker model).
	pipeline.Filter(&wg, stopCh, stage2, mathx.IsHarshad, q)
	pipeline.Filter(&wg, stopCh, stage2, mathx.IsHarshad, q)
	pipeline.Filter(&wg, stopCh, stage2, mathx.IsHarshad, q)

	// Wait until all stages stop
	wg.Wait()

	// Print queue results
	result := q.Snapshot()
	fmt.Printf("Q2: Total Harshad numbers found (from 200 random ints): %d\n", len(result))
	fmt.Println(result)
}
