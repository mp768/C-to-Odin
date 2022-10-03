struct Hello(T: typeid) {
	a: T,
	b: int,
}

impl Hello(T: typeid) {
    const TYPE = [3]int

	pub new() -> Self => Self { a: 3, b: 4 }

    // pub add(&self) -> int => self.a + self.b
    // pub sub(&self) -> int => self.a - self.b

    pub set_a(&mut self, a: T)   => self._set_a(a)
    pub set_b(&mut self, b: int) => self._set_b(b)

    _set_a(&mut self, a: T)   => self.a = a + 1
    _set_b(&mut self, a: int) => self.b = b + 2
}

trait HI {
    pub add(&self) -> int
    pub sub(&self) -> int       
}

impl HI for Hello {
    pub add(&self) -> int => int(self.a) + self.b
    pub sub(&self) -> int => int(self.a) - self.b 
}

fn main() {
    a := Hello(int)::new()
    

}