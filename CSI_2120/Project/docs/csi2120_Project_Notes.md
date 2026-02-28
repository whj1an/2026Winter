# Part 2

``` go
Project/
├── java/
│   └── src/
│       └── part1/
│           ├── GaleShapley.java
│           ├── Program.java
│           ├── Resident.java
│           └── StableMatching.java
└── go/
    ├── sequential/
    │   └── main.go
    └── concurrent/
        └── main.go
```

source code of part 2
Project/go/sequential/main.go
```go
// CSI2520 - Programming Paradigms
// Stable Matching Project - Part 2 (Go)
// Concurrent version using goroutines and sync.Mutex
//
// Student Name: Haojian Wang
// Student Number: 300411829
//
// Algorithm: McVitie-Wilson (recursive offer/evaluate)
//
// Concurrency design:
//   - Every call to offer() is a goroutine: go offer(...)
//     This includes calls from main AND calls from inside evaluate().
//   - Each Resident has its own sync.Mutex to protect nextIdx and matchedProgram.
//   - Each Program has its own sync.Mutex to protect selectedResidents.
//   - sync.WaitGroup tracks all active goroutines.
//     wg.Add(1) is called by the SPAWNER before go offer(...).
//     defer wg.Done() is called at the TOP of offer() to cover all exit paths.
//
// Lock ordering rule (prevents deadlock):
//   We never hold a Resident lock while acquiring a Program lock.
//   offer() locks a Resident, reads nextIdx, then RELEASES the lock
//   before calling evaluate(). evaluate() then locks the Program.
//   So the order is always: Resident lock released -> Program lock acquired.
//
// Usage:
//   go run main.go <residentsFile.csv> <programsFile.csv>
// Example:
//   go run main.go residentsLarge.csv programsLarge.csv

package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

// ============================================================
// Data Types
// ============================================================

// Resident holds one applicant's data and current match state.
// mu protects nextIdx and matchedProgram from sequential modification.
type Resident struct {
	residentID     int        // unique numerical ID
	firstname      string     // given name
	lastname       string     // family name
	rol            []string   // preferred program IDs, index 0 = most preferred
	matchedProgram string     // ID of matched program; "" means unmatched
	nextIdx        int        // next program index to propose to in rol
	mu             sync.Mutex // guards nextIdx and matchedProgram
}

// Program holds one residency program's data and current match state.
// mu protects selectedResidents from sequential modification.
type Program struct {
	programID         string      // unique three-letter ID (e.g. "NRS")
	name              string      // full program name
	nPositions        int         // quota: max residents accepted
	rol               []int       // preferred resident IDs, index 0 = most preferred
	selectedResidents []int       // IDs of currently matched residents
	rankCache         map[int]int // residentID -> rank index; read-only after loading
	mu                sync.Mutex  // guards selectedResidents
}

// ============================================================
// Program helper methods
// ============================================================

// member returns true if residentID is in this program's ROL.
// rankCache is read-only after construction, so no lock needed.
func (p *Program) member(residentID int) bool {
	_, ok := p.rankCache[residentID]
	return ok
}

// rank returns the 0-based position of residentID in the program's ROL.
// Lower index = more preferred. Returns -1 if not found.
// rankCache is read-only after construction, so no lock needed.
func (p *Program) rank(residentID int) int {
	if r, ok := p.rankCache[residentID]; ok {
		return r
	}
	return -1
}

// leastPreferred returns the ID of the currently matched resident that
// this program likes least (highest rank index).
// MUST be called with p.mu held.
func (p *Program) leastPreferred() int {
	if len(p.selectedResidents) == 0 {
		return -1
	}
	worst := p.selectedResidents[0]
	worstRank := p.rank(worst)
	for _, rid := range p.selectedResidents {
		if p.rank(rid) > worstRank {
			worstRank = p.rank(rid)
			worst = rid
		}
	}
	return worst
}

// removeResident removes a resident ID from selectedResidents.
// Uses swap-with-last for O(1) removal.
// MUST be called with p.mu held.
func (p *Program) removeResident(rid int) {
	for i, id := range p.selectedResidents {
		if id == rid {
			last := len(p.selectedResidents) - 1
			p.selectedResidents[i] = p.selectedResidents[last]
			p.selectedResidents = p.selectedResidents[:last]
			return
		}
	}
}

// McVitie-Wilson Algorithm - Concurrent version

// offer picks the next untried program from resident r's ROL
// and delegates to evaluate. If the ROL is exhausted, r stays unmatched.
//
// IMPORTANT: every call to offer() is a goroutine.
// The caller does wg.Add(1) before spawning, and defer wg.Done()
// here handles all exit paths (exhausted ROL or normal delegation).
func offer(rid int, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup) {
	defer wg.Done() // covers all return paths below

	r := residents[rid]

	// Lock resident to safely read and advance the proposal pointer
	r.mu.Lock()
	if r.nextIdx >= len(r.rol) {
		// ROL exhausted: this resident stays unmatched
		r.matchedProgram = ""
		r.mu.Unlock()
		return
	}
	pid := r.rol[r.nextIdx]
	r.nextIdx++ // advance so we never propose to this program again
	r.mu.Unlock()
	// Resident lock released before calling evaluate (deadlock prevention)

	evaluate(rid, pid, residents, programs, wg)
}

// evaluate handles the proposal of resident r to program p.
// All modifications to program state happen inside p.mu.
// Subsequent offer() calls are always launched as new goroutines.
//
// Three cases:
//
//	Case 1: r is not in p's ROL            -> reject, spawn offer(r)
//	Case 2: p has room (below quota)        -> accept r
//	Case 3: p is full
//	  3a: p prefers r over weakest match   -> displace weakest, spawn offer(weakest)
//	  3b: p does not prefer r              -> reject, spawn offer(r)
func evaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup) {
	r := residents[rid]
	p := programs[pid]

	// Case 1: r is not ranked by this program at all
	// No lock needed - rankCache is read-only
	if !p.member(rid) {
		wg.Add(1)
		go offer(rid, residents, programs, wg)
		return
	}

	// Lock the program to inspect and modify selectedResidents atomically
	p.mu.Lock()

	// Case 2: program still has open positions - accept r directly
	if len(p.selectedResidents) < p.nPositions {
		p.selectedResidents = append(p.selectedResidents, rid)

		// Update resident's matched program under the resident's own lock
		r.mu.Lock()
		r.matchedProgram = pid
		r.mu.Unlock()

		p.mu.Unlock()
		return
	}

	// Case 3: program is full - compare r against the weakest current match
	lp := p.leastPreferred()

	if p.rank(rid) < p.rank(lp) {
		// Case 3a: r is more preferred than lp - displace lp and accept r

		p.removeResident(lp)
		p.selectedResidents = append(p.selectedResidents, rid)

		// Update r's match state
		r.mu.Lock()
		r.matchedProgram = pid
		r.mu.Unlock()

		// Mark displaced resident (lp) as unmatched
		lpRes := residents[lp]
		lpRes.mu.Lock()
		lpRes.matchedProgram = ""
		lpRes.mu.Unlock()

		// Release program lock BEFORE spawning goroutine
		// (never hold a lock across a goroutine boundary)
		p.mu.Unlock()

		// Displaced resident must try their next program
		wg.Add(1)
		go offer(lp, residents, programs, wg)

	} else {
		// Case 3b: p does not prefer r - r must try their next program
		p.mu.Unlock()

		wg.Add(1)
		go offer(rid, residents, programs, wg)
	}
}

// CSV Parsing

// splitCSVLine splits one CSV line into fields.
// Handles quoted fields that contain commas, e.g. "[NRS,HEP,MMI]".
func splitCSVLine(line string) []string {
	var fields []string
	var current strings.Builder
	inQuotes := false

	for _, c := range line {
		switch {
		case c == '"':
			inQuotes = !inQuotes // toggle; do not include the quote character
		case c == ',' && !inQuotes:
			fields = append(fields, current.String())
			current.Reset()
		default:
			current.WriteRune(c)
		}
	}
	fields = append(fields, current.String()) // last field
	return fields
}

// parseStringList converts "[NRS,HEP,MMI]" into []string{"NRS","HEP","MMI"}.
func parseStringList(s string) []string {
	s = strings.Trim(s, "[] \t")
	if s == "" {
		return []string{}
	}
	parts := strings.Split(s, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		t := strings.TrimSpace(p)
		if t != "" {
			result = append(result, t)
		}
	}
	return result
}

// parseIntList converts "[574,517,226]" into []int{574, 517, 226}.
func parseIntList(s string) []int {
	s = strings.Trim(s, "[] \t")
	if s == "" {
		return []int{}
	}
	parts := strings.Split(s, ",")
	result := make([]int, 0, len(parts))
	for _, p := range parts {
		t := strings.TrimSpace(p)
		if t == "" {
			continue
		}
		n, err := strconv.Atoi(t)
		if err == nil {
			result = append(result, n)
		}
	}
	return result
}

// loadResidents reads the residents CSV and returns a map of id -> *Resident.
// Expected header: id,firstname,lastname,rol
func loadResidents(filename string) (map[int]*Resident, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	residents := make(map[int]*Resident)
	scanner := bufio.NewScanner(f)

	// Increase buffer size for large files with long ROL lines
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)

	firstLine := true
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if firstLine {
			firstLine = false
			continue // skip header
		}
		if line == "" {
			continue
		}

		fields := splitCSVLine(line)
		if len(fields) < 4 {
			continue
		}

		id, err := strconv.Atoi(strings.TrimSpace(fields[0]))
		if err != nil {
			continue
		}

		residents[id] = &Resident{
			residentID: id,
			firstname:  strings.TrimSpace(fields[1]),
			lastname:   strings.TrimSpace(fields[2]),
			rol:        parseStringList(fields[3]),
			nextIdx:    0,
		}
	}
	return residents, scanner.Err()
}

// loadPrograms reads the programs CSV and returns a map of id -> *Program.
// Expected header: id,name,numberOfPos,rol
func loadPrograms(filename string) (map[string]*Program, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	programs := make(map[string]*Program)
	scanner := bufio.NewScanner(f)

	// Increase buffer size for large files
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)

	firstLine := true
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if firstLine {
			firstLine = false
			continue // skip header
		}
		if line == "" {
			continue
		}

		fields := splitCSVLine(line)
		if len(fields) < 4 {
			continue
		}

		id := strings.TrimSpace(fields[0])
		name := strings.TrimSpace(fields[1])
		quota, err := strconv.Atoi(strings.TrimSpace(fields[2]))
		if err != nil {
			continue
		}

		rolInts := parseIntList(fields[3])

		// Pre-build the rank cache - read-only after this point, no lock needed
		cache := make(map[int]int, len(rolInts))
		for i, rid := range rolInts {
			cache[rid] = i
		}

		programs[id] = &Program{
			programID:         id,
			name:              name,
			nPositions:        quota,
			rol:               rolInts,
			selectedResidents: []int{},
			rankCache:         cache,
		}
	}
	return programs, scanner.Err()
}

// ============================================================
// Output
// ============================================================

// printResults prints the stable matching to stdout in the required format.
// Sorted by lastname then firstname (alphabetical).
func printResults(residents map[int]*Resident, programs map[string]*Program) {
	list := make([]*Resident, 0, len(residents))
	for _, r := range residents {
		list = append(list, r)
	}
	sort.Slice(list, func(i, j int) bool {
		if list[i].lastname != list[j].lastname {
			return list[i].lastname < list[j].lastname
		}
		return list[i].firstname < list[j].firstname
	})

	fmt.Println("lastname,firstname,residentID,programID,name")

	unmatchedCount := 0
	for _, r := range list {
		if r.matchedProgram == "" {
			fmt.Printf("%s,%s,%d,XXX,NOT_MATCHED\n",
				r.lastname, r.firstname, r.residentID)
			unmatchedCount++
		} else {
			p := programs[r.matchedProgram]
			fmt.Printf("%s,%s,%d,%s,%s\n",
				r.lastname, r.firstname, r.residentID, p.programID, p.name)
		}
	}

	openPositions := 0
	for _, p := range programs {
		openPositions += p.nPositions - len(p.selectedResidents)
	}

	fmt.Printf("Number of unmatched residents: %d\n", unmatchedCount)
	fmt.Printf("Number of positions available: %d\n", openPositions)
}

// ============================================================
// Main
// ============================================================

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintln(os.Stderr, "Usage: go run main.go <residentsFile> <programsFile>")
		os.Exit(1)
	}

	// Load data - not included in timing as per spec
	residents, err := loadResidents(os.Args[1])
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error loading residents:", err)
		os.Exit(1)
	}

	programs, err := loadPrograms(os.Args[2])
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error loading programs:", err)
		os.Exit(1)
	}

	// --- Start timing (file I/O excluded as per spec) ---
	start := time.Now()

	var wg sync.WaitGroup

	// Launch one goroutine per resident (the main sequential loop)
	for id := range residents {
		wg.Add(1)
		go offer(id, residents, programs, &wg)
	}

	// Wait for every goroutine (initial + cascaded) to finish
	wg.Wait()

	end := time.Now()
	// --- End timing ---

	// Print output (excluded from timing as per spec)
	printResults(residents, programs)
	fmt.Printf("\nExecution time: %s\n", end.Sub(start))
}

```