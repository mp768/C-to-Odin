#include "stdio.h"
#include "stdint.h"

typedef struct There {
    int c;
} There;

typedef struct Hello {
    int a;
    int b;
    There c;

    struct {
        int d;
        int e;
    }* f;

} Hello;

typedef struct {
    const char* const str;
    Hello hi;
}* HI;

typedef Hello* HelloPtr;

typedef int32_t i32;

typedef enum {
    Some,
    Enum,
} SomeEnum;

typedef struct A {
    struct {
        int32_t a;
    };
} A;

int main() {
    printf("HELLO WORLD!");

    return 0;
}