package main

import (
	"math"
)

// Haojian Wang, 300411829
// floorCeil32 takes a float32 number x and returns:
// 1) the floor value of x as an int
// 2) the ceil  value of x as an int

func floorCeil32(x float32) (int, int) {
	xf := float64(x)

	floorVal := math.Floor(xf)
	ceilVal := math.Ceil(xf)

	return int(floorVal), int(ceilVal)
}
