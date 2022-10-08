// only enable this if you want to debug print.
#define DEBUG_PRINT false

#include <iostream>
#include <string>
#include <vector>
#include <tuple>
#include <functional>
#include <fstream>
#include <sstream>
#include <clang-c/Index.h>
#include "keywords.hpp"
#include "data_types.hpp"
#include "functions.hpp"
#include "print_functions.hpp"

function save_to_file(SaveData ref data, std::string file_name) -> void;

function parse_file(std::string file_path, SaveData ref original_data) -> bool 
Begin
    CXIndex index        = clang_createIndex(0, 1);

    std::vector<char*> arguments;
    arguments.push_back("-fparse-all-comments");
    
    For let path in original_data.include_paths Then
        arguments.push_back(const_cast<char*>(path.c_str()));
    End
    
    CXTranslationUnit tu = clang_parseTranslationUnit(
        index, 
        file_path.c_str(), 
        arguments.data(), 
        cast(int, arguments.size()), 
        nullptr, 
        0, 
        cast(unsigned int, CXTranslationUnit_Flags::CXTranslationUnit_DetailedPreprocessingRecord)
    );

    original_data.idxs.push_back(index);
    original_data.tus.push_back(tu);
    
    #if DEBUG_PRINT
    std::cout << "EVALUATING TRANSLATION UNIT" << std::endl;
    std::cout << "RESULT: " << tu << std::endl;
    #endif

    If !tu Then
        return false;
    End

    CXCursor rootCursor = clang_getTranslationUnitCursor(tu);

    #if DEBUG_PRINT
    std::cout << "DATA:" << std::endl;

    std::cout << rootCursor.kind << std::endl;
    std::cout << rootCursor.xdata << std::endl;
    std::cout << rootCursor.data << std::endl;
    #endif

    DataQueue queue;

    clang_visitChildren(
        rootCursor, 
        (CXCursorVisitor)build_queue,
        &queue
    );

    SaveData data;
    data.remove_prefixes = original_data.remove_prefixes;
    data.remove_constant_prefixes = original_data.remove_constant_prefixes;
    data.convert_char_pointer_to_cstring = original_data.convert_char_pointer_to_cstring;

    For let entry in queue.data Then
        Switch entry.is Then
            Case(DataEntry::IS::ENUM)
                // TODO: Once enums are implemented.
                recurse_enum(&data, entry.name, entry.cursor, true);
            EndCase

            Case(DataEntry::IS::UNION)
                recurse_struct(&data, entry.name, entry.cursor, true, true);
            EndCase

            Case(DataEntry::IS::STRUCT)
                recurse_struct(&data, entry.name, entry.cursor, false, true);
            EndCase
            
            Case(DataEntry::IS::CONSTANT)
                #if DEBUG_PRINT
                std::cout << "MACRO CONSTANT GOTTEN: " << entry.name << std::endl;
                #endif

                data.macro_constants.push_back({ entry.name, entry.constant_string });
            EndCase

            Case(DataEntry::IS::TYPEDEF)
                // go through typedefs assign with anonoymous structs first, then correct them in the next phase.
                TypeDef type_def;

                type_def.name = entry.name;

                type_def.cursor = entry.cursor;
                type_def.type = clang_getTypedefDeclUnderlyingType(entry.cursor);

                type_def.type_name = (char*)clang_getTypeSpelling(type_def.type).data;
                type_def.struct_decl = data.struct_decls.size() != 0 ?
                                        data.struct_decls[data.struct_decls.size()-1] :
                                        StructDecl {};

                type_def.enum_decl = data.enum_decls.size() != 0 ?
                                        data.enum_decls[data.enum_decls.size()-1] :
                                        EnumDecl {};

                type_def.is = TypeDef::IS::NEITHER;

                data.type_defs.push_back(type_def);
            EndCase
        End
    End

    For var ref type_def in data.type_defs Then
        modify_type_def(data, type_def);
        // std::cout << type_def.name << ": " << (int)type_def.is << std::endl;
    End

    For let entry in queue.data Then
        Switch entry.is Then
            Case(DataEntry::IS::FUNCTION)
                parse_function(&data, entry.name, entry.cursor);
            EndCase
        End
    End

    If original_data.seperate_files Then
        let extension = file_path.find_last_of('.');
        data.package_name         = original_data.package_name;
        data.windows_library_path = original_data.windows_library_path;
        data.linux_library_path   = original_data.linux_library_path;
        data.mac_library_path     = original_data.mac_library_path;

        var new_file_path = file_path.erase(extension);
        new_file_path += ".odin";

        save_to_file(data, new_file_path);

        return true;
    End
    
    If data.struct_decls.size() != 0 Then
        let end = data.struct_decls.end();
        let start = data.struct_decls.begin();
        let oend = original_data.struct_decls.end();
        original_data.struct_decls.insert(oend, start, end);
    End

    If data.enum_decls.size() != 0 Then
        let end = data.enum_decls.end();
        let start = data.enum_decls.begin();
        let oend = original_data.enum_decls.end();
        original_data.enum_decls.insert(oend, start, end);
    End

    If data.function_decls.size() != 0 Then
        let end = data.function_decls.end();
        let start = data.function_decls.begin();
        let oend = original_data.function_decls.end();
        original_data.function_decls.insert(oend, start, end);
    End

    If data.type_defs.size() != 0 Then
        let end = data.type_defs.end();
        let start = data.type_defs.begin();
        let oend = original_data.type_defs.end();
        original_data.type_defs.insert(oend, start, end);
    End

    If data.macro_constants.size() != 0 Then
        let end = data.macro_constants.end();
        let start = data.macro_constants.begin();
        let oend = original_data.macro_constants.end();
        original_data.macro_constants.insert(oend, start, end);
    End

    // for (auto decl : data.struct_decls) {
    //     print_struct(&data, decl);
    // End

    // for (auto type_def : data.type_defs) {
    //     print_type_def(&data, type_def);
    // End

    return true;
End

function save_to_file(SaveData ref data, std::string file_name) -> void 
Begin
    std::ofstream file(file_name);

    file << "package " << data.package_name << "\n";
    file << "import " << __C_TYPE_LITERAL << " \"core:c\"\n\n";

    file << "when ODIN_OS == .Windows {\n";
    file << "\tforeign import __LIB__ \"" << data.windows_library_path << "\"\n";
    file << "End else when ODIN_OS == .Linux {\n";
    file << "\tforeign import __LIB__ \"" << data.linux_library_path << "\"\n";
    file << "} else when ODIN_OS == .Darwin {\n";
    file << "\tforeign import __LIB__ \"" << data.mac_library_path << "\"\n}\n\n"; 

    For let constant in data.macro_constants Then
        file << std::get<0>(constant) << " :: " << std::get<1>(constant) << "\n\n";
    End

    For var type_def in data.type_defs Then
        #if DEBUG_PRINT
        std::cout << "TYPEDEF NAMES: " << type_def.name << std::endl;
        std::cout << "IS: " << (int)type_def.is << std::endl;
        #endif

        If type_def.name != "" && data.type_names.find(type_def.name) == data.type_names.end() Then
            std::vector<std::string> comment_text;
            std::string content;
            std::string array_lengths;
            Switch type_def.is Then
                Case(TypeDef::IS::STRUCT)
                    comment_text = type_def.struct_decl.comment_text;
                    content = convert_struct_decl_to_string(&data, type_def.struct_decl);
                    For let array_size in type_def.array_sizes Then
                        array_lengths += "[" + std::to_string(array_size) + "]";
                    End

                    array_lengths += std::string(type_def.pointer_level, '^');
                EndCase

                Case(TypeDef::IS::ENUM)
                    comment_text = type_def.enum_decl.comment_text;
                    content = convert_enum_decl_to_string(&data, type_def.enum_decl);
                    For let array_size in type_def.array_sizes Then
                        array_lengths += "[" + std::to_string(array_size) + "]";
                    End

                    array_lengths += std::string(type_def.pointer_level, '^');
                EndCase

                Case(TypeDef::IS::NEITHER)
                    comment_text = type_def.comment_text;
                    content = "distinct ";

                    content += convert_type_name_to_string(&data, type_def.type, type_def.type_name);
                EndCase
            End

            For let comment_text in comment_text Then
                If comment_text != "" Then
                    file << std::string(data.recursion_level, '\t') << comment_text << '\n';
                End
            End

            file << type_def.name << " :: " << array_lengths << content << "\n\n";
        End

        data.type_names.emplace(type_def.name, "");
    End

    For var decl in data.enum_decls Then
        strip_prefix(decl.name, data.remove_prefixes);

        If decl.name != "" && data.type_names.find(decl.name) == data.type_names.end() Then
            file << decl.name << " :: ";
            file << convert_enum_decl_to_string(&data, decl);
            file << "\n\n";

            data.type_names.emplace(decl.name, "");
        End
    End

    For var decl in data.struct_decls Then
        strip_prefix(decl.name, data.remove_prefixes);

        If decl.name != "" && data.type_names.find(decl.name) == data.type_names.end() Then
            file << decl.name << " :: ";
            file << convert_struct_decl_to_string(&data, decl);
            file << "\n\n";

            data.type_names.emplace(decl.name, "");
        End
    End

    std::unordered_map<std::string, std::vector<FunctionDecl>> function_decls;

    For var decl in data.function_decls Then
        If decl.name != "main" Then
            let prefix_stripped = strip_prefix(decl.name, data.remove_prefixes);

            If function_decls.find(prefix_stripped) == function_decls.end() Then
                function_decls[prefix_stripped] = std::vector<FunctionDecl>();
            End

            function_decls[prefix_stripped].push_back(decl);

            //   convert_function_decl_to_string(&data, decl) << "\n\n";
        End
    End

    For let a in function_decls Then
        let prefix = std::get<0>(a);
        let decls = std::get<1>(a);

        file << "@(default_calling_convention = \"c\"";
        If prefix != "" Then
            file << ", link_prefix = \"" << prefix << "\")\n";
        Else 
            file << ")\n";
        End
        file << "foreign __LIB__ {\n"; 

        data.recursion_level += 1; 

        For let decl in decls Then
            file << convert_function_decl_to_string(&data, decl) << "\n";
        End

        data.recursion_level -= 1;

        file << "}\n\n";
    End


    file.close();
End

function main(int argc, char** argv) -> int 
Begin
    // if(argc < 2)
    //     return -1;
    //
    // char* file_path = argv[1];

    // std::vector<std::string> arguments;
    // for (int i = 0; i < argc; i++) {
    //     arguments.push_back(argv[i]);
    // }

    // TODO: Add logic to be able to do more customization with how the generation outputs stuff.

    // char* file_path[] = { "../../src/test.c", "../../src/test.h" };
    std::vector<std::string> file_paths;

    Begin
        std::cout << "What files would you like to convert? (surround with quotes): ";
        std::string str;
        std::getline(std::cin, str);

        var first_quote = str.find('"');

        While first_quote != std::string::npos Then
            str.erase(0, first_quote+1);
            let last_quote = str.find('"');

            If last_quote == std::string::npos Then
                std::cerr << "EXPECTED A '\"' TO END PATH!" << std::endl;
                return -1;
            End

            let path = str.substr(0, last_quote);
            file_paths.push_back(path);
            str = str.erase(0, last_quote+1);

            first_quote = str.find('"');
        End
    End

    std::vector<std::string> include_paths;
    Begin
        std::cout << "What include paths are there? (surround with quotes): ";
        std::string str;
        std::getline(std::cin, str);

        var first_quote = str.find('"');

        While first_quote != std::string::npos Then
            str.erase(0, first_quote+1);
            let last_quote = str.find('"');

            If last_quote == std::string::npos Then
                std::cerr << "EXPECTED A '\"' TO END PATH!" << std::endl;
                return -1;
            End

            let path = str.substr(0, last_quote);
            include_paths.push_back("-I" + path);
            str = str.erase(0, last_quote+1);

            first_quote = str.find('"');
        End
    End

    std::vector<std::string> prefixes_to_remove;
    Begin
        std::cout << "What prefixes would you like to remove? (surround with quotes): ";
        std::string str;
        std::getline(std::cin, str);

        var first_quote = str.find('"');

        While first_quote != std::string::npos Then
            str.erase(0, first_quote+1);
            let last_quote = str.find('"');

            If last_quote == std::string::npos Then
                std::cerr << "EXPECTED A '\"' TO END PATH!" << std::endl;
                return -1;
            End

            let prefix = str.substr(0, last_quote);
            prefixes_to_remove.push_back(prefix);
            str = str.erase(0, last_quote+1);

            first_quote = str.find('"');
        End
    End

    bool convert_to_cstring;
    Begin
        std::cout << "Would you like to convert character pointers to cstring's? (Y or N): ";
        std::string str;
        std::getline(std::cin, str);

        convert_to_cstring = str.length() == 1 && std::tolower(str[0]) == 'y';
    End

    bool seperate_files;
    Begin
        std::cout << "Would you like to maintain seperate files? (Y or N): ";
        std::string str;
        std::getline(std::cin, str);

        seperate_files = str.length() == 1 && std::tolower(str[0]) == 'y';
    End
    
    std::string package_name;
    Begin
        std::cout << "What should the package be named? (enter in plain text and make sure it is a valid identifer): ";
        std::getline(std::cin, package_name);
    End

    std::string windows_path;
    Begin
        std::cout << "What will be the windows path to the library? (surround in quotes): ";
        std::string str;
        std::getline(std::cin, str);

        let first_quote = str.find('"');

        If first_quote == std::string::npos Then
            std::cerr << "EXPECTED quotes AROUND THE LIBRARY PATH" << std::endl;
            return -1;
        End

        str = str.erase(0, first_quote+1);

        let last_quote = str.find('"');

        If last_quote == std::string::npos Then
            std::cerr << "EXPECTED AN ENDING QOUTE FOR THE PATH" << std::endl;
            return -1;
        End

        windows_path = str.substr(0, last_quote);
    End

    std::string linux_path;
    Begin
        std::cout << "What will be the linux path to the library? (surround in quotes): ";
        std::string str;
        std::getline(std::cin, str);

        let first_quote = str.find('"');

        If first_quote == std::string::npos Then
            std::cerr << "EXPECTED quotes AROUND THE LIBRARY PATH" << std::endl;
            return -1;
        End

        str = str.erase(0, first_quote+1);

        let last_quote = str.find('"');

        If last_quote == std::string::npos Then
            std::cerr << "EXPECTED AN ENDING QOUTE FOR THE PATH" << std::endl;
            return -1;
        End

        linux_path = str.substr(0, last_quote);
    End

    std::string mac_path;
    Begin
        std::cout << "What will be the mac path to the library? (surround in quotes): ";
        std::string str;
        std::getline(std::cin, str);

        let first_quote = str.find('"');

        If first_quote == std::string::npos Then
            std::cerr << "EXPECTED quotes AROUND THE LIBRARY PATH" << std::endl;
            return -1;
        End

        str = str.erase(0, first_quote+1);

        let last_quote = str.find('"');

        If last_quote == std::string::npos Then
            std::cerr << "EXPECTED AN ENDING QOUTE FOR THE PATH" << std::endl;
            return -1;
        End

        mac_path = str.substr(0, last_quote);
    End

    std::string output_path;
    If !seperate_files Then
        std::cout << "Where would you like to output the file? (surround in quotes): ";
        std::string str;
        std::getline(std::cin, str);

        let first_quote = str.find('"');

        If first_quote == std::string::npos Then
            std::cerr << "EXPECTED quotes AROUND THE LIBRARY PATH" << std::endl;
            return -1;
        End

        str = str.erase(0, first_quote+1);

        let last_quote = str.find('"');

        If last_quote == std::string::npos Then
            std::cerr << "EXPECTED AN ENDING QOUTE FOR THE PATH" << std::endl;
            return -1;
        End

        output_path = str.substr(0, last_quote);
    End

    SaveData data;
    data.remove_prefixes = prefixes_to_remove;
    data.convert_char_pointer_to_cstring = convert_to_cstring;
    data.seperate_files = seperate_files;
    data.package_name = package_name;
    data.windows_library_path = windows_path;
    data.linux_library_path = linux_path;
    data.mac_library_path = mac_path;
    data.include_paths = include_paths;

    For let file_path in file_paths Then
        std::cout << "PARSING FILE \"" << file_path << "\"" << std::endl;
        parse_file(file_path, data);
    End

    If !data.seperate_files Then
        save_to_file(data, output_path);
    End

    return 0;
End