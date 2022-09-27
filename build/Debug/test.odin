package tester
import _c_ "core:c"

There :: struct { // Struct "There"
	c: _c_.int,
}

Hello :: struct { // Struct "Hello"
	a: _c_.int,
	b: _c_.int,
	c: There,
	f: ^struct {
		d: _c_.int,
		e: _c_.int,
	},
}

HI :: struct {
	str: cstring,
	hi: Hello,
}

SomeEnum :: enum {
	Some = -1,
	Enum = 1073741824,
}

HelloPtr :: distinct ^Hello

i32_t :: distinct i32

INT_PROC :: distinct proc(^_c_.int, Hello, HelloPtr) -> ^_c_.int

SOME_PROC :: struct {
	b: _c_.int,
}

STUPID_STRUCT :: struct { // Struct "STUPID_STRUCT"
	str: ^_c_.uchar,
	some_data: ^^rawptr,
	hi: Hello,
}

EVEN_STUPIDER_STRUCT :: struct {
	SOME_MORE_DATA: ^^^^^rawptr,
	some_STR_Pointer: ^^^^^_c_.schar,
	stupid: STUPID_STRUCT,
}

A :: struct { // Struct "A"
	using _: struct {
		a: i32,
	},
}

func :: proc(a: struct { a: i32_t, }) -> rawptr --- 

func2 :: proc(b: _c_.int, d: _c_.float) -> _c_.int --- 

func3 :: proc(ADD: proc(_c_.int, _c_.int) -> _c_.int, SUB: proc(_c_.int, _c_.int) -> _c_.int) --- 

func4 :: proc(ptr: ^^^STUPID_STRUCT) -> ^STUPID_STRUCT --- 

func5 :: proc(ptr: ^STUPID_STRUCT, a: _c_.int, b: _c_.float, h: _c_.double) -> ^EVEN_STUPIDER_STRUCT --- 

add :: proc(a: _c_.int, b: _c_.int) -> _c_.int --- 

