package pipeline

import (
	"sync"

	"csi2120/a1/internal/ds"
)

// Filter reads integers from inputIntStream.
// If filterFunc(v) is true, it inserts v into the shared outputQueue.
//
// IMPORTANT:
// - This stage DOES NOT output to a channel (as required by your Q2 description).
// - It stops when stop is closed OR when input is closed.
func Filter(
	wg *sync.WaitGroup,
	stop <-chan bool,
	inputIntStream <-chan int,
	filterFunc func(int) bool,
	outputQueue *ds.Queue,
) {
	wg.Add(1)
	go func() {
		defer wg.Done()

		for {
			select {
			case <-stop:
				// Global stop signal
				return

			case v, ok := <-inputIntStream:
				// Upstream ended: no more data to process
				if !ok {
					return
				}

				// Apply filter and write to shared queue if matched
				if filterFunc(v) {
					outputQueue.Enqueue(v)
				}
			}
		}
	}()
}
