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
    std::vector<int> array_sizes;
};

struct TypeNotNamed {
    size_t index;
    FieldType type;
    int pointer_level;
    std::vector<int> array_sizes;
};

struct StructField {
    bool is_type_named;

    TypeNamed type_named;

    // this will be used if the type of a field is a anonymous or declared struct inside the parent struct.
    TypeNotNamed type_not_named;

    std::vector<std::string> comment_text;

    std::string name;
};

struct StructDecl {
    std::string name;
    std::vector<StructField> fields;
    std::vector<std::string> comment_text;
    bool is_union;
};

struct EnumDecl {
    std::string name;
    // CONSTANT_NAME = IS NEGATIVE, VALUE // COMMENT
    std::vector<std::tuple<std::string, bool, uint64_t, std::vector<std::string>>> constants; 
    std::vector<std::string> comment_text;
};

struct Argument {
    std::variant<TypeNamed, TypeNotNamed> type;
    std::string name;
};

struct FunctionDecl {
    std::string name;

    std::variant<TypeNamed, TypeNotNamed> return_type;
    std::vector<std::string> comment_text;

    std::vector<Argument> arguments;
};

struct TypeDef {
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
        UNION,
        TYPEDEF,
        FUNCTION,
        CONSTANT,
        NONE,
    } is;

    std::string constant_string;
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

    SaveData() {
        struct_decls.reserve(8);
        type_defs.reserve(8);
        recursion_level = 0;
        current_data = nullptr;
    }

    ~SaveData() {
        for (auto idx : idxs) {
            clang_disposeIndex(idx);
        }

        for (auto tu : tus) {
            clang_disposeTranslationUnit(tu);
        }
    }
};