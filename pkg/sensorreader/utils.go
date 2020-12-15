package sensorreader

func MinMax(a []float64) (float64, float64) {
	var min float64 = 0
	var max float64 = 0
	for _, item := range a {
		if item > max {
			max = item
		}
		if item < min {
			min = item
		}
	}
	return min, max
}
