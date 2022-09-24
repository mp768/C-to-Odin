#include "stdio.h"
#include "stdint.h"

#define DELLO 1 << 30

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

typedef enum {
    Some = -1,
    Enum = (DELLO),
} SomeEnum;

typedef Hello* HelloPtr;

typedef int32_t i32;

typedef int*(*INT_PROC)(const int* a, struct Hello, HelloPtr);

void func(struct { int a; } a);

typedef struct A {
    struct {
        int32_t a;
    };
} A;

int main() {
    printf("HELLO WORLD!");

    return 0;
}