#pragma once

// The name of this file is a lie, none of this is essential, but it does help me do a style I like more

#define ptr *
#define ref &
#define deref *
#define var auto
#define let const auto
#define in :
#define Enum enum class
// this macro is just for consistency
#define Struct struct
#define Begin {
#define For for (
#define While while (
#define Switch switch (
#define If if ( 
#define Then ) {
#define Elif } else if ( 
#define Else } else {
#define End }
#define EndCase End break;
#define EndRecord End;
#define Case(...) case __VA_ARGS__: Begin
#define function static inline var
#define cast(type, expr) ((type)(expr))
#define letd(T) const T