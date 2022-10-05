package dyncall
import _c_ "core:c"

when ODIN_OS == .Windows {
	foreign import __LIB__ "libdyncall.lib"
} else when ODIN_OS == .Linux {
	foreign import __LIB__ "S"
} else when ODIN_OS == .Darwin {
	foreign import __LIB__ "D"
}

DCbool :: distinct _c_.int

DCchar :: distinct _c_.char

DCuchar :: distinct _c_.uchar

DCshort :: distinct _c_.short

DCushort :: distinct _c_.ushort

DCint :: distinct _c_.int

DCuint :: distinct _c_.uint

DClong :: distinct _c_.long

DCulong :: distinct _c_.ulong

DClonglong :: distinct _c_.longlong

DCulonglong :: distinct _c_.ulonglong

DCfloat :: distinct _c_.float

DCdouble :: distinct _c_.double

DCpointer :: distinct rawptr

DCstring :: distinct cstring

DCsize :: distinct _c_.size_t

DCsigchar :: distinct _c_.char

DCCallVM :: struct {}

DCstruct :: struct {}
DC :: DCstruct

DCCallVM_ :: struct {}

DCstruct_ :: struct {}

@(default_calling_convention = "c", link_prefix = "dc")
foreign __LIB__ {
	NewCallVM :: proc(size: DCsize) -> ^DCCallVM --- 
	Free :: proc(vm: ^DCCallVM) --- 
	Reset :: proc(vm: ^DCCallVM) --- 
	Mode :: proc(vm: ^DCCallVM, mode: DCint) --- 
	ArgBool :: proc(vm: ^DCCallVM, value: DCbool) --- 
	ArgChar :: proc(vm: ^DCCallVM, value: DCchar) --- 
	ArgShort :: proc(vm: ^DCCallVM, value: DCshort) --- 
	ArgInt :: proc(vm: ^DCCallVM, value: DCint) --- 
	ArgLong :: proc(vm: ^DCCallVM, value: DClong) --- 
	ArgLongLong :: proc(vm: ^DCCallVM, value: DClonglong) --- 
	ArgFloat :: proc(vm: ^DCCallVM, value: DCfloat) --- 
	ArgDouble :: proc(vm: ^DCCallVM, value: DCdouble) --- 
	ArgPointer :: proc(vm: ^DCCallVM, value: DCpointer) --- 
	ArgStruct :: proc(vm: ^DCCallVM, s: ^DC, value: DCpointer) --- 
	CallVoid :: proc(vm: ^DCCallVM, funcptr: DCpointer) --- 
	CallBool :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DCbool --- 
	CallChar :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DCchar --- 
	CallShort :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DCshort --- 
	CallInt :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DCint --- 
	CallLong :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DClong --- 
	CallLongLong :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DClonglong --- 
	CallFloat :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DCfloat --- 
	CallDouble :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DCdouble --- 
	CallPointer :: proc(vm: ^DCCallVM, funcptr: DCpointer) -> DCpointer --- 
	CallStruct :: proc(vm: ^DCCallVM, funcptr: DCpointer, s: ^DC, returnValue: DCpointer) --- 
	GetError :: proc(vm: ^DCCallVM) -> DCint --- 
	NewStruct :: proc(fieldCount: DCsize, alignment: DCint) -> ^DC --- 
	StructField :: proc(s: ^DC, type: DCint, alignment: DCint, arrayLength: DCsize) --- 
	SubStruct :: proc(s: ^DC, fieldCount: DCsize, alignment: DCint, arrayLength: DCsize) --- 
	/* Each dcNewStruct or dcSubStruct call must be paired with a dcCloseStruct. */
	CloseStruct :: proc(s: ^DC) --- 
	StructSize :: proc(s: ^DC) -> DCsize --- 
	StructAlignment :: proc(s: ^DC) -> DCsize --- 
	FreeStruct :: proc(s: ^DC) --- 
	DefineStruct :: proc(signature: cstring) -> ^DC --- 
	/* returns respective mode for callconv sig char (w/o checking if mode exists */
	/* on current platform), or DC_ERROR_UNSUPPORTED_MODE if char isn't a sigchar */
	GetModeFromCCSigChar :: proc(sig_char: DCsigchar) -> DCint --- 
}

