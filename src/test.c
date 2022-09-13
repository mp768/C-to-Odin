#include "stdio.h"

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

typedef struct HI {
    Hello hi;
}* HI;

typedef Hello* HelloPtr;

typedef enum {
    Some,
    Enum,
} SomeEnum;

typedef struct A {
    struct {
        int a;
    };
} A;

int main() {
    printf("HELLO WORLD!");

    return 0;
}