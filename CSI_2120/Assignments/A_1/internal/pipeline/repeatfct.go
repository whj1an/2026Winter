package pipeline

import (
	"sync"
	"time"
)

// RepeatFct repeatedly calls fct() and sends its returned int to an output channel.
//
// Stopping conditions:
// 1) stop channel is closed (or receives a value)
// 2) output is not read for 2 seconds (send cannot proceed), then we stop automatically
//
// Why condition (2) works:
// - In Go, sending on an unbuffered channel blocks until a receiver is ready.
// - In a select, a blocking send case is "not selectable".
// - If nobody reads, the send case cannot proceed; after 2 seconds, time.After triggers.
func RepeatFct(wg *sync.WaitGroup, stop <-chan bool, fct func() int) <-chan int {
	out := make(chan int)

	wg.Add(1)
	go func() {
		defer wg.Done()
		defer close(out)

		for {
			select {
			case <-stop:
				// Stop requested by upstream
				return

			case out <- fct():
				// Successfully sent one value, continue

			case <-time.After(2 * time.Second):
				// Nobody read from out for 2 seconds
				return
			}
		}
	}()

	return out
}
