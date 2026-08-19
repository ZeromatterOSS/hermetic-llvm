#include <emmintrin.h>

// Clang only gives __m128i vector semantics when its builtin headers retain
// the canonical lib/clang/<version>/include resource-directory layout.
__m128i combine_vectors(__m128i left, __m128i right) { return left | right; }
