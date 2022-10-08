#pragma once
#include <string>
#include <vector>
#include <tuple>
#include <optional>
#include <clang-c/Index.h>
#include <unordered_map>
#include <variant>
#include "essential_macros.hpp"

Enum FieldType Begin
    STRUCT,
    ENUM,
EndRecord

Struct TypeNamed Begin
    std::string type_name;
    CXType type;
    std::vector<int> array_sizes;
EndRecord

Struct TypeNotNamed Begin
    size_t index;
    FieldType type;
    int pointer_level;
    std::vector<int> array_sizes;
EndRecord

Struct StructField Begin
    bool is_type_named;

    TypeNamed type_named;

    // this will be used if the type of a field is a anonymous or declared struct inside the parent struct.
    TypeNotNamed type_not_named;

    std::vector<std::string> comment_text;

    std::string name;
EndRecord

Struct StructDecl Begin
    std::string name;
    std::vector<StructField> fields;
    std::vector<std::string> comment_text;
    bool is_union;
EndRecord

Struct EnumDecl Begin
    std::string name;
    // CONSTANT_NAME = IS NEGATIVE, VALUE // COMMENT
    std::vector<std::tuple<std::string, bool, uint64_t, std::vector<std::string>>> constants; 
    std::vector<std::string> comment_text;
EndRecord

Struct Argument Begin
    std::variant<TypeNamed, TypeNotNamed> type;
    std::string name;
EndRecord

Struct FunctionDecl Begin
    std::string name;

    std::variant<TypeNamed, TypeNotNamed> return_type;
    std::vector<std::string> comment_text;

    std::vector<Argument> arguments;
EndRecord

Struct TypeDef Begin
    std::string name;

    // refers to whether a struct or enum is type defined anonymously 
    bool anonymous;
    unsigned int pointer_level;
    StructDecl struct_decl;
    EnumDecl enum_decl;
    CXType type;
    CXCursor cursor;
    bool is_proc_type;
    std::vector<int> array_sizes;

    std::vector<std::string> comment_text;

    Enum IS Begin
        STRUCT,
        ENUM,
        NEITHER
    End is;

    std::string type_name;
EndRecord

Struct DataEntry Begin
    Enum IS Begin
        STRUCT,
        ENUM,
        UNION,
        TYPEDEF,
        FUNCTION,
        CONSTANT,
        NONE,
    End is;

    std::string constant_string;
    CXCursor cursor;
    std::string name;
EndRecord

Struct DataQueue Begin
    std::vector<DataEntry> data;
EndRecord

Struct SaveData Begin
    std::vector<StructDecl> struct_decls;
    std::vector<EnumDecl> enum_decls;
    std::vector<FunctionDecl> function_decls;
    std::vector<TypeDef> type_defs;
    std::vector<std::tuple<std::string, std::string>> macro_constants;
    std::vector<std::string> remove_prefixes;
    std::vector<std::string> remove_constant_prefixes;
    std::vector<std::string> include_paths;
    std::unordered_map<std::string, std::string> type_names;
    void* current_data;
    
    std::vector<CXIndex> idxs;
    std::vector<CXTranslationUnit> tus;

    bool convert_char_pointer_to_cstring;
    bool seperate_files;
    std::string package_name;
    std::string windows_library_path;
    std::string linux_library_path;
    std::string mac_library_path;

    size_t recursion_level;

    SaveData() 
    Begin
        struct_decls.reserve(8);
        type_defs.reserve(8);
        recursion_level = 0;
        current_data = nullptr;
    End

    ~SaveData() 
    Begin
        For let idx in idxs Then
            clang_disposeIndex(idx);
        End

        For let tu in tus Then
            clang_disposeTranslationUnit(tu);
        End
    End
EndRecord