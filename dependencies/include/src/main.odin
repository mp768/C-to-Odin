package main

import "core:fmt"
import clang "../clang"

main :: proc() {
    idx := clang.createIndex(0, 1)

    tu := clang.parseTranslationUnit(idx, "C:/Users/mp725/OneDrive/Documents/Game Dev/C/C to Odin/src/test.c", nil, 0, nil, 0, 0)

    fmt.println("RESULT: ", uintptr(tu))

    if !bool(uintptr(tu)) do return

    root_cursor := clang.getTranslationUnitCursor(tu)

    fmt.println(root_cursor.kind, "data:", root_cursor.data);
}