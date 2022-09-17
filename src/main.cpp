#include <iostream>
#include <string>
#include <vector>
#include <optional>
#include <tuple>
#include <functional>
#include <fstream>
#include <sstream>
#include <clang-c/Index.h>

#define DEBUG_PRINT

enum class FieldType {
    STRUCT,
    ENUM,
};

struct StructField {
    bool is_type_named;

    struct {
        std::string type_name;
        CXType type;
    } type_named;

    // this will be used if the type of a field is a anonymous or declared struct inside the parent struct.
    struct {
        size_t index;
        FieldType type;
        unsigned int pointer_level;
    } type_not_named;

    std::string name;
};

struct StructDecl {
    std::string name;
    std::vector<StructField> fields;
};

struct TypeDef {
    std::string name;

    // refers to whether a struct or enum is type defined anonymously 
    bool anonymous;
    unsigned int pointer_level;
    StructDecl struct_decl;

    enum class IS {
        STRUCT,
        ENUM,
        NEITHER
    } is;

    std::string type_name;
};

struct ClientData {
    std::vector<StructDecl> struct_decls;
    std::vector<TypeDef> type_defs;
    size_t recursion_level;

    void push_struct(StructDecl decl) {
        struct_decls.push_back(decl);
    }

    void push_typedef(TypeDef type_def) {
        type_defs.push_back(type_def);
    }

    ClientData() {
        recursion_level = 0;
    }
};

void print_struct(ClientData* client_data, StructDecl decl) {
        std::cout << std::string(client_data->recursion_level, '\t') << "Struct \"" << decl.name << "\":" << std::endl;

        // std::cout << "FIELD AMOUNT: " << decl.fields.size() << std::endl;
        for (auto field : decl.fields) {
            // std::cout << "IS TRUE: " << field.is_type_named << std::endl;
            if (field.is_type_named) {
                std::cout << std::string(client_data->recursion_level+1, '\t') << field.type_named.type_name << " " << field.name << "," << std::endl;
            } else {
                switch (field.type_not_named.type) {
                    case FieldType::STRUCT:
                        client_data->recursion_level += 1;

                        print_struct(client_data, client_data->struct_decls[field.type_not_named.index]);

                        client_data->recursion_level -= 1;

                        std::cout << std::string(client_data->recursion_level+1, '\t') << std::string(field.type_not_named.pointer_level, '*') << " " << field.name << "," << std::endl;

                        break;
                    case FieldType::ENUM:
                        break;
                }
            }
        }
    }

CXVisitorResult visitor(CXCursor cursor, CXCursor parent, CXClientData client_data_) {
    CXSourceLocation location = clang_getCursorLocation(cursor);
    if(clang_Location_isFromMainFile( location ) == 0)
        return CXVisit_Continue;

    ClientData* client_data = (ClientData*)(client_data_);
    client_data->recursion_level += 1;

    CXCursorKind cursorKind = clang_getCursorKind(cursor);

    switch (cursor.kind) {
        case CXCursor_StructDecl:
            {
                StructDecl decl;

                decl.name = (char*)clang_getCursorSpelling(cursor).data;

                struct MoreClientData {
                    ClientData* data;
                    std::vector<StructField> fields;
                }; 

                MoreClientData more_client_data;
                more_client_data.data = client_data;
                more_client_data.fields.reserve(1);

                clang_visitChildren(
                    cursor, 
                    [](CXCursor cursor, CXCursor parent, CXClientData client_data_) {
                        auto client_data = (MoreClientData*)client_data_;

                        switch (clang_getCursorKind(cursor)) {
                            case CXCursor_FieldDecl:
                                {
                                    StructField field;

                                    field.type_named.type = clang_getCursorType(cursor);

                                    std::string type_name = std::string((char*)clang_getTypeSpelling(field.type_named.type).data);

                                    field.is_type_named = !(type_name.find("unnamed") != std::string::npos || 
                                                          type_name.find("anonymous") != std::string::npos);

                                    if (field.is_type_named) {
                                        field.type_named.type_name = type_name;
                                    } else {
                                        field.type_not_named.type = type_name.find("struct") != std::string::npos ? FieldType::STRUCT : FieldType::ENUM;

                                        switch (field.type_not_named.type) {
                                            case FieldType::STRUCT:
                                                field.type_not_named.index = client_data->data->struct_decls.size()-1;
                                                break;

                                            case FieldType::ENUM:
                                                break;
                                        }

                                        field.type_not_named.pointer_level = std::count(type_name.begin(), type_name.end(), '*');
                                        client_data->fields.pop_back();
                                    }

                                    field.name = std::string((char*)clang_getCursorSpelling(cursor).data);

                                    client_data->fields.push_back(field);
                                }

                                break;

                            case CXCursor_StructDecl:
                                {
                                    StructField field;

                                    field.is_type_named = false;
                                    field.name = "_";
                                    field.type_not_named.pointer_level = 0;
                                    field.type_not_named.type = FieldType::STRUCT;

                                    clang_visitChildren(
                                        cursor,
                                        (CXCursorVisitor)visitor,
                                        client_data->data
                                    );

                                    field.type_not_named.index = client_data->data->struct_decls.size()-1;
                                    client_data->fields.push_back(field);
                                }
                                
                                return CXChildVisit_Continue;   
                            
                            default:
                                break;
                        }

                        return CXChildVisit_Continue;
                    }, 
                    &more_client_data
                );

                decl.fields = more_client_data.fields;

                client_data->push_struct(decl);
            }
            
            break;
        
        case CXCursor_TypedefDecl:
            {
                // TypeDef type_def;

                // type_def.name = (char*)clang_getCursorSpelling(cursor).data;

                // CXType type = clang_getCursorType(cursor);

                // type_def.type_name = (char*)clang_getTypeSpelling(type).data;

                // bool is_struct = type_def.type_name.find("struct") != std::string::npos;
                // bool is_enum = type_def.type_name.find("enum") != std::string::npos;

                // type_def.is = TypeDef::IS::NEITHER;

                // if (!(is_struct || is_enum)) {
                //     goto TYPEDEF_END;
                // }

                // bool is_unnamed = type_def.type_name.find("unnamed") != std::string::npos || 
                //                   type_def.type_name.find("anonymous") != std::string::npos;
                // type_def.pointer_level = std::count(type_def.type_name.begin(), type_def.type_name.end(), '*');

                // if (is_enum) {
                //     type_def.is = TypeDef::IS::ENUM;

                //     // TODO: I have no implementation stufffor enums yet

                // } else {
                //     // we are just going to assume it's an struct at this point
                //     type_def.is = TypeDef::IS::STRUCT;

                //     if (is_unnamed) {
                //         type_def.anonymous = true;
                //         type_def.struct_decl = client_data->struct_decls[client_data->struct_decls.size()-1];
                //         goto TYPEDEF_END;
                //     }

                //     if (type_def.pointer_level == 0) {
                //         auto type_to_check = type_def.type_name.substr(6, type_def.type_name.size()-6-type_def.pointer_level);

                //         for (auto decl : client_data->struct_decls) {
                            
                //         }
                //     }
                // }

                // TYPEDEF_END:
                //     client_data->push_typedef(type_def);
            }

            break;

        default:
            break;
    }

    // std::cout << std::string(curLevel, '-') << " " << clang_getCString(clang_getCursorKindSpelling(cursorKind)) <<  
    // " (" << clang_getCString(clang_getCursorSpelling(cursor)) << ")" << std::endl;

    clang_visitChildren(
        cursor,
        (CXCursorVisitor)visitor,
        client_data
    ); 

    client_data->recursion_level -= 1;
    return CXVisit_Continue;
}

// NOTE:
// it may be a better idea to just collect the data from the recursion and leave
// we could do this through a queue system that fills specific data then it constructs all of it at the end.
// this would allow ambiguous stuff like aliasing, pointer to struct type that doesn't exist, etc to be easier 
// to parse and make valid odin code with.

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

CXVisitorResult build_queue(CXCursor cursor, CXCursor parent, CXClientData client_data) {
    CXSourceLocation location = clang_getCursorLocation(cursor);
    if(clang_Location_isFromMainFile(location) == 0)
        return CXVisit_Continue;
    
    auto* queue = (DataQueue*)client_data;

    switch (cursor.kind) {
        case CXCursor_StructDecl:
            {
                DataEntry entry;
                entry.is = DataEntry::IS::STRUCT;
                entry.cursor = cursor;
                entry.name = std::string((char*)clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);    
            }
            break;

        case CXCursor_EnumDecl: 
            {
                DataEntry entry;
                entry.is = DataEntry::IS::ENUM;
                entry.cursor = cursor;
                entry.name = std::string((char*)clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);
            }
            break;

        case CXCursor_TypedefDecl:
            {
                DataEntry entry;
                entry.is = DataEntry::IS::TYPEDEF;
                entry.cursor = cursor;
                entry.name = std::string((char*)clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);
            }
            break;

        case CXCursor_FunctionDecl:
            {
                DataEntry entry;
                entry.is = DataEntry::IS::FUNCTION;
                entry.cursor = cursor;
                entry.name = std::string((char*)clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);
            }
            break;
            
    }

    return CXVisit_Continue;
}

struct SaveData {
    std::vector<StructDecl> struct_decls;
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

void recurse_struct(SaveData* data, std::string name, CXCursor cursor) {
    StructDecl decl; 

    decl.name = name;
    decl.fields.reserve(1);

    data->current_data = &decl;

    clang_visitChildren(
        cursor,
        [](CXCursor cursor, CXCursor parent, CXClientData client_data) -> CXChildVisitResult {
            auto data = (SaveData*)client_data;

            switch (cursor.kind) {
                case CXCursor_FieldDecl:
                    {
                        StructField field;

                        auto type = clang_getCursorType(cursor);

                        auto type_name = std::string((char*)clang_getTypeSpelling(type).data);

                        field.name = (char*)clang_getCursorSpelling(cursor).data;

                        field.is_type_named = !(type_name.find("unnamed ") != std::string::npos || 
                                                type_name.find("anonymous ") != std::string::npos);

                        if (field.is_type_named) {
                            field.type_named.type = type;
                            field.type_named.type_name = type_name;
                        } else {
                            field.type_not_named.pointer_level = std::count(type_name.begin(), type_name.end(), '*');

                            if (type_name.find("struct") != std::string::npos) {
                                field.type_not_named.type = FieldType::STRUCT;

                                field.type_not_named.index = data->struct_decls.size()-1;
                            } else {
                                field.type_not_named.type = FieldType::ENUM;

                                // TODO: Once enum's are defined
                            }

                            ((StructDecl*)(data->current_data))->fields.pop_back();
                        }
                        

                        ((StructDecl*)(data->current_data))->fields.push_back(field);                        
                    }

                    break;

                case CXCursor_StructDecl:
                    {
                        void* current_data = data->current_data;

                        std::string name = (char*)clang_getCursorSpelling(cursor).data;

                        recurse_struct(data, name, cursor);

                        data->current_data = current_data;

                        StructField field;
                        field.name = "_";
                        field.is_type_named = false;
                        field.type_not_named.index = data->struct_decls.size()-1;
                        field.type_not_named.pointer_level = 0;
                        field.type_not_named.type = FieldType::STRUCT;

                        ((StructDecl*)(data->current_data))->fields.push_back(field);
                    }

                    break;

                case CXCursor_EnumDecl:
                    // TODO: do the enum stuff once it's implemented 

                    break;
            }

            return CXChildVisit_Continue;
        },       
        data
    );

    data->struct_decls.push_back(decl);
}

std::unordered_map<std::string, std::string> c_keyword_to_odin = {
    { "int", "__CORE__C__TYPE__LITERAL__.int" },
    { "signed", "__CORE__C__TYPE__LITERAL__.int" },
    { "unsigned int", "__CORE__C__TYPE__LITERAL__.uint" },

    { "char", "__CORE__C__TYPE__LITERAL__.char" },
    { "signed char", "__CORE__C__TYPE__LITERAL__.schar" },
    { "unsigned char", "__CORE__C__TYPE__LITERAL__.uchar" },

    { "short", "__CORE__C__TYPE__LITERAL__.short" },
    { "signed short", "__CORE__C__TYPE__LITERAL__.short" },
    { "unsigned short", "__CORE__C__TYPE__LITERAL__.ushort" },

    { "long", "__CORE__C__TYPE__LITERAL__.long" },
    { "signed long", "__CORE__C__TYPE__LITERAL__.long" },
    { "unsigned long", "__CORE__C__TYPE__LITERAL__.ulong" },

    { "long long", "__CORE__C__TYPE__LITERAL__.longlong" },
    { "signed long long", "__CORE__C__TYPE__LITERAL__.longlong" },
    { "unsigned long long", "__CORE__C__TYPE__LITERAL__.ulonglong" },

    { "float", "__CORE__C__TYPE__LITERAL__.float" },
    { "double", "__CORE__C__TYPE__LITERAL__.double" },

    { "size_t", "__CORE__C__TYPE__LITERAL__.size_t" },
    { "signed size_t", "__CORE__C__TYPE__LITERAL__.ssize_t" },
    { "wchar_t", "__CORE__C__TYPE__LITERAL__.wchar_t" },

    { "int8_t", "i8" },
    { "uint8_t", "u8" },
    { "int16_t", "i16" },
    { "uint16_t", "u16" },
    { "int32_t", "i32" },
    { "uint32_t", "u32" },
    { "int64_t", "i64" },
    { "uint64_t", "u64" },

    { "int_fast8_t", "__CORE__C__TYPE__LITERAL__.int_fast8_t" },
    { "uint_fast8_t", "__CORE__C__TYPE__LITERAL__.uint_fast8_t" },
    { "int_fast16_t", "__CORE__C__TYPE__LITERAL__.int_fast16_t" },
    { "uint_fast16_t", "__CORE__C__TYPE__LITERAL__.uint_fast16_t" },
    { "int_fast32_t", "__CORE__C__TYPE__LITERAL__.int_fast32_t" },
    { "uint_fast32_t", "__CORE__C__TYPE__LITERAL__.uint_fast32_t" },
    { "int_fast64_t", "__CORE__C__TYPE__LITERAL__.int_fast64_t" },
    { "uint_fast64_t", "__CORE__C__TYPE__LITERAL__.uint_fast64_t" },

    { "int_least8_t", "__CORE__C__TYPE__LITERAL__.int_least8_t" },
    { "uint_least8_t", "__CORE__C__TYPE__LITERAL__.uint_least8_t" },
    { "int_least16_t", "__CORE__C__TYPE__LITERAL__.int_least16_t" },
    { "uint_least16_t", "__CORE__C__TYPE__LITERAL__.uint_least16_t" },
    { "int_least32_t", "__CORE__C__TYPE__LITERAL__.int_least32_t" },
    { "uint_least32_t", "__CORE__C__TYPE__LITERAL__.uint_least32_t" },
    { "int_least64_t", "__CORE__C__TYPE__LITERAL__.int_least64_t" },
    { "uint_least64_t", "__CORE__C__TYPE__LITERAL__.uint_least64_t" },

    { "intptr_t", "__CORE__C__TYPE__LITERAL__.intptr_t" },
    { "uintptr_t", "__CORE__C__TYPE__LITERAL__.uintptr_t" },
    { "ptrdiff_t", "__CORE__C__TYPE__LITERAL__.ptrdiff_t" },

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
};

int main(int argc, char** argv) {
    // if(argc < 2)
    //     return -1;
    //
    // char* file_path = argv[1];

    char* file_path = "../../src/test.ast";

    CXIndex index        = clang_createIndex(0, 1);
    CXTranslationUnit tu = clang_createTranslationUnit(index, file_path);
    
    std::cout << "EVALUATING TRANSLATION UNIT" << std::endl;
    std::cout << "RESULT: " << tu << std::endl;
    if(!tu)
        return -1;
  
    CXCursor rootCursor = clang_getTranslationUnitCursor(tu);

    std::cout << "DATA:" << std::endl;

    std::cout << rootCursor.kind << std::endl;
    std::cout << rootCursor.xdata << std::endl;
    std::cout << rootCursor.data << std::endl;

    DataQueue queue;

    clang_visitChildren(
        rootCursor, 
        (CXCursorVisitor)build_queue,
        &queue
    );

    SaveData data;

    for (auto entry : queue.data) {
        switch (entry.is) {
            case DataEntry::IS::ENUM:
                // TODO: Once enums are implemented.

                break;

            case DataEntry::IS::STRUCT:
                recurse_struct(&data, entry.name, entry.cursor);
                break;

            case DataEntry::IS::TYPEDEF:
                // TODO: go through typedefs assign with anonoymous structs first, then correct them in the next phase.
                // It would be way easier to do.
                {
                    TypeDef type_def;

                    type_def.name = entry.name;

                    CXType type = clang_getTypedefDeclUnderlyingType(entry.cursor);

                    type_def.type_name = (char*)clang_getTypeSpelling(type).data;
                    type_def.struct_decl = data.struct_decls.size() != 0 ?
                                           data.struct_decls[data.struct_decls.size()-1] :
                                           StructDecl {  };

                    type_def.is = TypeDef::IS::NEITHER;

                    data.type_defs.push_back(type_def);
                }

                break;
        }
    }

    for (auto& type_def : data.type_defs) {
        // std::cout << "TYPEDEF TYPE NAME: " << type_def.type_name << std::endl;

        bool is_struct = type_def.type_name.find("struct ") != std::string::npos;
        bool is_enum = type_def.type_name.find("enum ") != std::string::npos;

        if (!(is_struct || is_enum)) {
            continue;
        }

        type_def.anonymous = false;

        bool is_unnamed = type_def.type_name.find("unnamed ") != std::string::npos || 
                            type_def.type_name.find("anonymous ") != std::string::npos;
        type_def.pointer_level = std::count(type_def.type_name.begin(), type_def.type_name.end(), '*');

        if (is_enum) {
            type_def.is = TypeDef::IS::ENUM;

            // TODO: I have no implementation stufffor enums yet

        } else {
            // we are just going to assume it's an struct at this point
            type_def.is = TypeDef::IS::STRUCT;

            if (is_unnamed) {
                type_def.anonymous = true;
                continue;
            }

            if (type_def.pointer_level == 0) {
                auto type_to_check = type_def.type_name.substr(7, type_def.type_name.size()-6-type_def.pointer_level);

                int i = 0;
                bool found = false;

                // std::cout << "SUBSTR RESULT: " << type_to_check << " " << type_to_check.size() << std::endl;

                for (auto decl : data.struct_decls) {
                    if (type_to_check == decl.name) {
                        type_def.struct_decl = data.struct_decls[i];
                        found = true;
                    }

                    i++;
                }

                if (!found) {
                    type_def.anonymous = true;
                }
            }
        }
    }

    for (auto entry : queue.data) {
        switch (entry.is) {
            case DataEntry::IS::FUNCTION:
                break;
        }
    }

    std::function<void(SaveData*, StructDecl)> print_struct;

    print_struct = [&](SaveData* save_data, StructDecl decl) -> void {
        std::cout << std::string(save_data->recursion_level, '\t') << "Struct \"" << decl.name << "\":" << std::endl;

        for (auto field : decl.fields) {
            if (field.is_type_named) {
                std::cout << std::string(save_data->recursion_level+1, '\t') << field.type_named.type_name << " " << field.name << std::endl;
            } else {
                switch (field.type_not_named.type) {
                    case FieldType::STRUCT:
                        save_data->recursion_level += 1;

                        print_struct(save_data, save_data->struct_decls[field.type_not_named.index]);

                        save_data->recursion_level -= 1;

                        break;
                    
                    case FieldType::ENUM:
                        // TODO: once enums are implemented.
                        break;
                }

                std::cout << std::string(save_data->recursion_level+1, '\t') <<  
                             std::string(field.type_not_named.pointer_level, '*') << " " << field.name << std::endl;
            }
        }
    };

    std::function<void(SaveData*, TypeDef)> print_type_def;

    print_type_def = [&](SaveData* data, TypeDef type_def) -> void {
        std::cout << std::string(data->recursion_level, '\t') << "TYPEDEF \"" << type_def.name << "\": ";

        switch (type_def.is) {
            case TypeDef::IS::STRUCT:
                // std::cout << "Struct " << std::endl; 

                if (type_def.anonymous) {
                    std::cout << std::endl;

                    data->recursion_level += 1;
                    print_struct(data, type_def.struct_decl);
                    data->recursion_level -= 1;

                    std::cout << std::string(data->recursion_level+1, '\t') << "Pointer level: " << type_def.pointer_level << std::endl;
                } else {
                    std::cout << type_def.type_name << std::endl;
                }

                break;
            
            case TypeDef::IS::ENUM:
                // TODO: Once enums are implemented.
                std::cout << std::endl;

                break;

            case TypeDef::IS::NEITHER:
                std::cout << type_def.type_name << std::endl;

                break;
        }
    }; 

    for (auto decl : data.struct_decls) {
        print_struct(&data, decl);
    }

    for (auto type_def : data.type_defs) {
        print_type_def(&data, type_def);
    }

    std::ofstream file("../../test.odin");

    file << "package test\n";
    file << "import __CORE__C__TYPE__LITERAL__ \"core:c\"\n\n";

    std::function<std::string(std::string)> convert_type_name_to_string;

    convert_type_name_to_string = [&](std::string type_name) -> std::string {
        std::stringstream ss;

        if (type_name.find("enum ") != std::string::npos)
            type_name = type_name.erase(0, 5);
        else if (type_name.find("struct ") != std::string::npos)
            type_name = type_name.erase(0, 6);
        
        auto const_index = 0;
        const_index = type_name.find("const ");

        auto decrease = false;

        while (const_index != std::string::npos) {
            type_name = type_name.erase(const_index, (decrease ? 5 : 6));
            const_index = type_name.find("const");

            decrease = true;
        }

        // std::cout << "TYPE BEFORE: " << type_name << std::endl;

        {
            auto const_index = type_name.find("*");

            auto pointer_level = 0;

            auto found_pointer=  false;

            while (const_index != std::string::npos) {
                type_name = type_name.erase(const_index, 1);
                const_index = type_name.find("*");
                found_pointer = true;

                pointer_level++;
            }

            if (found_pointer) {
                type_name = type_name.erase(type_name.size()-1, 1);
            }

            ss << std::string(pointer_level, '^');

            std::cout << "TYPE: " << type_name << "|" << std::endl;



            if (c_keyword_to_odin.find(type_name) != c_keyword_to_odin.end()) {
                ss << c_keyword_to_odin[type_name];
            } else {
                ss << type_name;
            }
        }

        return ss.str();
    };

    std::function<std::string(SaveData*, StructDecl)> convert_struct_decl_to_string;

    convert_struct_decl_to_string = [&](SaveData* data, StructDecl decl) -> std::string {
        std::stringstream ss;

        ss << "struct {";

        if (decl.fields.size() == 0) {
            ss << '}';
            return ss.str();
        }

        if (decl.name != "")
            ss << " // Struct \"" << decl.name << "\"\n";
        else
            ss << '\n'; 

        for (auto field : decl.fields) {
            ss << std::string(data->recursion_level+1, '\t') << field.name << ": ";

            switch (field.is_type_named) {
                case true:
                    ss << convert_type_name_to_string(field.type_named.type_name);

                    break;

                case false:
                    switch (field.type_not_named.type) {
                        case FieldType::STRUCT:
                            ss << std::string(field.type_not_named.pointer_level, '^');

                            data->recursion_level += 1;        

                            ss << convert_struct_decl_to_string(data, data->struct_decls[field.type_not_named.index]); 

                            data->recursion_level -= 1;

                            break;

                        case FieldType::ENUM:
                            // TODO: Once enum is implemented.

                            break;
                    } 

                    break;
            }

            ss << ",\n";
        }

        ss << std::string(data->recursion_level, '\t') << '}';
        
        return ss.str();
    };

    for (auto type_def : data.type_defs) {
        if (type_def.name != "" && data.type_names.find(type_def.name) == data.type_names.end()) {
            // temporary statement since enums aren't implemented yet
            if (type_def.is == TypeDef::IS::ENUM)
                break;

            file << type_def.name << " :: distinct ";
            switch (type_def.is) {
                case TypeDef::IS::STRUCT:
                    file << convert_struct_decl_to_string(&data, type_def.struct_decl) << "\n\n";

                    break;

                case TypeDef::IS::ENUM:
                    break;

                case TypeDef::IS::NEITHER:
                    file << convert_type_name_to_string(type_def.type_name) << "\n\n";

                    break;
            }
        }

        data.type_names.emplace(type_def.name, "");
    }

    for (auto decl : data.struct_decls) {
        if (decl.name != "" && data.type_names.find(decl.name) == data.type_names.end()) {
            file << decl.name << " :: ";
            file << convert_struct_decl_to_string(&data, decl);
            file << "\n\n";

            data.type_names.emplace(decl.name, "");
        }
    }

    file.close();

    clang_disposeTranslationUnit(tu);
    clang_disposeIndex(index);
    return 0;
}