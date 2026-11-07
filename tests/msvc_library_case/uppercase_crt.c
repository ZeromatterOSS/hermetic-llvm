#include <stdlib.h>

// Prebuilt MSVC archives commonly request uppercase CRT library names.
#pragma comment(lib, "OLDNAMES")
#ifdef _DLL
#pragma comment(lib, "MSVCRT")
#else
#pragma comment(lib, "LIBCMT")
#endif

int main(void) {
  void *allocation = malloc(16);
  if (!allocation) return 1;
  free(allocation);
  return 0;
}
