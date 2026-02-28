// Sequential / Single-Threaded
// Student Name: Haojian Wang
// Student Number: 300411829

// For notes:
//  	Algorithm: McVitie-Wilson, recursive offer/evaluate

// NO goroutines, NO mutexes

package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
	"time"
)

// Data Types
// resident holds one applicant's data and current match state.
type Resident struct {
	residentID     int
	firstname      string
	lastname       string
	rol            []string
	matchedProgram string
	nextIdx        int
}

type Program struct {
	programID         string
	name              string
	nPositions        int
	rol               []int
	selectedResidents []int
	rankCache         map[int]int
}

// Program helper methods
func (p *Program) member(residentID int) bool {
	_, ok := p.rankCache[residentID]
	return ok
}

// rank returns the 0-based position of residentID in the program's ROL.
// Lower index = more preferred. Returns -1 if not found.
func (p *Program) rank(residentID int) int {
	if r, ok := p.rankCache[residentID]; ok {
		return r
	}
	return -1
}

// leastPreferred returns the ID of the currently matched resident that
// this program likes least (highest rank index among matched residents).
// Returns -1 if no residents are matched yet.
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

// removeResident removes a resident ID from selectedResident
// sue swap-with-last trick for O(1) removal.
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

// Main method: McVitie-Wilson Algorithm - Sequential version

// offer picks the next untried program from resident "r"'s ROL
// delegates evaluate. if the ROL is exhausted, r stays unmatch
// one half of the mutual recursion: offer -> evaluate -> offer -> ...
func offer(rid int, residents map[int]*Resident, programs map[string]*Program) {
	r := residents[rid]

	// Check if resident has exhausted all programs on their list
	if r.nextIdx >= len(r.rol) {
		r.matchedProgram = "" // stays unmatched
		return
	}

	// Take the next program from the resident's ROL
	pid := r.rol[r.nextIdx]
	r.nextIdx++ // advance pointer so we never propose here again

	evaluate(rid, pid, residents, programs)
}

// evaluate handles the proposal of resident r to program p.
// It implements the three McVitie-Wilson cases:
//
//	Case 1: r is not in p's ROL           -> reject, call offer(r) again
//	Case 2: p has room (below quota)       -> accept r
//	Case 3: p is full
//	  3a: p prefers r over weakest match  -> displace weakest, call offer(weakest)
//	  3b: p does not prefer r             -> reject, call offer(r) again
func evaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program) {
	r := residents[rid]
	p := programs[pid]

	// Case 1: program did not rank this resident at all
	if !p.member(rid) {
		offer(rid, residents, programs)
		return
	}

	// Case 2: program still has open positions
	if len(p.selectedResidents) < p.nPositions {
		p.selectedResidents = append(p.selectedResidents, rid)
		r.matchedProgram = pid
		return
	}

	// Case 3: program is full - compare r with weakest current match
	lp := p.leastPreferred()

	if p.rank(rid) < p.rank(lp) {
		// Case 3a: r is more preferred than lp - displace lp
		p.removeResident(lp)
		p.selectedResidents = append(p.selectedResidents, rid)
		r.matchedProgram = pid

		// lp is now unmatched and must try their next program
		residents[lp].matchedProgram = ""
		offer(lp, residents, programs)
	} else {
		// Case 3b: p does not prefer r - r must try their next program
		offer(rid, residents, programs)
	}
}

// CSV Parsing
// splitCSVLine splits one CSV line into fields.
// It correctly handles quoted fields that contain commas,
// for example the ROL column: "[NRS,HEP,MMI]"
func splitCSVLine(line string) []string {
	var fields []string
	var current strings.Builder
	inQuotes := false

	for _, c := range line {
		switch {
		case c == '"':
			inQuotes = !inQuotes // toggle; do not include the quote character itself
		case c == ',' && !inQuotes:
			fields = append(fields, current.String())
			current.Reset()
		default:
			current.WriteRune(c)
		}
	}
	fields = append(fields, current.String()) // last field has no trailing comma
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

// loadResidents reads the residents CSV file and returns a map of id -> *Resident.
// Expected CSV header: id,firstname,lastname,rol
func loadResidents(filename string) (map[int]*Resident, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	residents := make(map[int]*Resident)
	scanner := bufio.NewScanner(f)

	// Increase scanner buffer for large files where ROL lines can be very long
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)

	firstLine := true
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if firstLine {
			firstLine = false
			continue // skip header row
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

// loadPrograms reads the programs CSV file and returns a map of id -> *Program.
// Expected CSV header: id,name,numberOfPos,rol
func loadPrograms(filename string) (map[string]*Program, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	programs := make(map[string]*Program)
	scanner := bufio.NewScanner(f)

	// Increase scanner buffer for large files
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)

	firstLine := true
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if firstLine {
			firstLine = false
			continue // skip header row
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

		// Pre-build rank cache: residentID -> rank index (0-based)
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

// Output

// printResults prints the stable matching to stdout in the required format.
// Residents are sorted alphabetically by lastname, then by firstname.
func printResults(residents map[int]*Resident, programs map[string]*Program) {
	// Collect all residents into a slice for sorting
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
			// Unmatched resident uses XXX and NOT_MATCHED as per spec
			fmt.Printf("%s,%s,%d,XXX,NOT_MATCHED\n",
				r.lastname, r.firstname, r.residentID)
			unmatchedCount++
		} else {
			p := programs[r.matchedProgram]
			fmt.Printf("%s,%s,%d,%s,%s\n",
				r.lastname, r.firstname, r.residentID, p.programID, p.name)
		}
	}

	// Count remaining open positions across all programs
	openPositions := 0
	for _, p := range programs {
		openPositions += p.nPositions - len(p.selectedResidents)
	}

	fmt.Printf("Number of unmatched residents: %d\n", unmatchedCount)
	fmt.Printf("Number of positions available: %d\n", openPositions)
}

// Main

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintln(os.Stderr, "Usage: go run main.go <residentsFile> <programsFile>")
		os.Exit(1)
	}

	// Load CSV files (not included in execution time measurement per spec)
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

	// --- Start timing (I/O excluded as per spec) ---
	start := time.Now()

	// McVitie-Wilson main loop: call offer() once for every resident
	for id := range residents {
		offer(id, residents, programs)
	}

	end := time.Now()
	// --- End timing ---

	// Print results and execution time (console output not timed)
	printResults(residents, programs)
	fmt.Printf("\nExecution time: %s\n", end.Sub(start))
}
