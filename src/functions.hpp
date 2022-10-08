#pragma once
#include <string>
#include <vector>
#include "data_types.hpp"
#include "essential_macros.hpp"

#define FIND_FUNCTION_PTR(variable) (variable.find("(*") != std::string::npos && (variable.find("*)") != std::string::npos || variable.find("])") != std::string::npos))
#define FIND_ANONYMOUS(variable) (variable.find("anonymous ") != std::string::npos || variable.find("unnamed ") != std::string::npos)
#define GET_RAW_COMMENT(cursor) std::vector<std::string> comments; { var range = clang_Cursor_getCommentRange(cursor); if (range.begin_int_data != 0 && range.end_int_data != 0) { std::string comment = cast(char ptr, clang_Cursor_getRawCommentText(cursor).data); comments = strip_unnecessary_newline(comment); }  }
#define FIND_ARRAY_BRACES(variable) (variable.find("[") != std::string::npos && variable.find("]") != std::string::npos)

function strip_unnecessary_newline(std::string ref str) -> std::vector<std::string>
Begin
    var r_index = str.find('\r');

    While r_index != std::string::npos Then
        str.erase(r_index, 1);

        r_index = str.find('\r');
    End

    var newline_index = str.find('\n');

    While newline_index != std::string::npos Then
        If newline_index == str.size()-1 || newline_index == 0 Then
            str = str.erase(newline_index, 1);
        Elif str[newline_index+1] != '\n' Then
            str[newline_index] = '\b';
            // str = str.erase(newline_index+1, 1);
        End
        
        newline_index = str.find('\n');
    End

    var b_index = str.find('\b');

    While b_index != std::string::npos Then
        str[b_index] = '\n';

        b_index = str.find('\b');
    End

    std::stringstream ss(str);
    std::string STR;
    std::vector<std::string> results;

    While std::getline(ss, STR, '\n') Then
        results.push_back(STR);
    End

    return results;
End

function get_rid_of_const(std::string ref type_name) -> void 
Begin
    var const_index = type_name.find("const ");

    #if DEBUG_PRINT
    std::cout << "TYPE NAME BEFORE REMOVEMENT OF CONST: " << type_name << std::endl; 
    #endif

    var decrease = false;

    While const_index != std::string::npos Then
        type_name = type_name.erase(const_index, (decrease ? 5 : 6));
        const_index = type_name.find("const");

        #if DEBUG_PRINT 
        std::cout << "PROGRESS ON CONST REMOVING: " << type_name << std::endl;
        #endif 

        decrease = true;
    End
End

function trim_spaces_string(std::string ref type_name) -> void;

function get_rid_of_pointer(std::string ref type_name) -> int
Begin
    var pointer_index = type_name.find("*");

    var pointer_level = 0;

    var found_pointer = false;

    While pointer_index != std::string::npos Then
        type_name = type_name.erase(pointer_index, 1);
        pointer_index = type_name.find("*");
        found_pointer = true;

        pointer_level++;
    End

    If found_pointer Then
        trim_spaces_string(type_name);
    End

    #if DEBUG_PRINT 
    std::cout << "TRIMMED POINTER FOR: " << type_name << std::endl;
    #endif

    return pointer_level;
End

function trim_spaces_string(std::string ref type_name) -> void 
Begin
    var space_index = type_name.find(' ');

    While space_index != std::string::npos Then
        If space_index == type_name.size()-1 || space_index == 0 Then
            type_name = type_name.erase(space_index, 1);
        Elif type_name[space_index+1] != ' ' Then
            type_name[space_index] = '\b';
        Else
            type_name[space_index] = '\b';
        End
        
        space_index = type_name.find(' ');

        #if DEBUG_PRINT
        std::cout << "CURRENT TRIMMING OF SPACES: " << type_name << std::endl;
        #endif
    End

    var b_index = type_name.find('\b');

    While b_index != std::string::npos Then
        type_name[b_index] = ' ';

        b_index = type_name.find('\b');
    End
End

function convert_to_c_keyword(std::string type_name) -> std::string 
Begin
    If c_keyword_to_odin.find(type_name) != c_keyword_to_odin.end() Then
        return c_keyword_to_odin[type_name];
    End

    return type_name;
End

function strip_enum_and_struct(std::string ref str) -> void 
Begin
    let enum_idx = str.find("enum ");
    let struct_idx = str.find("struct ");
    let union_idx = str.find("union ");

    If enum_idx != std::string::npos Then
        str = str.erase(enum_idx, 4);
    Elif struct_idx != std::string::npos Then
        str = str.erase(struct_idx, 6);
    Elif union_idx != std::string::npos Then
        str = str.erase(union_idx, 5);
    End
End

function strip_prefix(std::string ref str, std::vector<std::string> remove_prefixes) -> std::string 
Begin
    std::string prefix_stripped = "";

    size_t prefix_index = 0;

    var i = 0;
    While prefix_index != std::string::npos Then
        prefix_index = std::string::npos;

        For let prefix in remove_prefixes Then
            prefix_index = str.find(prefix);

            If prefix_index != std::string::npos && prefix_index == 0 Then
                str = str.erase(prefix_index, prefix.length());
                prefix_stripped += prefix;
            End
        End

        i++;

        If i > 1000 Then
            // just give up after a while.
            break;
        End
    End

    return prefix_stripped;
End

function convert_c_fptr_to_odin_fptr(SaveData ptr data, CXType type, std::string fptr) -> std::string;
function recurse_enum(SaveData ptr data, std::string name, CXCursor cursor, bool declaring = false) -> void;
function recurse_struct(SaveData ptr data, std::string name, CXCursor cursor, bool is_union, bool declaring = false) -> void;

// this shouldn't be `to_string` but I don't want to chnage it right now because I'm lazy.
function convert_type_to_string(SaveData ptr data, CXType type) -> std::variant<TypeNamed, TypeNotNamed> 
Begin
    var type_name = std::string((char ptr)clang_getTypeSpelling(type).data);

    std::vector<int> array_sizes;

    If FIND_FUNCTION_PTR(type_name) Then
        type_name = convert_c_fptr_to_odin_fptr(data, type, type_name);

        return TypeNamed {
            type_name,
            type,
            array_sizes,
        };
    
    End

    If FIND_ARRAY_BRACES(type_name) Then
        var array_size = clang_getArraySize(type);

        While array_size != -1 Then
            array_sizes.push_back(cast(int, array_size));
            type = clang_getArrayElementType(type);
            array_size = clang_getArraySize(type);
        End

        std::reverse(array_sizes.begin(), array_sizes.end());
    End

    let is_enum = type_name.find("enum ") != std::string::npos;
    let is_union = type_name.find("union ") != std::string::npos;

    let is_named = !FIND_ANONYMOUS(type_name);

    If is_named Then
        strip_enum_and_struct(type_name);
        return TypeNamed {
            type_name,
            type,
            array_sizes,
        };
    End

    var pointer_level = get_rid_of_pointer(type_name);

    For var i = 0; i < pointer_level; i++ Then
        type = clang_getPointeeType(type);
    End

    let if_struct_or_enum = clang_getTypeDeclaration(type);

    If is_enum Then
        recurse_enum(data, "", if_struct_or_enum);
    Else
        recurse_struct(data, "", if_struct_or_enum, is_union);
    End

    return TypeNotNamed {
        (is_enum ? data->enum_decls.size()-1 : data->struct_decls.size()-1),
        (is_enum ? FieldType::ENUM : FieldType::STRUCT),
        pointer_level,
        array_sizes,
    };
End

function convert_enum_decl_to_string(SaveData ptr data, EnumDecl decl, bool add_new_line_to_each_field = true) -> std::string;
function convert_struct_decl_to_string(SaveData ptr data, StructDecl decl, bool add_new_line_to_each_field = true) -> std::string;
function convert_type_name_to_string(SaveData ptr data, CXType type, std::string type_name) -> std::string;

function convert_c_fptr_to_odin_fptr(SaveData ptr data, CXType type, std::string fptr) -> std::string 
Begin
    If !FIND_FUNCTION_PTR(fptr) Then
        return fptr;
    End

    std::stringstream final_str;

    // to handle the potential possibility that a lunatic would create a typedef of a function pointer, and want more than 1.
    Begin
        var array_size = clang_getArraySize(type);

        While array_size != -1 Then
            final_str << "[" << array_size << "]";

            type = clang_getArrayElementType(type);
            array_size = clang_getArraySize(type);
        End

        fptr = (char ptr)clang_getTypeSpelling(type).data;
    End

    Begin
        let starting_position = fptr.find("(*");
        let ending_position = fptr.find("*)");

        var pointers = fptr.substr(starting_position, ending_position-starting_position+1);

        var pointer_level = get_rid_of_pointer(pointers);

        final_str << std::string(pointer_level-1, '^');

        #if DEBUG_PRINT
        std::cout << "TYPE SPELLING: " << (char ptr)clang_getTypeSpelling(type).data << std::endl;
        #endif

        // std::cout << "CURSOR TYPENAME: " << (char ptr)clang_getCursorSpelling(cursor).data << std::endl;

        // CXType type = clang_getCursorType(cursor);

        For var i = 0; i < pointer_level; i++ Then
            type = clang_getPointeeType(type);
        End        

        // cursor = clang_getTypeDeclaration(type);
    End

    #if DEBUG_PRINT
    std::cout << "TYPE SPELLING: " << (char ptr)clang_getTypeSpelling(type).data << std::endl;
    #endif

    final_str << "proc \"c\" (";

    let argument_amount = clang_getNumArgTypes(type);

    For var i = 0; i < argument_amount; i++ Then
        let argument_type = clang_getArgType(type, (unsigned int)i);

        let _type = convert_type_to_string(data, argument_type);

        If std::holds_alternative<TypeNamed>(_type) Then
            var type = std::get<TypeNamed>(_type);
            final_str << convert_type_name_to_string(data, type.type, type.type_name);
        Else
            var type = std::get<TypeNotNamed>(_type);

            final_str << std::string(type.pointer_level, '^'); 

            For let array_size in type.array_sizes Then
                final_str << "[" << array_size << "]";
            End

            If type.type == FieldType::ENUM Then
                final_str << convert_enum_decl_to_string(data, data->enum_decls[type.index], false);
            Else
                final_str << convert_struct_decl_to_string(data, data->struct_decls[type.index], false);
            End
        End

        final_str << ", ";
    End

    If argument_amount > 0 Then
        final_str.seekp(-2, final_str.cur);
    End

    final_str << ')';

    let return_type_type = clang_getResultType(type);

    #if DEBUG_PRINT
    std::cout << return_type_type.kind << std::endl;
    #endif

    let return_type = convert_type_to_string(data, return_type_type);

    If std::holds_alternative<TypeNamed>(return_type) Then
        var type_named = std::get<TypeNamed>(return_type);

        trim_spaces_string(type_named.type_name);

        If type_named.type_name != "void" Then
            final_str << " -> ";
            final_str << convert_type_name_to_string(data, type_named.type, type_named.type_name);
        End
    Else
        let type_not_named = std::get<TypeNotNamed>(return_type);

        final_str << " -> " << std::string(type_not_named.pointer_level, '^');

        If type_not_named.type == FieldType::ENUM Then
            final_str << convert_enum_decl_to_string(data, data->enum_decls[type_not_named.index], false);
        Else
            final_str << convert_struct_decl_to_string(data, data->struct_decls[type_not_named.index], false);
        End
    End

    return final_str.str();
End

function convert_type_name_to_string(SaveData ptr data, CXType type, std::string type_name) -> std::string 
Begin
    std::stringstream ss;

    If FIND_FUNCTION_PTR(type_name) Then
        return convert_c_fptr_to_odin_fptr(data, type, type_name);
    End

    If type_name.find("proc(") != std::string::npos Then 
        return type_name;
    End 

    strip_enum_and_struct(type_name);
    
    get_rid_of_const(type_name);

    std::vector<std::string> array_size_strings;

    While FIND_ARRAY_BRACES(type_name) Then
        let starting_index = type_name.find("[");
        let ending_index = type_name.find("]");

        let number = type_name.substr(starting_index+1, ending_index-starting_index);

        std::string array_size_string = "[" + number;
        array_size_strings.push_back(array_size_string);

        type_name = type_name.erase(starting_index, ending_index-starting_index+1);
    End

    std::reverse(array_size_strings.begin(), array_size_strings.end());

    For let array_size_string in array_size_strings Then
        #if DEBUG_PRINT
        std::cout << type_name << ": " << array_size_string << std::endl;
        #endif

        ss << array_size_string;
    End

    Begin
        var pointer_level = get_rid_of_pointer(type_name);

        strip_prefix(type_name, data->remove_prefixes);
        trim_spaces_string(type_name);

        If unallowed_keywords_in_odin.find(type_name) != unallowed_keywords_in_odin.end() Then
            type_name += "_t";
        End
        
        If type_name == "void" && pointer_level >= 1 Then
            pointer_level -= 1;
            type_name = "rawptr";
        End

        If type_name == "char" && data->convert_char_pointer_to_cstring && pointer_level >= 1 Then
            pointer_level -= 1;
            type_name = "cstring";
        End

        ss << std::string(pointer_level, '^');

        ss << convert_to_c_keyword(type_name);
    End

    return ss.str();
End

function convert_enum_decl_to_string(SaveData ptr data, EnumDecl decl, bool add_new_line_to_each_field) -> std::string 
Begin
    std::stringstream ss;

    ss << "enum {";

    If decl.constants.size() == 0 Then
        ss << '}';
        return ss.str();
    End

    // if (decl.comment_text != "" && add_new_line_to_each_field) 
    //     ss << decl.comment_text;
    // else if (decl.comment_text != "")
    //     ss << "/* " << decl.comment_text << " */";

    If add_new_line_to_each_field Then
        ss << '\n'; 
    End
    
    For let constant in decl.constants Then
        var name = std::get<0>(constant);
        let is_negative = std::get<1>(constant);
        let value = std::get<2>(constant);
        let comment_text_ = std::get<3>(constant);

        strip_prefix(name, data->remove_constant_prefixes);

        If add_new_line_to_each_field Then
            ss << std::string(data->recursion_level+1, '\t');
        Else
            ss << " ";
        End

        For let comment_text in comment_text_ Then
            If comment_text != "" Then
                If add_new_line_to_each_field Then
                    ss << comment_text << '\n';
                    ss << std::string(data->recursion_level+1, '\t');
                Else
                    ss << "/* " << comment_text << " */ ";
                End
            End
        End

        ss << name << " = " << std::string(is_negative, '-') << value << ','; 
        
        If add_new_line_to_each_field Then
            ss << "\n";
        Else
            ss << " ";
        End
    End

    If add_new_line_to_each_field Then
        ss << std::string(data->recursion_level, '\t');
    End

    ss << '}';

    return ss.str();
End 

function convert_struct_decl_to_string(SaveData ptr data, StructDecl decl, bool add_new_line_to_each_field) -> std::string 
Begin
    std::stringstream ss;

    ss << "struct ";

    If decl.is_union Then
        ss << "#raw_union ";
    End

    ss << '{';

    // if (decl.comment_text != "" && add_new_line_to_each_field)
    //     ss << decl.comment_text;
    // else if (decl.comment_text != "") 
    //     ss << "/* " << decl.comment_text << " */";

    If decl.fields.size() == 0 Then
        ss << '}';
        return ss.str();
    End

    If add_new_line_to_each_field Then
        ss << '\n'; 
    End

    For var field in decl.fields Then
        If add_new_line_to_each_field Then
            ss << std::string(data->recursion_level+1, '\t');
        Else 
            ss << " ";
        End
        
        For let comment_text in field.comment_text Then
            If comment_text != "" Then
                If add_new_line_to_each_field Then
                    ss << comment_text << '\n';
                    ss << std::string(data->recursion_level+1, '\t');
                Else
                    ss << "/* " << comment_text << " */ ";
                End
            End
        End

        If field.name == "_" && !field.is_type_named Then
            ss << "using ";
        End

        #if DEBUG_PRINT 
        std::cout << "STRUCT FIELD NAME IS: " << field.name << std::endl;
        #endif

        If unallowed_keywords_in_odin.find(field.name) != unallowed_keywords_in_odin.end() Then
            field.name += "_v";
        End

        Switch field.is_type_named Then
            Case(true)
                trim_spaces_string(field.type_named.type_name);
                If field.type_named.type_name == field.name Then
                    ss << field.name << "_v: ";
                Else
                    ss << field.name << ": ";
                End
                
                ss << convert_type_name_to_string(data, field.type_named.type, field.type_named.type_name);
            EndCase

            Case(false)
                ss << field.name << ": ";

                Switch field.type_not_named.type Then
                    Case(FieldType::STRUCT)
                        ss << std::string(field.type_not_named.pointer_level, '^');

                        data->recursion_level += 1;        

                        ss << convert_struct_decl_to_string(data, data->struct_decls[field.type_not_named.index]); 

                        data->recursion_level -= 1;
                    EndCase

                    Case(FieldType::ENUM)
                        ss << std::string(field.type_not_named.pointer_level, '^');

                        data->recursion_level += 1;

                        ss << convert_enum_decl_to_string(data, data->enum_decls[field.type_not_named.index]);

                        data->recursion_level -= 1;
                    EndCase
                End
            EndCase
        End

        ss << ",";

        If add_new_line_to_each_field Then
            ss << "\n";
        Else 
            ss << " ";
        End
    End

    If add_new_line_to_each_field Then
        ss << std::string(data->recursion_level, '\t');
    End
    
    ss << '}';
    
    return ss.str();
End

function convert_function_decl_to_string(SaveData ptr data, FunctionDecl decl) -> std::string 
Begin
    std::stringstream ss;

    // strip_prefix(decl.name, data->remove_prefixes);

    For let comment_text in decl.comment_text Then
        If comment_text != "" Then
            ss << std::string(data->recursion_level, '\t') << comment_text << '\n';
        End
    End

    ss << std::string(data->recursion_level, '\t') << decl.name << " :: proc(";
    For var argument in decl.arguments Then
        If unallowed_keywords_in_odin.find(argument.name) != unallowed_keywords_in_odin.end() Then
            argument.name += "_v";
        End

        If std::holds_alternative<TypeNamed>(argument.type) Then
            let type_named = std::get<TypeNamed>(argument.type);

            If argument.name != "" && argument.name != type_named.type_name Then
                ss << argument.name << ": ";
            Elif argument.name == type_named.type_name Then
                ss << argument.name << "_v: ";
            Else
                ss << "_: ";
            End
            
            ss << (type_named.type_name.find("proc") != std::string::npos ? 
                            type_named.type_name :
                            convert_type_name_to_string(data, type_named.type, type_named.type_name));
        Else
            If argument.name != "" Then
                ss << argument.name << ": ";
            Else
                ss << "_: ";
            End

            let type_not_named = std::get<TypeNotNamed>(argument.type);

            ss << std::string(type_not_named.pointer_level, '^') << 
                            (type_not_named.type == FieldType::ENUM ?
                            convert_enum_decl_to_string(data, data->enum_decls[type_not_named.index], false) :
                            convert_struct_decl_to_string(data, data->struct_decls[type_not_named.index], false));
        End

        ss << ", ";
    End

    If decl.arguments.size() > 0 Then
        ss.seekp(-2, ss.cur);
    End

    ss << ")";

    If std::holds_alternative<TypeNamed>(decl.return_type) Then
        var type_named = std::get<TypeNamed>(decl.return_type);

        trim_spaces_string(type_named.type_name);

        If type_named.type_name != "void" Then
            ss << " -> ";
            ss << convert_type_name_to_string(data, type_named.type, type_named.type_name);
        End
    Else
        let type_not_named = std::get<TypeNotNamed>(decl.return_type);

        ss << " -> " << std::string(type_not_named.pointer_level, '^');

        If type_not_named.type == FieldType::ENUM Then
            ss << convert_enum_decl_to_string(data, data->enum_decls[type_not_named.index], false);
        Else
            ss << convert_struct_decl_to_string(data, data->struct_decls[type_not_named.index], false);
        End
    End

    ss << " --- ";

    return ss.str();
End

function modify_type_def(SaveData ref data, TypeDef ref type_def) -> void 
Begin
    GET_RAW_COMMENT(type_def.cursor);
    type_def.comment_text = comments;

    strip_prefix(type_def.name, data.remove_prefixes);

    If unallowed_keywords_in_odin.find(type_def.name) != unallowed_keywords_in_odin.end() Then
        type_def.name += "_t";
    End

    // if (type_def.is_proc_type) 
    //     return;
    
    #if DEBUG_PRINT
    If type_def.type_name.find("(*") != std::string::npos Then
        std::cout << "FUNCTION PTR IS: " << type_def.type_name << std::endl;
    End
    #endif

    If FIND_FUNCTION_PTR(type_def.type_name) Then
        type_def.is_proc_type = true;
        type_def.type_name = convert_c_fptr_to_odin_fptr(ref data, type_def.type, type_def.type_name);
        return;
    End

    If FIND_ARRAY_BRACES(type_def.type_name) Then
        var type = type_def.type;
        var array_size = clang_getArraySize(type);

        While array_size != -1 Then
            type_def.array_sizes.push_back(cast(int, array_size));
            type = clang_getArrayElementType(type);

            array_size = clang_getArraySize(type);
        End

        std::reverse(type_def.array_sizes.begin(), type_def.array_sizes.end());
    End

    let is_struct = type_def.type_name.find("struct ") != std::string::npos;
    let is_enum = type_def.type_name.find("enum ") != std::string::npos;
    let is_union = type_def.type_name.find("union ") != std::string::npos;

    If !(is_struct || is_enum || is_union) Then
        return;
    End

    type_def.anonymous = false;

    let is_unnamed = FIND_ANONYMOUS(type_def.type_name);
    type_def.pointer_level = (unsigned int)std::count(type_def.type_name.begin(), type_def.type_name.end(), '*');

    If is_enum Then
        type_def.is = TypeDef::IS::ENUM;

        If is_unnamed Then
            type_def.anonymous = true;
            return;
        End

        If type_def.pointer_level == 0 Then
            let type_to_check = type_def.type_name.substr(6, type_def.type_name.size()-5-type_def.pointer_level);

            var found = false;

            For let decl in data.enum_decls Then
                If type_to_check == decl.name Then
                    type_def.enum_decl = decl;
                    found = true;
                End
            End

            If !found Then
                type_def.anonymous = true;
            End
        End
    Else
        // we are just going to assume it's an struct at this point
        type_def.is = TypeDef::IS::STRUCT;

        If is_unnamed Then
            type_def.anonymous = true;
            return;
        End

        If type_def.pointer_level == 0 Then
            let type_to_check = type_def.type_name.substr(7, type_def.type_name.size()-6-type_def.pointer_level);

            bool found = false;

            For let decl in data.struct_decls Then
                If type_to_check == decl.name Then
                    type_def.struct_decl = decl;
                    found = true;
                End
            End

            If !found Then
                type_def.anonymous = true;
            End
        End
    End
End

function parse_function(SaveData ptr data, std::string name, CXCursor cursor) -> void 
Begin
    FunctionDecl decl;

    For let decl in data->function_decls Then 
        If decl.name == name Then 
            return;
        End
    End

    GET_RAW_COMMENT(cursor);
    decl.comment_text = comments;

    decl.name = name;

    let num_arguments = clang_Cursor_getNumArguments(cursor);

    decl.arguments.reserve(num_arguments);

    For var i = 0; i < num_arguments; i++ Then 
        let argument_cursor = clang_Cursor_getArgument(cursor, (unsigned int)i);

        let name = std::string(cast(char ptr, clang_getCursorSpelling(argument_cursor).data));

        let type = clang_getCursorType(argument_cursor);

        Argument argument;
        argument.type = convert_type_to_string(data, type);

        argument.name = name;

        decl.arguments.push_back(
            argument
        );
    End

    let return_type = clang_getCursorResultType(cursor);

    decl.return_type = convert_type_to_string(data, return_type);
    
    data->function_decls.push_back(decl);
End


// 'recurse' doesn't really make sense here, but I couldn't figure out what to name it.
function recurse_enum(SaveData ptr data, std::string name, CXCursor cursor, bool declaring) -> void 
Begin
    EnumDecl decl;

    decl.name = name;
    GET_RAW_COMMENT(cursor);

    decl.comment_text = comments;

    Struct PassData Begin
        EnumDecl ptr decl;
        std::string prefix_to_remove;
    EndRecord

    PassData pass_data;
    pass_data.decl = ref decl;
    pass_data.prefix_to_remove = "";

    data->current_data = ref pass_data;
    
    clang_visitChildren(
        cursor,
        [](CXCursor cursor, CXCursor parent, CXClientData client_data) -> CXChildVisitResult 
        Begin
            var data = cast(SaveData ptr, client_data);

            Switch cursor.kind Then 
                Case(CXCursor_EnumConstantDecl)
                    let pass_data = cast(PassData ptr, data->current_data);

                    var prefix_to_remove = ref pass_data->prefix_to_remove;
                    var decl = pass_data->decl;
                    GET_RAW_COMMENT(cursor);

                    std::string name = cast(char ptr, clang_getCursorSpelling(cursor).data);
                    let value = clang_getEnumConstantDeclUnsignedValue(cursor);
                    let value2 = clang_getEnumConstantDeclValue(cursor);

                    let is_negative = cast(long long, value) > value2; 

                    If deref prefix_to_remove == "" Then
                        deref prefix_to_remove = name;
                    Else
                        For var i = name.size(); i > 0; i-- Then
                            let prefix = name.substr(0, i);
                            let a = prefix_to_remove->find(prefix);

                            If a == 0 Then 
                                deref prefix_to_remove = prefix;
                                break;
                            End
                        End
                    End

                    decl->constants.push_back({ name, is_negative, cast(uint64_t, is_negative ? -value2 : value), comments });
                EndCase
            End

            return CXChildVisit_Continue;
        End,
        data
    );

    var i = 0;
    var found = false;
    For let decl in data->enum_decls Then 
        If decl.name == name Then 
            found = true;
            break;
        End

        i++;
    End

    For var ref constant in decl.constants Then 
        var ref name = std::get<0>(constant);

        If name == pass_data.prefix_to_remove Then
            continue;
        End

        name.erase(0, pass_data.prefix_to_remove.size());
    End

    If found && name != "" && declaring Then
        data->enum_decls[i] = decl;
    Else
        data->enum_decls.push_back(decl);
    End
End

function recurse_struct(SaveData ptr data, std::string name, CXCursor cursor, bool is_union, bool declaring) -> void 
Begin
    StructDecl decl; 

    decl.name = name;
    decl.fields.reserve(1);
    decl.is_union = is_union;
    GET_RAW_COMMENT(cursor);
    decl.comment_text = comments;

    data->current_data = ref decl;

    clang_visitChildren(
        cursor,
        [](CXCursor cursor, CXCursor parent, CXClientData client_data) -> CXChildVisitResult 
        Begin
            var data = cast(SaveData ptr, client_data);
            var is_union = false;

            Switch cursor.kind Then 
                Case(CXCursor_FieldDecl)
                    StructField field;
                    GET_RAW_COMMENT(cursor);
                    field.comment_text = comments;

                    let type = clang_getCursorType(cursor);

                    let type_name = std::string((char ptr)clang_getTypeSpelling(type).data);

                    field.name = (char ptr)clang_getCursorSpelling(cursor).data;

                    strip_prefix(field.name, data->remove_prefixes);
                    If unallowed_keywords_in_odin.find(field.name) != unallowed_keywords_in_odin.end() Then 
                        field.name += "_v";
                    End

                    field.is_type_named = !FIND_ANONYMOUS(type_name);

                    #define FIELDS cast(StructDecl ptr, data->current_data)->fields

                    If field.is_type_named Then 
                        field.type_named.type = type;
                        field.type_named.type_name = type_name;

                        If FIND_FUNCTION_PTR(type_name) && FIELDS.size() > 0 && FIELDS[FIELDS.size()-1].name == "_" Then 
                            FIELDS.pop_back();
                        End
                    Else
                        field.type_not_named.pointer_level = (unsigned int)std::count(type_name.begin(), type_name.end(), '*');

                        If type_name.find("struct") != std::string::npos Then 
                            field.type_not_named.type = FieldType::STRUCT;

                            field.type_not_named.index = data->struct_decls.size()-1;
                        Else
                            field.type_not_named.type = FieldType::ENUM;

                            field.type_not_named.index = data->enum_decls.size()-1;
                        End

                        FIELDS.pop_back();
                    End
                    

                    FIELDS.push_back(field);                        
                    #undef FIELDS
                EndCase

                Case(CXCursor_UnionDecl)
                    is_union = true;
                Case(CXCursor_StructDecl)
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
                EndCase
                EndCase

                Case(CXCursor_EnumDecl)
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
                EndCase
            End

            return CXChildVisit_Continue;
        End,       
        data
    );

    var i = 0;
    var found = false;
    For let decl in data->struct_decls Then 
        If decl.name == name Then 
            found = true;
            break;
        End

        i++;
    End

    If found && name != "" && declaring Then 
        data->struct_decls[i] = decl;
    Else
        data->struct_decls.push_back(decl);
    End
End

function build_queue(CXCursor cursor, CXCursor parent, CXClientData client_data) -> CXVisitorResult 
Begin
    CXSourceLocation location = clang_getCursorLocation(cursor);

    If clang_Location_isInSystemHeader(location) != 0 Then
        return CXVisit_Continue;
    End
    
    var ptr queue = cast(DataQueue ptr, client_data);

    Switch cursor.kind Then 
        Case(CXCursor_StructDecl)
            DataEntry entry;
            entry.is = DataEntry::IS::STRUCT;
            entry.cursor = cursor;
            entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

            queue->data.push_back(entry);    
        EndCase
        
        Case(CXCursor_MacroExpansion, CXCursor_MacroDefinition)
            // probably just going to make my own macro parser instead, since it seems 
            // to have done all the macro parsing by now
            // for the meantime, I should just get started on removing redudant enum
            // constant prefixes..
            let is_function_like = clang_Cursor_isMacroFunctionLike(cursor);

            #if DEBUG_PRINT
            std::cout << "MACRO IS FUNCTION LIKE?: " << is_function_like << std::endl;
            #endif

            // what we don't want, because most likely we won't able to even parse a 
            // function like macro in the first place
            If is_function_like Then break; End

            std::cout << "IS THIS A CURSOR DEFINITION: " << clang_isCursorDefinition(cursor) << std::endl;
            std::cout << "IS THIS A PREP DEFINITION: " << clang_isPreprocessing(cursor.kind) << std::endl;

            var definition_cursor = clang_getCursorDefinition(cursor);
            var result = clang_Cursor_Evaluate(cursor);

            DataEntry entry;
            entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);
            entry.cursor = cursor;
            entry.is = DataEntry::IS::CONSTANT;

            std::cout << "MACRO EVALUATION: " << clang_EvalResult_getKind(result) << std::endl;
            std::cout << "CURSOR KIND: " << (char ptr)clang_getCursorDisplayName(cursor).data << std::endl;
            
            
            Switch clang_EvalResult_getKind(result) Then 
                Case(CXEval_Float)
                    var r = clang_EvalResult_getAsDouble(result);

                    entry.constant_string = std::to_string(r);
                EndCase
                
                Case(CXEval_Int)
                    If !clang_EvalResult_isUnsignedInt(result) Then 
                        var r = clang_EvalResult_getAsLongLong(result);
                        entry.constant_string = std::to_string(r);
                    Else
                        var r = clang_EvalResult_getAsUnsigned(result);
                        entry.constant_string = std::to_string(r);
                    End
                EndCase
                
                Case(CXEval_StrLiteral)
                    var r = clang_EvalResult_getAsStr(result);
                    entry.constant_string = r;
                EndCase
            End

            queue->data.push_back(entry);
        EndCase
        // EndCase
        
        Case(CXCursor_UnionDecl)
            DataEntry entry;
            entry.is = DataEntry::IS::UNION;
            entry.cursor = cursor;
            entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

            queue->data.push_back(entry);    
        EndCase

        Case(CXCursor_EnumDecl) 
            DataEntry entry;
            entry.is = DataEntry::IS::ENUM;
            entry.cursor = cursor;
            entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

            queue->data.push_back(entry);
        EndCase

        Case(CXCursor_TypedefDecl)
            DataEntry entry;
            entry.is = DataEntry::IS::TYPEDEF;
            entry.cursor = cursor;
            entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

            queue->data.push_back(entry);
        EndCase

        Case(CXCursor_FunctionDecl)
            DataEntry entry;
            entry.is = DataEntry::IS::FUNCTION;
            entry.cursor = cursor;
            entry.name = cast(char ptr, clang_getCursorSpelling(cursor).data);

            queue->data.push_back(entry);
        EndCase
    End

    return CXVisit_Continue;
End

