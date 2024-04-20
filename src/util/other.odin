package util

import "core:math"

ceil_div :: #force_inline proc(a, b: $T) -> T {
	return auto_cast math.ceil(cast(f32)a / auto_cast b)
}
