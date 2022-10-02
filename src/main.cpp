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

#define DEBUG_PRINT

void save_to_file(SaveData& data, std::string file_name, std::string package_name);

bool parse_file(std::string file_path, SaveData& original_data) {
    CXIndex index        = clang_createIndex(0, 1);
    char* arguments[] = { "-fparse-all-comments" };
    CXTranslationUnit tu = clang_parseTranslationUnit(index, file_path.c_str(), arguments, 1, nullptr, 0, CXTranslationUnit_Flags::CXTranslationUnit_KeepGoing);

    original_data.idxs.push_back(index);
    original_data.tus.push_back(tu);
    
    std::cout << "EVALUATING TRANSLATION UNIT" << std::endl;
    std::cout << "RESULT: " << tu << std::endl;
    if(!tu)
        return false;
  
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
    data.remove_prefixes = original_data.remove_prefixes;
    data.remove_constant_prefixes = original_data.remove_constant_prefixes;
    data.convert_char_pointer_to_cstring = original_data.convert_char_pointer_to_cstring;

    for (auto entry : queue.data) {
        switch (entry.is) {
            case DataEntry::IS::ENUM:
                // TODO: Once enums are implemented.
                recurse_enum(&data, entry.name, entry.cursor, true);

                break;

            case DataEntry::IS::UNION:
                recurse_struct(&data, entry.name, entry.cursor, true, true);
                break;

            case DataEntry::IS::STRUCT:
                recurse_struct(&data, entry.name, entry.cursor, false, true);
                break;

            case DataEntry::IS::TYPEDEF:
                // go through typedefs assign with anonoymous structs first, then correct them in the next phase.
                {
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
                }

                break;
        }
    }

    for (auto& type_def : data.type_defs) {
        modify_type_def(data, type_def);
        // std::cout << type_def.name << ": " << (int)type_def.is << std::endl;
    }

    for (auto entry : queue.data) {
        switch (entry.is) {
            case DataEntry::IS::FUNCTION:
                parse_function(&data, entry.name, entry.cursor);
                break;
        }
    }

    if (original_data.seperate_files) {
        auto extension = file_path.find_last_of('.');

        auto new_file_path = file_path.erase(extension);
        new_file_path += ".odin";

        save_to_file(data, new_file_path, original_data.package_name);
    }
    
    if (data.struct_decls.size() != 0) {
        auto end = data.struct_decls.end();
        auto start = data.struct_decls.begin();
        auto oend = original_data.struct_decls.end();
        original_data.struct_decls.insert(oend, start, end);
    }

    if (data.enum_decls.size() != 0) {
        auto end = data.enum_decls.end();
        auto start = data.enum_decls.begin();
        auto oend = original_data.enum_decls.end();
        original_data.enum_decls.insert(oend, start, end);
    }

    if (data.function_decls.size() != 0) {
        auto end = data.function_decls.end();
        auto start = data.function_decls.begin();
        auto oend = original_data.function_decls.end();
        original_data.function_decls.insert(oend, start, end);
    }

    if (data.type_defs.size() != 0) {
        auto end = data.type_defs.end();
        auto start = data.type_defs.begin();
        auto oend = original_data.type_defs.end();
        original_data.type_defs.insert(oend, start, end);
    }

    // for (auto decl : data.struct_decls) {
    //     print_struct(&data, decl);
    // }

    // for (auto type_def : data.type_defs) {
    //     print_type_def(&data, type_def);
    // }

    return true;
}

// TODO: worry about library paths later
void save_to_file(SaveData& data, std::string file_name, std::string package_name) {
    std::ofstream file(file_name);

    file << "package " << package_name << "\n";
    file << "import " << __C_TYPE_LITERAL << " \"core:c\"\n\n";

    for (auto type_def : data.type_defs) {
        std::cout << "TYPEDEF NAMES: " << type_def.name << std::endl;
        std::cout << "IS: " << (int)type_def.is << std::endl;

        if (type_def.name != "" && data.type_names.find(type_def.name) == data.type_names.end()) {
            std::vector<std::string> comment_text;
            std::string content;
            switch (type_def.is) {
                case TypeDef::IS::STRUCT:
                    comment_text = type_def.struct_decl.comment_text;
                    content = convert_struct_decl_to_string(&data, type_def.struct_decl);

                    break;

                case TypeDef::IS::ENUM:
                    comment_text = type_def.enum_decl.comment_text;
                    content = convert_enum_decl_to_string(&data, type_def.enum_decl);

                    break;

                case TypeDef::IS::NEITHER:
                    comment_text = type_def.comment_text;
                    content = "distinct ";

                    content += convert_type_name_to_string(&data, type_def.type_name);

                    break;
            }

            for (auto comment_text : comment_text) {
                if (comment_text != "") {
                    file << std::string(data.recursion_level, '\t') << comment_text << '\n';
                }
            }

            std::string array_lengths;

            for (auto array_size : type_def.array_sizes) {
                // array_lengths += "[" + std::to_string(array_size) + "]";
            }

            file << type_def.name << " :: " << content << "\n\n";
        }

        data.type_names.emplace(type_def.name, "");
    }

    for (auto decl : data.enum_decls) {
        strip_prefix(decl.name, data.remove_prefixes);

        if (decl.name != "" && data.type_names.find(decl.name) == data.type_names.end()) {
            file << decl.name << " :: ";
            file << convert_enum_decl_to_string(&data, decl);
            file << "\n\n";

            data.type_names.emplace(decl.name, "");
        }
    }

    for (auto decl : data.struct_decls) {
        strip_prefix(decl.name, data.remove_prefixes);

        if (decl.name != "" && data.type_names.find(decl.name) == data.type_names.end()) {
            file << decl.name << " :: ";
            file << convert_struct_decl_to_string(&data, decl);
            file << "\n\n";

            data.type_names.emplace(decl.name, "");
        }
    }

    std::unordered_map<std::string, std::vector<FunctionDecl>> function_decls;

    for (auto decl : data.function_decls) {
        if (decl.name != "main") {
            auto prefix_stripped = strip_prefix(decl.name, data.remove_prefixes);

            if (function_decls.find(prefix_stripped) == function_decls.end()) {
                function_decls[prefix_stripped] = std::vector<FunctionDecl>();
            }

            function_decls[prefix_stripped].push_back(decl);

            //   convert_function_decl_to_string(&data, decl) << "\n\n";
        }
    }

    for (auto a : function_decls) {
        auto prefix = std::get<0>(a);
        auto decls = std::get<1>(a);

        file << "@(default_calling_convention = \"c\", link_prefix = \"" << prefix << "\")\n";
        file << "foreign __LIB__ {\n"; 

        data.recursion_level += 1; 

        for (auto decl : decls) {
            file << convert_function_decl_to_string(&data, decl) << "\n";
        }

        data.recursion_level -= 1;

        file << "}\n\n";
    }


    file.close();
}

int main(int argc, char** argv) {
    // if(argc < 2)
    //     return -1;
    //
    // char* file_path = argv[1];

    std::vector<std::string> arguments;
    for (int i = 0; i < argc; i++) {
        arguments.push_back(argv[i]);
    }

    // TODO: Add logic to be able to do more customization with how the generation outputs stuff.

    char* file_path[] = { "../../src/test.c", "../../src/test.h" };

    SaveData data;
    data.remove_prefixes = { "test_", "something_" };
    data.convert_char_pointer_to_cstring = false;
    data.seperate_files = false;
    data.package_name = "tester";

    parse_file(file_path[0], data);
    parse_file(file_path[1], data);

    save_to_file(data, "../../test.odin", data.package_name);

    return 0;
}