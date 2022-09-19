package test
import __CORE__C__TYPE__LITERAL__ "core:c"

There :: struct { // Struct "There"
	c: __CORE__C__TYPE__LITERAL__.int,
}

Hello :: struct { // Struct "Hello"
	a: __CORE__C__TYPE__LITERAL__.int,
	b: __CORE__C__TYPE__LITERAL__.int,
	c: There,
	f: ^struct {
		d: __CORE__C__TYPE__LITERAL__.int,
		e: __CORE__C__TYPE__LITERAL__.int,
	},
}

HI :: struct {
	str: ^__CORE__C__TYPE__LITERAL__.char,
	hi: Hello,
}

HelloPtr :: distinct ^Hello

i32_t :: distinct i32

A :: struct { // Struct "A"
	using _: struct {
		a: i32,
	},
}

