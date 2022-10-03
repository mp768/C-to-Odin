package testerV4
import _c_ "core:c"

when ODIN_OS == .Windows {
	foreign import __LIB__ "D"
} else when ODIN_OS == .Linux {
	foreign import __LIB__ "D"
} else when ODIN_OS == .Darwin {
	foreign import __LIB__ "D"
}

There :: struct {
	c: _c_.int,
}

// this is hello
Hello :: [1][2]^^struct {
	a: [2][1]_c_.int,
	b: _c_.int,
	c: There,
	f: ^struct {
		d: _c_.int,
		e: _c_.int,
	},
}

HI :: ^struct {
	str: cstring,
	hi: Hello,
}

SomeEnum :: enum {
	Some = -1,
	Enum = 1073741824,
}

HelloPtr :: distinct ^Hello

i32_t :: distinct [4][3][1]i32

INT_PROC :: distinct [2]proc([3]^_c_.int, [2]Hello, HelloPtr) -> ^_c_.int

// THIS IS SOME_PROC, THIS FUNCTION DOES SOMETHING
// I REALLY DON'T KNOW WHAT IT DOES, BUT IT DOES
// SOMETHING I GUESS
/*
* MULTI-LINE COMMENT
* WOOOWOWOWOOW
* IT'S AMAZING !!??!?!?!?!??!?!?!?
*/
SOME_PROC :: distinct ^proc(^struct { b: _c_.int, }) -> ^^^rawptr

SUB_UNION_OMG :: struct #raw_union {
	a: _c_.int,
	using _: struct #raw_union {
		b: _c_.int,
		c: _c_.float,
	},
}

STUPID_STRUCT :: struct {
	str: ^_c_.uchar,
	some_data: ^^rawptr,
	hi: Hello,
}

EVEN_STUPIDER_STRUCT :: struct {
	SOME_MORE_DATA: ^^^^^rawptr,
	some_STR_Pointer: ^^^^^_c_.schar,
	stupid: STUPID_STRUCT,
}

// TYPEDEF A IS A BUNCH OF A
A :: struct {
	using _: struct {
		a: i32,
		vec3: [3]_c_.float,
	},
}

SUB_CONTENT :: struct {
	a: _c_.int,
	b: _c_.int,
}

JOOO :: struct {
	a: _c_.double,
	b: i64,
}

@(default_calling_convention = "c", link_prefix = "test_")
foreign __LIB__ {
	// func
	func :: proc(a: struct { a: i32_t, }) -> rawptr --- 
	// func4
	// what the func4
	func4 :: proc(ptr: ^^^STUPID_STRUCT) -> ^STUPID_STRUCT --- 
	// func5
	// what the func5
	func5 :: proc(ptr: [2]^STUPID_STRUCT, a: _c_.int, b: _c_.float, h: _c_.double) -> ^EVEN_STUPIDER_STRUCT --- 
	add :: proc(a: _c_.int, b: _c_.int) -> _c_.int --- 
}

@(default_calling_convention = "c", link_prefix = "test_something_")
foreign __LIB__ {
	// func2
	func2 :: proc(b: _c_.int, d: _c_.float) -> _c_.int --- 
}

@(default_calling_convention = "c")
foreign __LIB__ {
	sub :: proc(content: ^SUB_CONTENT) -> _c_.int --- 
}

@(default_calling_convention = "c", link_prefix = "something_test_")
foreign __LIB__ {
	// THIS IS BOUND TO SOMETHING I JUST IDK WHAT
	// this does something so cool
	// you just got to see it.
	func3 :: proc(ADD: proc(_c_.int, _c_.int) -> _c_.int, SUB: proc(_c_.int, _c_.int) -> _c_.int) --- 
}

