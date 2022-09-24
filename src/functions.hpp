#pragma once
#include <string>
#include <vector>
#include "data_types.hpp"

static inline void get_rid_of_const(std::string& type_name) {
    auto const_index = type_name.find("const ");

    auto decrease = false;

    while (const_index != std::string::npos) {
        type_name = type_name.erase(const_index, (decrease ? 5 : 6));
        const_index = type_name.find("const");

        decrease = true;
    }
}

static inline auto get_rid_of_pointer(std::string& type_name) -> int {
    auto pointer_index = type_name.find("*");

    auto pointer_level = 0;

    auto found_pointer = false;

    while (pointer_index != std::string::npos) {
        type_name = type_name.erase(pointer_index, 1);
        pointer_index = type_name.find("*");
        found_pointer = true;

        pointer_level++;
    }

    if (found_pointer) {
        type_name = type_name.erase(type_name.size()-1, 1);
    }

    return pointer_level;
}

static inline void trim_spaces_string(std::string& type_name) {
    auto space_index = type_name.find(' ');

    while (space_index != std::string::npos) {
        type_name = type_name.erase(space_index, 1);
        space_index = type_name.find(' ');
    }
}

static inline auto convert_to_c_keyword(std::string type_name) -> std::string {
    if (c_keyword_to_odin.find(type_name) != c_keyword_to_odin.end()) {
        return c_keyword_to_odin[type_name];
    }

    return type_name;
}

static inline void strip_enum_and_struct(std::string& str) {
    auto enum_idx = str.find("enum ");
    auto struct_idx = str.find("struct ");

    if (enum_idx != std::string::npos)
        str = str.erase(enum_idx, 5);
    else if (struct_idx != std::string::npos)
        str = str.erase(struct_idx, 6);
}

static inline auto convert_c_fptr_to_odin_fptr(std::string fptr) -> std::string {
    if (fptr.find("(*)") != std::string::npos) {
        auto position = fptr.find("(*)");

        auto type = fptr.substr(0, position);

        auto type_name = fptr.erase(0, position+3);

        fptr = "proc" + type_name + " -> " + type;
    } else {
        return fptr;
    }

    auto starting_position = fptr.find('(');
    auto end_position = fptr.find(')');

    std::stringstream final_str;
    final_str << "proc(";

    std::string type;

    for (auto i = starting_position+1; i <= end_position; i++) {
        auto current_char = fptr[i];

        if (current_char != ',' && current_char != ')') {
            type += current_char;
        } else { 
            strip_enum_and_struct(type);
            get_rid_of_const(type);
            auto pointer_level = get_rid_of_pointer(type);
            trim_spaces_string(type);

            final_str << std::string(pointer_level, '^');

            if (unallowed_keywords_in_odin.find(type) != unallowed_keywords_in_odin.end()) {
                type += "_t";
            }

            final_str << convert_to_c_keyword(type);

            if (current_char != ')') {
                final_str << ", ";
            }

            type = "";
        }
    }

    final_str << ')';

    auto return_type = fptr.substr(end_position+5);

    if (return_type != "void") {
        get_rid_of_const(return_type);
        auto pointer_level = get_rid_of_pointer(return_type);

        if (unallowed_keywords_in_odin.find(return_type) != unallowed_keywords_in_odin.end()) {
            return_type += "_t";
        }

        trim_spaces_string(return_type);

        final_str << " -> ";
        final_str << std::string(pointer_level, '^');
        final_str << convert_to_c_keyword(return_type);
    }

    return final_str.str();
}

static inline auto convert_type_name_to_string(std::string type_name) -> std::string {
    std::stringstream ss;

    if (type_name.find("proc(") != std::string::npos) {
        return type_name;
    }

    strip_enum_and_struct(type_name);
    
    get_rid_of_const(type_name);

    // std::cout << "TYPE BEFORE: " << type_name << std::endl;

    {
        auto pointer_level = get_rid_of_pointer(type_name);

        ss << std::string(pointer_level, '^');

        if (unallowed_keywords_in_odin.find(type_name) != unallowed_keywords_in_odin.end()) {
            type_name += "_t";
        }

        // std::cout << "TYPE: " << type_name << "|" << std::endl;

        ss << convert_to_c_keyword(type_name);
    }

    return ss.str();
}

static inline auto convert_enum_decl_to_string(SaveData* data, EnumDecl decl) {
    std::stringstream ss;

    ss << "enum {";

    if (decl.constants.size() == 0) {
        ss << '}';
        return ss.str();
    }

    if (decl.name != "")
        ss << " // Enum \"" << decl.name << "\"\n";
    else
        ss << '\n'; 

    for (auto constant : decl.constants) {
        auto name = std::get<0>(constant);
        auto is_negative = std::get<1>(constant);
        auto value = std::get<2>(constant);

        ss << std::string(data->recursion_level+1, '\t') << name << " = " << std::string(is_negative, '-') << value << ",\n";
    }

    ss << std::string(data->recursion_level, '\t') << '}';

    return ss.str();
}

static inline auto convert_struct_decl_to_string(SaveData* data, StructDecl decl) -> std::string {
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
        ss << std::string(data->recursion_level+1, '\t');

        if (field.name == "_" && !field.is_type_named) {
            ss << "using ";
        }

        ss << field.name << ": ";

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
                        ss << std::string(field.type_not_named.pointer_level, '^');

                        data->recursion_level += 1;

                        ss << convert_enum_decl_to_string(data, data->enum_decls[field.type_not_named.index]);

                        data->recursion_level -= 1;

                        break;
                } 

                break;
        }

        ss << ",\n";
    }

    ss << std::string(data->recursion_level, '\t') << '}';
    
    return ss.str();
}

static inline void modify_type_def(SaveData& data, TypeDef& type_def) {
    // std::cout << "TYPEDEF TYPE NAME: " << type_def.type_name << std::endl;

    if (unallowed_keywords_in_odin.find(type_def.name) != unallowed_keywords_in_odin.end()) {
        type_def.name += "_t";
    }

    if (type_def.type_name.find("(*)") != std::string::npos) {
        type_def.type_name = convert_c_fptr_to_odin_fptr(type_def.type_name);
        return;
    }

    bool is_struct = type_def.type_name.find("struct ") != std::string::npos;
    bool is_enum = type_def.type_name.find("enum ") != std::string::npos;

    if (!(is_struct || is_enum)) {
        return;
    }

    type_def.anonymous = false;

    bool is_unnamed = type_def.type_name.find("unnamed ") != std::string::npos || 
                        type_def.type_name.find("anonymous ") != std::string::npos;
    type_def.pointer_level = (unsigned int)std::count(type_def.type_name.begin(), type_def.type_name.end(), '*');

    if (is_enum) {
        type_def.is = TypeDef::IS::ENUM;

        if (is_unnamed) {
            type_def.anonymous = true;
            return;
        }

        if (type_def.pointer_level == 0) {
            auto type_to_check = type_def.type_name.substr(6, type_def.type_name.size()-5-type_def.pointer_level);

            bool found = false;

            // std::cout << "SUBSTR RESULT: " << type_to_check << " " << type_to_check.size() << std::endl;

            for (auto decl : data.enum_decls) {
                if (type_to_check == decl.name) {
                    type_def.enum_decl = decl;
                    found = true;
                }
            }

            if (!found) {
                type_def.anonymous = true;
            }
        }
    } else {
        // we are just going to assume it's an struct at this point
        type_def.is = TypeDef::IS::STRUCT;

        if (is_unnamed) {
            type_def.anonymous = true;
            return;
        }

        if (type_def.pointer_level == 0) {
            auto type_to_check = type_def.type_name.substr(7, type_def.type_name.size()-6-type_def.pointer_level);

            bool found = false;

            // std::cout << "SUBSTR RESULT: " << type_to_check << " " << type_to_check.size() << std::endl;

            for (auto decl : data.struct_decls) {
                if (type_to_check == decl.name) {
                    type_def.struct_decl = decl;
                    found = true;
                }
            }

            if (!found) {
                type_def.anonymous = true;
            }
        }
    }
}

static inline void recurse_enum(SaveData* data, std::string name, CXCursor cursor);
static inline void recurse_struct(SaveData* data, std::string name, CXCursor cursor);

static inline void parse_function(SaveData* data, std::string name, CXCursor cursor) {
    FunctionDecl decl;

    decl.name = name;

    auto num_arguments = clang_Cursor_getNumArguments(cursor);

    decl.arguments.reserve(num_arguments);

    for (auto i = 0; i < num_arguments; i++) {
        auto argument_cursor = clang_Cursor_getArgument(cursor, (unsigned int)i);

        auto name = std::string((char*)clang_getCursorSpelling(argument_cursor).data);

        auto type = clang_getCursorType(argument_cursor);

        auto type_name = std::string((char*)clang_getTypeSpelling(type).data);

        if (type_name.find("(*)") != std::string::npos) {
            convert_c_fptr_to_odin_fptr(type_name);
        }

        auto is_enum = type_name.find("enum ") != std::string::npos;

        auto is_named = !(is_enum || type_name.find("struct ") != std::string::npos);

        if (is_named) {
            decl.arguments.push_back(
                Argument { 
                    TypeNamed {
                        type_name,
                        type
                    },
                    name
                }
            );
            continue;
        }

        auto if_struct_or_enum = clang_getTypeDeclaration(type);

        auto pointer_level = get_rid_of_pointer(type_name);

        if (is_enum) {
            recurse_enum(data, "", if_struct_or_enum);
        } else {
            recurse_struct(data, "", if_struct_or_enum);
        }

        // decl.arguments.push_back(
        //     Argument {
        //         TypeNotNamed {
        //             0, //(is_enum ? (data->enum_decls.size()-1) : (data->struct_decls.size()-1)),
        //             FieldType::ENUM, // (is_enum ? FieldType::ENUM : FieldType::STRUCT),
        //             pointer_index
        //         },
        //         name
        //     }
        // );

        Argument argument;
        argument.type = TypeNotNamed {
            (is_enum ? (data->enum_decls.size()-1) : (data->struct_decls.size()-1)),
            (is_enum ? FieldType::ENUM : FieldType::STRUCT),
            pointer_level
        };

        argument.name = name;

        decl.arguments.push_back(
            argument
        );

        std::cout << type_name << " " << name << std::endl;
    }
    

    data->function_decls.push_back(decl);
}

// 'recurse' doesn't really make sense here, but I couldn't figure out what to name it.
static inline void recurse_enum(SaveData* data, std::string name, CXCursor cursor) {
    EnumDecl decl;

    decl.name = name;

    data->current_data = &decl;
    
    clang_visitChildren(
        cursor,
        [](CXCursor cursor, CXCursor parent, CXClientData client_data) -> CXChildVisitResult {
            auto data = (SaveData*)client_data;

            switch (cursor.kind) {
                case CXCursor_EnumConstantDecl:
                    {
                        auto decl = (EnumDecl*)data->current_data;

                        std::string name = (char*)clang_getCursorSpelling(cursor).data;
                        unsigned long long value = clang_getEnumConstantDeclUnsignedValue(cursor);
                        long long value2 = clang_getEnumConstantDeclValue(cursor);

                        bool is_negative = (long long)value > value2;

                        decl->constants.push_back({ name, is_negative, (uint64_t)(is_negative ? -value2 : value) });
                    }

                    break;
            }

            return CXChildVisit_Continue;
        },
        data
    );

    data->enum_decls.push_back(decl);
}

static inline void recurse_struct(SaveData* data, std::string name, CXCursor cursor) {
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

                        if (unallowed_keywords_in_odin.find(field.name) != unallowed_keywords_in_odin.end()) {
                            field.name += "_v";
                        }

                        field.is_type_named = !(type_name.find("unnamed ") != std::string::npos || 
                                                type_name.find("anonymous ") != std::string::npos);

                        if (field.is_type_named) {
                            field.type_named.type = type;
                            field.type_named.type_name = type_name;
                        } else {
                            field.type_not_named.pointer_level = (unsigned int)std::count(type_name.begin(), type_name.end(), '*');

                            if (type_name.find("struct") != std::string::npos) {
                                field.type_not_named.type = FieldType::STRUCT;

                                field.type_not_named.index = data->struct_decls.size()-1;
                            } else {
                                field.type_not_named.type = FieldType::ENUM;

                                field.type_not_named.index = data->enum_decls.size()-1;
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
                    {
                        void* current_data = data->current_data;

                        std::string name = (char*)clang_getCursorSpelling(cursor).data;

                        recurse_enum(data, name, cursor);

                        data->current_data = current_data;

                        StructField field;
                        field.name = "_";
                        field.is_type_named = false;
                        field.type_not_named.index = data->enum_decls.size()-1;
                        field.type_not_named.pointer_level = 0;
                        field.type_not_named.type = FieldType::ENUM;

                        ((StructDecl*)data->current_data)->fields.push_back(field);
                    }

                    break;
            }

            return CXChildVisit_Continue;
        },       
        data
    );

    data->struct_decls.push_back(decl);
}

static inline CXVisitorResult build_queue(CXCursor cursor, CXCursor parent, CXClientData client_data) {
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

