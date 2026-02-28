package ds

import (
	"fmt"
	"strings"
	"sync"
)

// Queue is a thread-safe FIFO queue for integers.
//
// Why thread-safe?
// - In Q2, you have 3 concurrent filter goroutines.
// - All of them may call Enqueue at the same time.
// - Without a mutex, you will get data races and corrupted slice state.
type Queue struct {
	mu   sync.Mutex // protects all fields below
	data []int      // underlying storage; front is at index 0
}

// NewQueue creates an empty queue.
// You can use it or just do: q := &Queue{}
func NewQueue() *Queue {
	return &Queue{
		data: make([]int, 0),
	}
}

// Enqueue inserts x at the end of the queue (FIFO).
func (q *Queue) Enqueue(x int) {
	q.mu.Lock()
	defer q.mu.Unlock()

	q.data = append(q.data, x)
}

// Dequeue removes and returns the element at the front of the queue.
// The second return value is false if the queue is empty.
func (q *Queue) Dequeue() (int, bool) {
	q.mu.Lock()
	defer q.mu.Unlock()

	if len(q.data) == 0 {
		return 0, false
	}

	// Take the front element
	v := q.data[0]

	// Remove it from the slice (FIFO)
	// This is O(n) due to shifting; it is fine for assignment scale.
	q.data = q.data[1:]

	return v, true
}

// Peek returns the front element without removing it.
// The second return value is false if the queue is empty.
func (q *Queue) Peek() (int, bool) {
	q.mu.Lock()
	defer q.mu.Unlock()

	if len(q.data) == 0 {
		return 0, false
	}
	return q.data[0], true
}

// Len returns the number of elements in the queue.
func (q *Queue) Len() int {
	q.mu.Lock()
	defer q.mu.Unlock()

	return len(q.data)
}

// IsEmpty returns true if the queue has no elements.
func (q *Queue) IsEmpty() bool {
	return q.Len() == 0
}

// Snapshot returns a copy of the queue content.
// This is the safest way to print the queue after all goroutines finish.
func (q *Queue) Snapshot() []int {
	q.mu.Lock()
	defer q.mu.Unlock()

	cp := make([]int, len(q.data))
	copy(cp, q.data)
	return cp
}

// String returns a human-readable representation of the queue.
// Example: [12, 15, 18]
func (q *Queue) String() string {
	q.mu.Lock()
	defer q.mu.Unlock()

	parts := make([]string, 0, len(q.data))
	for _, v := range q.data {
		parts = append(parts, fmt.Sprintf("%d", v))
	}
	return "[" + strings.Join(parts, ", ") + "]"
}
