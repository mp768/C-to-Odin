package tester
import _c_ "core:c"

SUB_CONTENT :: struct {
	a: _c_.int,
	b: _c_.int,
}

@(default_calling_convention = "c", link_prefix = "")
foreign __LIB__ {
	sub :: proc(content: ^SUB_CONTENT) -> _c_.int --- 
}

@(default_calling_convention = "c", link_prefix = "test_")
foreign __LIB__ {
	add :: proc(a: _c_.int, b: _c_.int) -> _c_.int --- 
}

