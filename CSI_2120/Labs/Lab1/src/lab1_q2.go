package main

// Haojian Wang

func keepPositives(nums []int) []int {
	result := make([]int, 0, cap(nums))

	for _, v := range nums {
		if v > 0 {
			result = append(result, v)
		}
	}

	return result
}
