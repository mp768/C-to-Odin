#pragma once
#include <string>
#include <vector>
#include "data_types.hpp"
#include "essential_macros.hpp"

#define cast(type, expr) ((type)(expr))
#define FIND_FUNCTION_PTR(variable) (variable.find("(*") != std::string::npos && (variable.find("*)") != std::string::npos || variable.find("])") != std::string::npos))
#define FIND_ANONYMOUS(variable) (variable.find("anonymous ") != std::string::npos || variable.find("unnamed ") != std::string::npos)
#define GET_RAW_COMMENT(cursor) std::vector<std::string> comments; { var range = clang_Cursor_getCommentRange(cursor); if (range.begin_int_data != 0 && range.end_int_data != 0) { std::string comment = cast(char ptr, clang_Cursor_getRawCommentText(cursor).data); comments = strip_unnecessary_newline(comment); }  }
#define FIND_ARRAY_BRACES(variable) (variable.find("[") != std::string::npos && variable.find("]") != std::string::npos)

function strip_unnecessary_newline(std::string ref str) -> std::vector<std::string> {
    var r_index = str.find('\r');

    while (r_index != std::string::npos) {
        str.erase(r_index, 1);

        r_index = str.find('\r');
    }

    var newline_index = str.find('\n');

    while (newline_index != std::string::npos) {
        if (newline_index == str.size()-1 || newline_index == 0)
            str = str.erase(newline_index, 1);
        else if (str[newline_index+1] != '\n') {
            str[newline_index] = '\b';
            // str = str.erase(newline_index+1, 1);
        }
        
        newline_index = str.find('\n');
    }

    var b_index = str.find('\b');

    while (b_index != std::string::npos) {
        str[b_index] = '\n';

        b_index = str.find('\b');
    }

    std::stringstream ss(str);
    std::string STR;
    std::vector<std::string> results;

    while(std::getline(ss, STR, '\n')) {
        results.push_back(STR);
    }

    return results;
}

function get_rid_of_const(std::string ref type_name) -> void {
    var const_index = type_name.find("const ");

    #if DEBUG_PRINT
    std::cout << "TYPE NAME BEFORE REMOVEMENT OF CONST: " << type_name << std::endl; 
    #endif

    var decrease = false;

    while (const_index != std::string::npos) {
        type_name = type_name.erase(const_index, (decrease ? 5 : 6));
        const_index = type_name.find("const");

        #if DEBUG_PRINT 
        std::cout << "PROGRESS ON CONST REMOVING: " << type_name << std::endl;
        #endif 

        decrease = true;
    }
}

function trim_spaces_string(std::string ref type_name) -> void;

function get_rid_of_pointer(std::string ref type_name) -> int {
    var pointer_index = type_name.find("*");

    var pointer_level = 0;

    var found_pointer = false;

    while (pointer_index != std::string::npos) {
        type_name = type_name.erase(pointer_index, 1);
        pointer_index = type_name.find("*");
        found_pointer = true;

        pointer_level++;
    }

    if (found_pointer) {
        trim_spaces_string(type_name);
    }

    #if DEBUG_PRINT 
    std::cout << "TRIMMED POINTER FOR: " << type_name << std::endl;
    #endif

    return pointer_level;
}

function trim_spaces_string(std::string ref type_name) -> void {
    var space_index = type_name.find(' ');

    while (space_index != std::string::npos) {
        if (space_index == type_name.size()-1 || space_index == 0)
            type_name = type_name.erase(space_index, 1);
        else if (type_name[space_index+1] != ' ')
            type_name[space_index] = '\b';
        else 
            type_name[space_index] = '\b';
        
        space_index = type_name.find(' ');

        #if DEBUG_PRINT
        std::cout << "CURRENT TRIMMING OF SPACES: " << type_name << std::endl;
        #endif
    }

    var b_index = type_name.find('\b');

    while (b_index != std::string::npos) {
        type_name[b_index] = ' ';

        b_index = type_name.find('\b');
    }
}

function convert_to_c_keyword(std::string type_name) -> std::string {
    if (c_keyword_to_odin.find(type_name) != c_keyword_to_odin.end()) {
        return c_keyword_to_odin[type_name];
    }

    return type_name;
}

function strip_enum_and_struct(std::string ref str) -> void {
    var enum_idx = str.find("enum ");
    var struct_idx = str.find("struct ");
    var union_idx = str.find("union ");

    if (enum_idx != std::string::npos)
        str = str.erase(enum_idx, 4);
    else if (struct_idx != std::string::npos)
        str = str.erase(struct_idx, 6);
    else if (union_idx != std::string::npos)
        str = str.erase(union_idx, 5);
}

function strip_prefix(std::string ref str, std::vector<std::string> remove_prefixes) -> std::string {
    std::string prefix_stripped = "";

    size_t prefix_index = 0;

    var i = 0;
    while (prefix_index != std::string::npos) {
        prefix_index = std::string::npos;

        for (let prefix in remove_prefixes) {
            prefix_index = str.find(prefix);

            if (prefix_index != std::string::npos && prefix_index == 0) {
                str = str.erase(prefix_index, prefix.length());
                prefix_stripped += prefix;
            }
        }

        i++;

        if (i > 1000) {
            // just give up after a while.
            break;
        }
    }

    return prefix_stripped;
}

function convert_c_fptr_to_odin_fptr(SaveData ptr data, CXType type, std::string fptr) -> std::string;
function recurse_enum(SaveData ptr data, std::string name, CXCursor cursor, bool declaring = false) -> void;
function recurse_struct(SaveData ptr data, std::string name, CXCursor cursor, bool is_union, bool declaring = false) -> void;

// this shouldn't be `to_string` but I don't want to chnage it right now because I'm lazy.
function convert_type_to_string(SaveData ptr data, CXType type) -> std::variant<TypeNamed, TypeNotNamed> {
    var type_name = std::string((char ptr)clang_getTypeSpelling(type).data);

    std::vector<int> array_sizes;

    if (FIND_FUNCTION_PTR(type_name)) {
        type_name = convert_c_fptr_to_odin_fptr(data, type, type_name);

        return TypeNamed {
            type_name,
            type,
            array_sizes,
        };
    }


    if (FIND_ARRAY_BRACES(type_name)) {
        var array_size = clang_getArraySize(type);

        while (array_size != -1) {
            array_sizes.push_back(cast(int, array_size));
            type = clang_getArrayElementType(type);
            array_size = clang_getArraySize(type);
        }

        std::reverse(array_sizes.begin(), array_sizes.end());
    }

    var is_enum = type_name.find("enum ") != std::string::npos;
    var is_union = type_name.find("union ") != std::string::npos;

    var is_named = !FIND_ANONYMOUS(type_name);

    if (is_named) {
        strip_enum_and_struct(type_name);
        return TypeNamed {
            type_name,
            type,
            array_sizes,
        };
    }

    var pointer_level = get_rid_of_pointer(type_name);

    for (var i = 0; i < pointer_level; i++) {
        type = clang_getPointeeType(type);
    }

    var if_struct_or_enum = clang_getTypeDeclaration(type);

    if (is_enum) {
        recurse_enum(data, "", if_struct_or_enum);
    } else {
        recurse_struct(data, "", if_struct_or_enum, is_union);
    }

    return TypeNotNamed {
        (is_enum ? data->enum_decls.size()-1 : data->struct_decls.size()-1),
        (is_enum ? FieldType::ENUM : FieldType::STRUCT),
        pointer_level,
        array_sizes,
    };
}

function convert_enum_decl_to_string(SaveData ptr data, EnumDecl decl, bool add_new_line_to_each_field = true) -> std::string;
function convert_struct_decl_to_string(SaveData ptr data, StructDecl decl, bool add_new_line_to_each_field = true) -> std::string;
function convert_type_name_to_string(SaveData ptr data, CXType type, std::string type_name) -> std::string;

function convert_c_fptr_to_odin_fptr(SaveData ptr data, CXType type, std::string fptr) -> std::string {
    if (!FIND_FUNCTION_PTR(fptr)) {
        return fptr;
    }

    std::stringstream final_str;

    // to handle the potential possibility that a lunatic would create a typedef of a function pointer, and want more than 1.
    {
        var array_size = clang_getArraySize(type);

        while (array_size != -1) {
            final_str << "[" << array_size << "]";

            type = clang_getArrayElementType(type);
            array_size = clang_getArraySize(type);
        }

        fptr = (char ptr)clang_getTypeSpelling(type).data;
    }

    {
        var starting_position = fptr.find("(*");
        var ending_position = fptr.find("*)");

        var pointers = fptr.substr(starting_position, ending_position-starting_position+1);

        var pointer_level = get_rid_of_pointer(pointers);

        final_str << std::string(pointer_level-1, '^');

        #if DEBUG_PRINT
        std::cout << "TYPE SPELLING: " << (char ptr)clang_getTypeSpelling(type).data << std::endl;
        #endif

        // std::cout << "CURSOR TYPENAME: " << (char ptr)clang_getCursorSpelling(cursor).data << std::endl;

        // CXType type = clang_getCursorType(cursor);

        for (var i = 0; i < pointer_level; i++) {
            type = clang_getPointeeType(type);
        }        

        // cursor = clang_getTypeDeclaration(type);
    }

    #if DEBUG_PRINT
    std::cout << "TYPE SPELLING: " << (char ptr)clang_getTypeSpelling(type).data << std::endl;
    #endif

    final_str << "proc \"c\" (";

    var argument_amount = clang_getNumArgTypes(type);

    for (var i = 0; i < argument_amount; i++) {
        var argument_type = clang_getArgType(type, (unsigned int)i);

        var _type = convert_type_to_string(data, argument_type);

        if (std::holds_alternative<TypeNamed>(_type)) {
            var type = std::get<TypeNamed>(_type);
            final_str << convert_type_name_to_string(data, type.type, type.type_name);
        } else {
            var type = std::get<TypeNotNamed>(_type);

            final_str << std::string(type.pointer_level, '^'); 

            for (let array_size in type.array_sizes) {
                final_str << "[" << array_size << "]";
            }

            if (type.type == FieldType::ENUM) {
                final_str << convert_enum_decl_to_string(data, data->enum_decls[type.index], false);
            } else {
                final_str << convert_struct_decl_to_string(data, data->struct_decls[type.index], false);
            }
            
        }

        final_str << ", ";
    }

    if (argument_amount > 0)
        final_str.seekp(-2, final_str.cur);

    final_str << ')';

    var return_type_type = clang_getResultType(type);

    #if DEBUG_PRINT
    std::cout << return_type_type.kind << std::endl;
    #endif

    var return_type = convert_type_to_string(data, return_type_type);

    if (std::holds_alternative<TypeNamed>(return_type)) {
        var type_named = std::get<TypeNamed>(return_type);

        trim_spaces_string(type_named.type_name);

        if (type_named.type_name != "void") {
            final_str << " -> ";
            final_str << convert_type_name_to_string(data, type_named.type, type_named.type_name);
        }
    } else {
        var type_not_named = std::get<TypeNotNamed>(return_type);

        final_str << " -> " << std::string(type_not_named.pointer_level, '^');

        if (type_not_named.type == FieldType::ENUM) {
            final_str << convert_enum_decl_to_string(data, data->enum_decls[type_not_named.index], false);
        } else {
            final_str << convert_struct_decl_to_string(data, data->struct_decls[type_not_named.index], false);
        }
    }

    return final_str.str();
}

function convert_type_name_to_string(SaveData ptr data, CXType type, std::string type_name) -> std::string {
    std::stringstream ss;

    if (FIND_FUNCTION_PTR(type_name)) {
        return convert_c_fptr_to_odin_fptr(data, type, type_name);
    }

    if (type_name.find("proc(") != std::string::npos) {
        return type_name;
    }

    strip_enum_and_struct(type_name);
    
    get_rid_of_const(type_name);

    std::vector<std::string> array_size_strings;

    while (FIND_ARRAY_BRACES(type_name)) {
        var starting_index = type_name.find("[");
        var ending_index = type_name.find("]");

        var number = type_name.substr(starting_index+1, ending_index-starting_index);

        std::string array_size_string = "[" + number;
        array_size_strings.push_back(array_size_string);

        type_name = type_name.erase(starting_index, ending_index-starting_index+1);
    }

    std::reverse(array_size_strings.begin(), array_size_strings.end());

    for (let array_size_string in array_size_strings) {
        #if DEBUG_PRINT
        std::cout << type_name << ": " << array_size_string << std::endl;
        #endif

        ss << array_size_string;
    }

    {
        var pointer_level = get_rid_of_pointer(type_name);

        strip_prefix(type_name, data->remove_prefixes);
        trim_spaces_string(type_name);

        if (unallowed_keywords_in_odin.find(type_name) != unallowed_keywords_in_odin.end()) {
            type_name += "_t";
        }
        
        if (type_name == "void" && pointer_level >= 1) {
            pointer_level -= 1;
            type_name = "rawptr";
        }

        if (type_name == "char" && data->convert_char_pointer_to_cstring && pointer_level >= 1) {
            pointer_level -= 1;
            type_name = "cstring";
        }

        ss << std::string(pointer_level, '^');

        ss << convert_to_c_keyword(type_name);
    }

    return ss.str();
}

function convert_enum_decl_to_string(SaveData ptr data, EnumDecl decl, bool add_new_line_to_each_field) -> std::string {
    std::stringstream ss;

    ss << "enum {";

    if (decl.constants.size() == 0) {
        ss << '}';
        return ss.str();
    }

    // if (decl.comment_text != "" && add_new_line_to_each_field) 
    //     ss << decl.comment_text;
    // else if (decl.comment_text != "")
    //     ss << "/* " << decl.comment_text << " */";

    if (add_new_line_to_each_field)
        ss << '\n'; 

    for (let constant in decl.constants) {
        var name = std::get<0>(constant);
        var is_negative = std::get<1>(constant);
        var value = std::get<2>(constant);
        var comment_text_ = std::get<3>(constant);

        strip_prefix(name, data->remove_constant_prefixes);

        if (add_new_line_to_each_field)
            ss << std::string(data->recursion_level+1, '\t');
        else 
            ss << " ";

        for (let comment_text in comment_text_) {
            if (comment_text != "") {
                if (add_new_line_to_each_field) {
                    ss << comment_text << '\n';
                    ss << std::string(data->recursion_level+1, '\t');
                } else {
                    ss << "/* " << comment_text << " */ ";
                }
            }
        }

        ss << name << " = " << std::string(is_negative, '-') << value << ','; 
        
        if (add_new_line_to_each_field)
            ss << "\n";
        else 
            ss << " ";
    }

    if (add_new_line_to_each_field)
        ss << std::string(data->recursion_level, '\t');

    ss << '}';

    return ss.str();
}

function convert_struct_decl_to_string(SaveData ptr data, StructDecl decl, bool add_new_line_to_each_field) -> std::string {
    std::stringstream ss;

    ss << "struct ";

    if (decl.is_union) {
        ss << "#raw_union ";
    }

    ss << '{';

    // if (decl.comment_text != "" && add_new_line_to_each_field)
    //     ss << decl.comment_text;
    // else if (decl.comment_text != "") 
    //     ss << "/* " << decl.comment_text << " */";

    if (decl.fields.size() == 0) {
        ss << '}';
        return ss.str();
    }

    if (add_new_line_to_each_field)
        ss << '\n'; 

    for (var field in decl.fields) {
        if (add_new_line_to_each_field)
            ss << std::string(data->recursion_level+1, '\t');
        else 
            ss << " ";
        
        for (let comment_text in field.comment_text) {
            if (comment_text != "") {
                if (add_new_line_to_each_field) {
                    ss << comment_text << '\n';
                    ss << std::string(data->recursion_level+1, '\t');
                }
                else {
                    ss << "/* " << comment_text << " */ ";
                }
            }
        }

        if (field.name == "_" && !field.is_type_named) {
            ss << "using ";
        }

        #if DEBUG_PRINT 
        std::cout << "STRUCT FIELD NAME IS: " << field.name << std::endl;
        #endif

        if (unallowed_keywords_in_odin.find(field.name) != unallowed_keywords_in_odin.end()) {
            field.name += "_v";
        }


        switch (field.is_type_named) {
            case true:
                trim_spaces_string(field.type_named.type_name);
                if (field.type_named.type_name == field.name)
                    ss << field.name << "_v: ";
                else 
                    ss << field.name << ": ";
                
                ss << convert_type_name_to_string(data, field.type_named.type, field.type_named.type_name);

                break;

            case false:
                ss << field.name << ": ";

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

        ss << ",";

        if (add_new_line_to_each_field)
            ss << "\n";
        else 
            ss << " ";
    }

    if (add_new_line_to_each_field)
        ss << std::string(data->recursion_level, '\t');
    
    ss << '}';
    
    return ss.str();
}

function convert_function_decl_to_string(SaveData ptr data, FunctionDecl decl) -> std::string {
    std::stringstream ss;

    // strip_prefix(decl.name, data->remove_prefixes);

    for (let comment_text in decl.comment_text) {
        if (comment_text != "") {
            ss << std::string(data->recursion_level, '\t') << comment_text << '\n';
        }
    }

    ss << std::string(data->recursion_level, '\t') << decl.name << " :: proc(";
    for (var argument in decl.arguments) {
        if (unallowed_keywords_in_odin.find(argument.name) != unallowed_keywords_in_odin.end()) {
            argument.name += "_v";
        }

        if (std::holds_alternative<TypeNamed>(argument.type)) {
            var type_named = std::get<TypeNamed>(argument.type);

            if (argument.name != "" && argument.name != type_named.type_name)
                ss << argument.name << ": ";
            else if (argument.name == type_named.type_name)
                ss << argument.name << "_v: ";
            else
                ss << "_: ";
            
            ss << (type_named.type_name.find("proc") != std::string::npos ? 
                            type_named.type_name :
                            convert_type_name_to_string(data, type_named.type, type_named.type_name));
        } else {
            if (argument.name != "")
                ss << argument.name << ": ";
            else
                ss << "_: ";

            var type_not_named = std::get<TypeNotNamed>(argument.type);

            ss << std::string(type_not_named.pointer_level, '^') << 
                            (type_not_named.type == FieldType::ENUM ?
                            convert_enum_decl_to_string(data, data->enum_decls[type_not_named.index], false) :
                            convert_struct_decl_to_string(data, data->struct_decls[type_not_named.index], false));
        }

        ss << ", ";
    }

    if (decl.arguments.size() > 0)
        ss.seekp(-2, ss.cur);

    ss << ")";

    if (std::holds_alternative<TypeNamed>(decl.return_type)) {
        var type_named = std::get<TypeNamed>(decl.return_type);

        trim_spaces_string(type_named.type_name);

        if (type_named.type_name != "void") {
            ss << " -> ";
            ss << convert_type_name_to_string(data, type_named.type, type_named.type_name);
        }
    } else {
        var type_not_named = std::get<TypeNotNamed>(decl.return_type);

        ss << " -> " << std::string(type_not_named.pointer_level, '^');

        if (type_not_named.type == FieldType::ENUM) {
            ss << convert_enum_decl_to_string(data, data->enum_decls[type_not_named.index], false);
        } else {
            ss << convert_struct_decl_to_string(data, data->struct_decls[type_not_named.index], false);
        }
    }

    ss << " --- ";

    return ss.str();
}

function modify_type_def(SaveData ref data, TypeDef ref type_def) -> void {
    GET_RAW_COMMENT(type_def.cursor);
    type_def.comment_text = comments;

    strip_prefix(type_def.name, data.remove_prefixes);

    if (unallowed_keywords_in_odin.find(type_def.name) != unallowed_keywords_in_odin.end()) {
        type_def.name += "_t";
    }

    // if (type_def.is_proc_type) 
    //     return;
    
    #if DEBUG_PRINT
    if (type_def.type_name.find("(*") != std::string::npos)
        std::cout << "FUNCTION PTR IS: " << type_def.type_name << std::endl;
    #endif

    if (FIND_FUNCTION_PTR(type_def.type_name)) {
        type_def.is_proc_type = true;
        type_def.type_name = convert_c_fptr_to_odin_fptr(ref data, type_def.type, type_def.type_name);
        return;
    }

    if (FIND_ARRAY_BRACES(type_def.type_name)) {
        var type = type_def.type;
        var array_size = clang_getArraySize(type);

        while (array_size != -1) {
            type_def.array_sizes.push_back(cast(int, array_size));
            type = clang_getArrayElementType(type);

            array_size = clang_getArraySize(type);
        }

        std::reverse(type_def.array_sizes.begin(), type_def.array_sizes.end());
    }

    bool is_struct = type_def.type_name.find("struct ") != std::string::npos;
    bool is_enum = type_def.type_name.find("enum ") != std::string::npos;
    bool is_union = type_def.type_name.find("union ") != std::string::npos;

    if (!(is_struct || is_enum || is_union)) {
        return;
    }

    type_def.anonymous = false;

    bool is_unnamed = FIND_ANONYMOUS(type_def.type_name);
    type_def.pointer_level = (unsigned int)std::count(type_def.type_name.begin(), type_def.type_name.end(), '*');

    if (is_enum) {
        type_def.is = TypeDef::IS::ENUM;

        if (is_unnamed) {
            type_def.anonymous = true;
            return;
        }

        if (type_def.pointer_level == 0) {
            var type_to_check = type_def.type_name.substr(6, type_def.type_name.size()-5-type_def.pointer_level);

            bool found = false;

            for (let decl in data.enum_decls) {
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
            var type_to_check = type_def.type_name.substr(7, type_def.type_name.size()-6-type_def.pointer_level);

            bool found = false;

            for (let decl in data.struct_decls) {
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

function parse_function(SaveData ptr data, std::string name, CXCursor cursor) -> void {
    FunctionDecl decl;

    for (let decl in data->function_decls) {
        if (decl.name == name) {
            return;
        }
    }

    GET_RAW_COMMENT(cursor);
    decl.comment_text = comments;

    decl.name = name;

    var num_arguments = clang_Cursor_getNumArguments(cursor);

    decl.arguments.reserve(num_arguments);

    for (var i = 0; i < num_arguments; i++) {
        var argument_cursor = clang_Cursor_getArgument(cursor, (unsigned int)i);

        var name = std::string(cast(char ptr, clang_getCursorSpelling(argument_cursor).data));

        var type = clang_getCursorType(argument_cursor);

        Argument argument;
        argument.type = convert_type_to_string(data, type);

        argument.name = name;

        decl.arguments.push_back(
            argument
        );
    }

    var return_type = clang_getCursorResultType(cursor);

    decl.return_type = convert_type_to_string(data, return_type);
    
    data->function_decls.push_back(decl);
}


// 'recurse' doesn't really make sense here, but I couldn't figure out what to name it.
function recurse_enum(SaveData ptr data, std::string name, CXCursor cursor, bool declaring) -> void {
    EnumDecl decl;

    decl.name = name;
    GET_RAW_COMMENT(cursor);

    decl.comment_text = comments;

    data->current_data = ref decl;
    
    clang_visitChildren(
        cursor,
        [](CXCursor cursor, CXCursor parent, CXClientData client_data) -> CXChildVisitResult {
            var data = cast(SaveData ptr, client_data);

            switch (cursor.kind) {
                case CXCursor_EnumConstantDecl:
                    {
                        var decl = cast(EnumDecl ptr, data->current_data);
                        GET_RAW_COMMENT(cursor);

                        std::string name = cast(char ptr, clang_getCursorSpelling(cursor).data);
                        unsigned long long value = clang_getEnumConstantDeclUnsignedValue(cursor);
                        long long value2 = clang_getEnumConstantDeclValue(cursor);

                        bool is_negative = (long long)value > value2;

                        decl->constants.push_back({ name, is_negative, cast(uint64_t, is_negative ? -value2 : value), comments });
                    }

                    break;
            }

            return CXChildVisit_Continue;
        },
        data
    );

    var i = 0;
    var found = false;
    for (let decl in data->enum_decls) {
        if (decl.name == name) {
            found = true;
            break;
        }

        i++;
    }

    if (found && name != "" && declaring)
        data->enum_decls[i] = decl;
    else
        data->enum_decls.push_back(decl);
}

function recurse_struct(SaveData ptr data, std::string name, CXCursor cursor, bool is_union, bool declaring) -> void {
    StructDecl decl; 

    decl.name = name;
    decl.fields.reserve(1);
    decl.is_union = is_union;
    GET_RAW_COMMENT(cursor);
    decl.comment_text = comments;

    data->current_data = ref decl;

    clang_visitChildren(
        cursor,
        [](CXCursor cursor, CXCursor parent, CXClientData client_data) -> CXChildVisitResult {
            var data = cast(SaveData ptr, client_data);
            bool is_union = false;

            switch (cursor.kind) {
                case CXCursor_FieldDecl:
                    {
                        StructField field;
                        GET_RAW_COMMENT(cursor);
                        field.comment_text = comments;

                        var type = clang_getCursorType(cursor);

                        var type_name = std::string((char ptr)clang_getTypeSpelling(type).data);

                        field.name = (char ptr)clang_getCursorSpelling(cursor).data;

                        strip_prefix(field.name, data->remove_prefixes);
                        if (unallowed_keywords_in_odin.find(field.name) != unallowed_keywords_in_odin.end()) {
                            field.name += "_v";
                        }

                        field.is_type_named = !FIND_ANONYMOUS(type_name);

                        #define FIELDS cast(StructDecl ptr, data->current_data)->fields

                        if (field.is_type_named) {
                            field.type_named.type = type;
                            field.type_named.type_name = type_name;

                            if (FIND_FUNCTION_PTR(type_name) && FIELDS.size() > 0 && FIELDS[FIELDS.size()-1].name == "_") {
                                FIELDS.pop_back();
                            }
                        } else {
                            field.type_not_named.pointer_level = (unsigned int)std::count(type_name.begin(), type_name.end(), '*');

                            if (type_name.find("struct") != std::string::npos) {
                                field.type_not_named.type = FieldType::STRUCT;

                                field.type_not_named.index = data->struct_decls.size()-1;
                            } else {
                                field.type_not_named.type = FieldType::ENUM;

                                field.type_not_named.index = data->enum_decls.size()-1;
                            }

                            FIELDS.pop_back();
                        }
                        

                        FIELDS.push_back(field);                        
                        #undef FIELDS
                    }

                    break;

                case CXCursor_UnionDecl:
                    is_union = true;
                case CXCursor_StructDecl:
                    {
                        void ptr current_data = data->current_data;

                        std::string name = cast(char ptr, clang_getCursorSpelling(cursor).data);

                        recurse_struct(data, name, cursor, is_union);

                        data->current_data = current_data;

                        StructField field;
                        field.name = "_";
                        field.is_type_named = false;
                        field.type_not_named.index = data->struct_decls.size()-1;
                        field.type_not_named.pointer_level = 0;
                        field.type_not_named.type = FieldType::STRUCT;

                        cast(StructDecl ptr, data->current_data)->fields.push_back(field);
                    }

                    break;

                case CXCursor_EnumDecl:
                    {
                        void ptr current_data = data->current_data;

                        std::string name = cast(char ptr, clang_getCursorSpelling(cursor).data);

                        recurse_enum(data, name, cursor);

                        data->current_data = current_data;

                        StructField field;
                        field.name = "_";
                        field.is_type_named = false;
                        field.type_not_named.index = data->enum_decls.size()-1;
                        field.type_not_named.pointer_level = 0;
                        field.type_not_named.type = FieldType::ENUM;

                        cast(StructDecl ptr, data->current_data)->fields.push_back(field);
                    }

                    break;
            }

            return CXChildVisit_Continue;
        },       
        data
    );

    int i = 0;
    bool found = false;
    for (let decl in data->struct_decls) {
        if (decl.name == name) {
            found = true;
            break;
        }

        i++;
    }

    if (found && name != "" && declaring) 
        data->struct_decls[i] = decl;
    else
        data->struct_decls.push_back(decl);
}

static inline CXVisitorResult build_queue(CXCursor cursor, CXCursor parent, CXClientData client_data) {
    CXSourceLocation location = clang_getCursorLocation(cursor);

    if(clang_Location_isInSystemHeader(location) != 0)
        return CXVisit_Continue;
    
    var ptr queue = cast(DataQueue ptr, client_data);

    switch (cursor.kind) {
        case CXCursor_StructDecl:
            {
                DataEntry entry;
                entry.is = DataEntry::IS::STRUCT;
                entry.cursor = cursor;
                entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);    
            }
            break;
        
        case CXCursor_MacroDefinition: 
        case CXCursor_MacroExpansion:
            {
                // probably just going to make my own macro parser instead, since it seems 
                // to have done all the macro parsing by now
                // for the meantime, I should just get started on removing redudant enum
                // constant prefixes..
                var is_function_like = clang_Cursor_isMacroFunctionLike(cursor);

                #if DEBUG_PRINT
                std::cout << "MACRO IS FUNCTION LIKE?: " << is_function_like << std::endl;
                #endif

                // what we don't want, because most likely we won't able to even parse a 
                // function like macro in the first place
                if (is_function_like) break;

                var definition_cursor = clang_getCursorDefinition(cursor);
                var result = clang_Cursor_Evaluate(cursor);


                DataEntry entry;
                entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);
                entry.cursor = cursor;
                entry.is = DataEntry::IS::CONSTANT;

                std::cout << "MACRO EVALUATION: " << clang_EvalResult_getKind(result) << std::endl;
                std::cout << "CURSOR KIND: " << (char ptr)clang_getCursorDisplayName(cursor).data << std::endl;
                
                switch (clang_EvalResult_getKind(result)) {
                    case CXEval_Float:
                        {
                            var r = clang_EvalResult_getAsDouble(result);

                            entry.constant_string = std::to_string(r);
                        }
                        break;
                    
                    case CXEval_Int:
                        {
                            if (!clang_EvalResult_isUnsignedInt(result)) {
                                var r = clang_EvalResult_getAsLongLong(result);
                                entry.constant_string = std::to_string(r);
                            } else {
                                var r = clang_EvalResult_getAsUnsigned(result);
                                entry.constant_string = std::to_string(r);
                            }
                        }
                        break;
                    
                    case CXEval_StrLiteral:
                        {
                            var r = clang_EvalResult_getAsStr(result);
                            entry.constant_string = r;
                        }
                        break;
                }

                queue->data.push_back(entry);
            }
            break;
        
        case CXCursor_UnionDecl:
            {
                DataEntry entry;
                entry.is = DataEntry::IS::UNION;
                entry.cursor = cursor;
                entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);    
            }
            break;

        case CXCursor_EnumDecl: 
            {
                DataEntry entry;
                entry.is = DataEntry::IS::ENUM;
                entry.cursor = cursor;
                entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);
            }
            break;

        case CXCursor_TypedefDecl:
            {
                DataEntry entry;
                entry.is = DataEntry::IS::TYPEDEF;
                entry.cursor = cursor;
                entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);
            }
            break;

        case CXCursor_FunctionDecl:
            {
                DataEntry entry;
                entry.is = DataEntry::IS::FUNCTION;
                entry.cursor = cursor;
                entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

                queue->data.push_back(entry);
            }
            break;
            
    }

    return CXVisit_Continue;
}

