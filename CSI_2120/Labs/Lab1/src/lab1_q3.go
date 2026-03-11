package main

import "fmt"

type Point struct {
	x int
	y int
}

type PtTree struct {
	pt          Point
	left, right *PtTree
}

func (t *PtTree) postorder() {
	if t == nil {
		return
	}

	t.left.postorder()

	t.right.postorder()

	fmt.Printf("(%d,%d) ", t.pt.x, t.pt.y)
}

func (t *PtTree) find(x, y int) bool {
	if t == nil {
		return false
	}

	if t.pt.x == x && t.pt.y == y {
		return true
	}

	return t.left.find(x, y) || t.right.find(x, y)
}

type PointSearcher interface {
	find(x, y int) bool
}
