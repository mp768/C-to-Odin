# C-to-Odin
 An odin binding generator that parses c header files into ***hopefully most of the time*** valid odin bindings to a library

# What is currently going on with the project?
 Currently I do not have motivation nor interest in doing this project anymore (at least for now). I am archiving it so that you can still view the code and modify it, but I  don't feel obliged to make changes to it. You can apply whatever changes you need on your own or continue it somewhere else.  

# What can it do?
 Currently it supports the ability to convert most of a header correctly, it fails to pull in c system headers, but that is by design as we don't want to pull the whole c stdlib everytime we convert a header. It currently doesn't support macro parsing, so no macro constants with magic values will be converted, and is probably something that will have to be implemented via a handmade parser for the c preprocessor. It also tries to avoid naming conflicts with keywords found in odin, but not found in c, such as `in`, `not_in`, `i32`, `u32`, `f32`, etc.

# Issues with the code
 The code is written heavily in macros currently, which is not in standard c++ style and features a monstrosity of `If a == 2 Then /* do something */ End` in pascal style of writing code. But it's something that can be easily gotten rid of with a find and replace feature in your editor of choice. 
 
