package testerV5
import _c_ "core:c"

when ODIN_OS == .Windows {
	foreign import __LIB__ "L"
} else when ODIN_OS == .Linux {
	foreign import __LIB__ "L"
} else when ODIN_OS == .Darwin {
	foreign import __LIB__ "L"
}

SUB_CONTENT :: struct {
	a: _c_.int,
	b: _c_.int,
}

@(default_calling_convention = "c")
foreign __LIB__ {
	sub :: proc(content: ^SUB_CONTENT) -> _c_.int --- 
}

