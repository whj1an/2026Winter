package mathx

// sumDigits returns the sum of decimal digits of n.
// Example: 1729 -> 1+7+2+9 = 19
// return <int>
func sumDigits(n int) int {
	if n < 0 {
		n = -n
	}

	s := 0
	for n > 0 {
		s += n % 10
		n /= 10
	}
	return s
}

// IsHarshad
func IsHarshad(n int) bool {
	if n <= 0 {
		return false
	}

	s := sumDigits(n)
	if s == 0 {
		return false
	}

	return n%s == 0
}
