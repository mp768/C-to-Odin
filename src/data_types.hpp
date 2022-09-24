#pragma once
#include <string>
#include <vector>
#include <tuple>
#include <optional>
#include <clang-c/Index.h>
#include <unordered_map>
#include <variant>

enum class FieldType {
    STRUCT,
    ENUM,
};

struct TypeNamed {
    std::string type_name;
    CXType type;
};

struct TypeNotNamed {
    size_t index;
    FieldType type;
    int pointer_level;
};

struct StructField {
    bool is_type_named;

    TypeNamed type_named;

    // this will be used if the type of a field is a anonymous or declared struct inside the parent struct.
    TypeNotNamed type_not_named;

    std::string name;
};

struct StructDecl {
    std::string name;
    std::vector<StructField> fields;
};

struct EnumDecl {
    std::string name;
    // CONSTANT_NAME = IS NEGATIVE, VALUE
    std::vector<std::tuple<std::string, bool, uint64_t>> constants; 
};

struct Argument {
    std::variant<TypeNamed, TypeNotNamed> type;
    std::string name;
};

struct FunctionDecl {
    std::string name;

    std::variant<TypeNamed, TypeNotNamed> return_type;

    std::vector<Argument> arguments;
};

struct TypeDef {
    std::string name;

    // refers to whether a struct or enum is type defined anonymously 
    bool anonymous;
    unsigned int pointer_level;
    StructDecl struct_decl;
    EnumDecl enum_decl;

    enum class IS {
        STRUCT,
        ENUM,
        NEITHER
    } is;

    std::string type_name;
};

struct DataEntry {
    enum class IS {
        STRUCT,
        ENUM,
        TYPEDEF,
        FUNCTION,
        NONE,
    } is;

    CXCursor cursor;
    std::string name;
};

struct DataQueue {
    std::vector<DataEntry> data;
};

struct SaveData {
    std::vector<StructDecl> struct_decls;
    std::vector<EnumDecl> enum_decls;
    std::vector<FunctionDecl> function_decls;
    std::vector<TypeDef> type_defs;
    std::unordered_map<std::string, std::string> type_names;
    void* current_data;

    size_t recursion_level;

    SaveData() {
        struct_decls.reserve(8);
        type_defs.reserve(8);
        recursion_level = 0;
        current_data = nullptr;
    }
};