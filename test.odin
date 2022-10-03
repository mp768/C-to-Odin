package testerv3
import _c_ "core:c"

when ODIN_OS == .Windows {
	foreign import __LIB__ "S"
} else when ODIN_OS == .Linux {
	foreign import __LIB__ "S"
} else when ODIN_OS == .Darwin {
	foreign import __LIB__ "S"
}

