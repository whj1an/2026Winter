package pipeline

import "sync"

// TakeN reads up to n values from input and forwards them to output.
// After taking n values, it triggers stopOnce(close(stopCh)) to stop the whole pipeline.
//
// Why we need stopOnce?
// - Closing a channel twice causes panic.
// - Multiple stages might try to stop the pipeline; stopOnce guarantees only once.
func TakeN(
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
				// Broadcast stop to all stages
				stopOnce.Do(func() { close(stopCh) })
				return
			}
		}

		// If input closed early, still stop the system to avoid hanging goroutines.
		stopOnce.Do(func() { close(stopCh) })
	}()

	return out
}
