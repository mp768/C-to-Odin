package main 

import "core:fmt"

HI :: ^struct {
    hi: ^int,
}

main :: proc() {
    a := new(struct { hi: ^int })

    b: HI = a

    fmt.println(b);
}