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

typedef Hello* test_HelloPtr;

typedef int32_t test_i32;

typedef int*(*INT_PROC)(const int* a, struct Hello, test_HelloPtr);

typedef void****(**SOME_PROC)(struct { int b; } a);

void* test_func(struct { test_i32 a; } a);

int test_func2(int b, float d);

void test_func3(int(*ADD)(int, int), int(*SUB)(int, int));

typedef union {
    int a;
    union {
        int b;
        float c;
    };
} SUB_UNION_OMG;

typedef struct STUPID_STRUCT {
    unsigned char* str;
    void*** some_data;
    Hello hi;
} STUPID_STRUCT;

typedef struct {
    void****** SOME_MORE_DATA;
    signed char***** some_STR_Pointer;
    STUPID_STRUCT stupid;
    // bool true_or_false;
} EVEN_STUPIDER_STRUCT;

STUPID_STRUCT* test_func4(STUPID_STRUCT*** ptr);

EVEN_STUPIDER_STRUCT* test_func5(STUPID_STRUCT* ptr, int a, float b, double h);

typedef struct A {
    struct {
        int32_t a;
    };
} A;

int main() {
    printf("HELLO WORLD!");

    return 0;
}