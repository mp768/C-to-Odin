package test
import __CORE__C__TYPE__LITERAL__ "core:c"

There :: distinct struct { // Struct "There"
	c: __CORE__C__TYPE__LITERAL__.int,
}

Hello :: distinct struct { // Struct "Hello"
	a: __CORE__C__TYPE__LITERAL__.int,
	b: __CORE__C__TYPE__LITERAL__.int,
	c: There,
	f: ^struct {
		d: __CORE__C__TYPE__LITERAL__.int,
		e: __CORE__C__TYPE__LITERAL__.int,
	},
}

HI :: distinct struct {
	str: ^__CORE__C__TYPE__LITERAL__.char,
	hi: Hello,
}

HelloPtr :: distinct ^Hello

i32 :: distinct i32

A :: struct { // Struct "A"
	_: struct {
		a: i32,
	},
}

