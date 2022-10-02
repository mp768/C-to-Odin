#include "stdio.h"
#include "stdint.h"

#define DELLO 1 << 30

typedef struct There {
    int c;
} There;

struct JOOO;

struct JOOO {
    double a;
    int64_t b;
};

// this is hello
typedef struct Hello {
    int a[1][2];
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

typedef int32_t test_i32[1][3][4];

typedef int*(*INT_PROC)(const int*[3], struct Hello[2], test_HelloPtr);

// THIS IS SOME_PROC, THIS FUNCTION DOES SOMETHING
// I REALLY DON'T KNOW WHAT IT DOES, BUT IT DOES
// SOMETHING I GUESS
/*
* MULTI-LINE COMMENT
* WOOOWOWOWOOW
* IT'S AMAZING !!??!?!?!?!??!?!?!?
*/
typedef void****(**SOME_PROC)(struct { int b; }* a);

// func
void* test_func(struct { test_i32 a; } a);

// func2
int test_something_func2(int b, float d);

// THIS IS BOUND TO SOMETHING I JUST IDK WHAT
// this does something so cool
// you just got to see it.
void something_test_func3(int(*ADD)(int, int), int(*SUB)(int, int));

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

// func4
// what the func4
STUPID_STRUCT* test_func4(STUPID_STRUCT*** ptr);

// func5
// what the func5
EVEN_STUPIDER_STRUCT* test_func5(STUPID_STRUCT* ptr[2], int a, float b, double h);

// TYPEDEF A IS A BUNCH OF A
typedef struct A {
    struct {
        int32_t a;
        float vec3[3];
    };
} A;

int main() {
    printf("HELLO WORLD!");

    return 0;
}