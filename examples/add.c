#include <stdint.h>

int main(void) {
    volatile uint64_t a = 2;
    volatile uint64_t b = 3;
    volatile uint64_t c = a + b;
    return (int)c;
}
