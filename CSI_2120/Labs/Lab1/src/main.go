package main

import "fmt"

func main() {

	// question 1
	// Test values:
	// 1) positive non-integer
	// 2) negative non-integer (important for correct floor/ceil behavior)
	// 3) exact integers
	fmt.Println("This is the test main method of lab1 \n" +
		"Question 1")
	tests := []float32{3.14, -2.3, 5.0, -7.0, 0.0}

	for _, x := range tests {
		f, c := floorCeil32(x)
		fmt.Printf("x = %-6v  floor(x) = %-3d  ceil(x) = %-3d\n", x, f, c)
	}

	// Question 2
	// Create a slice with an explicit capacity so we can clearly verify the capacity requirement.
	// Here: len=0, cap=10 after make, then we append values.
	fmt.Println("\nQuestion 2")
	nums := make([]int, 0, 10)
	nums = append(nums, -3, 0, 5, -1, 9, -8, 2)

	// Call the function.
	positives := keepPositives(nums)

	// Print to demonstrate:
	// 1) negatives removed
	// 2) only positives kept (0 is not included)
	// 3) capacity is the same as the original slice
	fmt.Println("Original slice:", nums)
	fmt.Printf("Original len=%d cap=%d\n", len(nums), cap(nums))

	fmt.Println("Result slice (only positives):", positives)
	fmt.Printf("Result   len=%d cap=%d\n", len(positives), cap(positives))

	fmt.Println("\nQuestion 3")
	// Question 3
	// Build the exact tree shown in the question.
	// Root: (2,3)
	tree := PtTree{
		pt: Point{2, 3},
		left: &PtTree{
			pt: Point{5, 1},
			left: &PtTree{
				pt:    Point{2, 2},
				left:  nil,
				right: nil,
			},
			right: &PtTree{
				pt: Point{8, 3},
				left: &PtTree{
					pt:    Point{1, 6},
					left:  nil,
					right: nil,
				},
				right: nil,
			},
		},
		right: &PtTree{
			pt: Point{4, 7},
			left: &PtTree{
				pt: Point{7, 2},
				left: &PtTree{
					pt:    Point{6, 4},
					left:  nil,
					right: nil,
				},
				right: &PtTree{
					pt:    Point{0, 9},
					left:  nil,
					right: nil,
				},
			},
			right: &PtTree{
				pt:    Point{3, 6},
				left:  nil,
				right: nil,
			},
		},
	}

	// I) Post-order print
	tree.postorder()
	fmt.Println("") // newline after traversal output

	// III) Interface variable (NOT a pointer to an interface)
	var ps PointSearcher
	ps = &tree // *PtTree implements find(x,y)

	// II) Search (7,2) -> expected Found
	u, v := 7, 2
	if ps.find(u, v) {
		fmt.Printf("Found: %d %d\n", u, v)
	} else {
		fmt.Printf("Not Found\n")
	}

	// II) Search (8,6) -> expected Not Found
	x, y := 8, 6
	if ps.find(x, y) {
		fmt.Printf("Found: %d %d\n", x, y)
	} else {
		fmt.Printf("Not Found\n")
	}
}
