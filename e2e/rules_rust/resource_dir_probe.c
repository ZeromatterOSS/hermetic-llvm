#include <stdarg.h>

int sum_values(int count, ...) {
    va_list values;
    int sum = 0;

    va_start(values, count);
    for (int i = 0; i < count; ++i) {
        sum += va_arg(values, int);
    }
    va_end(values);

    return sum;
}
