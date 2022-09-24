package test
import __ODIN_CORE_C__ "core:c"

There :: struct { // Struct "There"
	c: __ODIN_CORE_C__.int,
}

Hello :: struct { // Struct "Hello"
	a: __ODIN_CORE_C__.int,
	b: __ODIN_CORE_C__.int,
	c: There,
	f: ^struct {
		d: __ODIN_CORE_C__.int,
		e: __ODIN_CORE_C__.int,
	},
}

HI :: struct {
	str: ^__ODIN_CORE_C__.char,
	hi: Hello,
}

SomeEnum :: enum {
	Some = -1,
	Enum = 1073741824,
}

HelloPtr :: distinct ^Hello

i32_t :: distinct i32

INT_PROC :: distinct proc(^__ODIN_CORE_C__.int, Hello, HelloPtr) -> ^__ODIN_CORE_C__.int

A :: struct { // Struct "A"
	using _: struct {
		a: i32,
	},
}

