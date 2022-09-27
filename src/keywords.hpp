#pragma once

#include <unordered_map>
#include <string>

#define __C_TYPE_LITERAL "_c_"

std::unordered_map<std::string, std::string> c_keyword_to_odin = {
    { "int", __C_TYPE_LITERAL ".int" },
    { "signed", __C_TYPE_LITERAL ".int" },
    { "unsigned int", __C_TYPE_LITERAL ".uint" },

    { "char", __C_TYPE_LITERAL ".char" },
    { "signed char", __C_TYPE_LITERAL ".schar" },
    { "unsigned char", __C_TYPE_LITERAL ".uchar" },

    { "short", __C_TYPE_LITERAL ".short" },
    { "signed short", __C_TYPE_LITERAL ".short" },
    { "unsigned short", __C_TYPE_LITERAL ".ushort" },

    { "long", __C_TYPE_LITERAL ".long" },
    { "signed long", __C_TYPE_LITERAL ".long" },
    { "unsigned long", __C_TYPE_LITERAL ".ulong" },

    { "long long", __C_TYPE_LITERAL ".longlong" },
    { "signed long long", __C_TYPE_LITERAL ".longlong" },
    { "unsigned long long", __C_TYPE_LITERAL ".ulonglong" },

    { "float", __C_TYPE_LITERAL ".float" },
    { "double", __C_TYPE_LITERAL ".double" },

    { "size_t", __C_TYPE_LITERAL ".size_t" },
    { "signed size_t", __C_TYPE_LITERAL ".ssize_t" },
    { "wchar_t", __C_TYPE_LITERAL ".wchar_t" },

    { "int8_t", "i8" },
    { "uint8_t", "u8" },
    { "int16_t", "i16" },
    { "uint16_t", "u16" },
    { "int32_t", "i32" },
    { "uint32_t", "u32" },
    { "int64_t", "i64" },
    { "uint64_t", "u64" },

    { "int_fast8_t", __C_TYPE_LITERAL ".int_fast8_t" },
    { "uint_fast8_t", __C_TYPE_LITERAL ".uint_fast8_t" },
    { "int_fast16_t", __C_TYPE_LITERAL ".int_fast16_t" },
    { "uint_fast16_t", __C_TYPE_LITERAL ".uint_fast16_t" },
    { "int_fast32_t", __C_TYPE_LITERAL ".int_fast32_t" },
    { "uint_fast32_t", __C_TYPE_LITERAL ".uint_fast32_t" },
    { "int_fast64_t", __C_TYPE_LITERAL ".int_fast64_t" },
    { "uint_fast64_t", __C_TYPE_LITERAL ".uint_fast64_t" },

    { "int_least8_t", __C_TYPE_LITERAL ".int_least8_t" },
    { "uint_least8_t", __C_TYPE_LITERAL ".uint_least8_t" },
    { "int_least16_t", __C_TYPE_LITERAL ".int_least16_t" },
    { "uint_least16_t", __C_TYPE_LITERAL ".uint_least16_t" },
    { "int_least32_t", __C_TYPE_LITERAL ".int_least32_t" },
    { "uint_least32_t", __C_TYPE_LITERAL ".uint_least32_t" },
    { "int_least64_t", __C_TYPE_LITERAL ".int_least64_t" },
    { "uint_least64_t", __C_TYPE_LITERAL ".uint_least64_t" },

    { "intptr_t", __C_TYPE_LITERAL ".intptr_t" },
    { "uintptr_t", __C_TYPE_LITERAL ".uintptr_t" },
    { "ptrdiff_t", __C_TYPE_LITERAL ".ptrdiff_t" },

    { "intmax_t", "__CORE_C_LITERAL__.intmax_t" },
    { "uintmax_t", "__CORE_C_LITERAL__.uintmax_t" },
};

std::unordered_map<std::string, void*> unallowed_keywords_in_odin = {
    { "i8", nullptr },
    { "i16", nullptr },
    { "i32", nullptr },
    { "i64", nullptr },

    { "u8", nullptr },
    { "u16", nullptr },
    { "u32", nullptr },
    { "u64", nullptr },

    { "f32", nullptr },
    { "f64", nullptr },
    { "f128", nullptr },

    { "string", nullptr },
    { "cstring", nullptr },

    { "in", nullptr },
    { "not_in", nullptr },
    { "import", nullptr },
    { "foreign", nullptr },
    { "proc", nullptr },
    { "package", nullptr },
};