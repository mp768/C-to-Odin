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

bool parse_file(std::string file_path, SaveData& data) {
    CXIndex index        = clang_createIndex(0, 1);
    CXTranslationUnit tu = clang_parseTranslationUnit(index, file_path.c_str(), nullptr, 0, nullptr, 0, CXTranslationUnit_Flags::CXTranslationUnit_KeepGoing);

    data.idxs.push_back(index);
    data.tus.push_back(tu);
    
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

    for (auto entry : queue.data) {
        switch (entry.is) {
            case DataEntry::IS::ENUM:
                // TODO: Once enums are implemented.
                recurse_enum(&data, entry.name, entry.cursor);

                break;

            case DataEntry::IS::UNION:
                recurse_struct(&data, entry.name, entry.cursor, true);
                break;

            case DataEntry::IS::STRUCT:
                recurse_struct(&data, entry.name, entry.cursor, false);
                break;

            case DataEntry::IS::TYPEDEF:
                // go through typedefs assign with anonoymous structs first, then correct them in the next phase.
                {
                    TypeDef type_def;

                    type_def.name = entry.name;

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
    }

    for (auto entry : queue.data) {
        switch (entry.is) {
            case DataEntry::IS::FUNCTION:
                parse_function(&data, entry.name, entry.cursor);
                break;
        }
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
        if (type_def.name != "" && data.type_names.find(type_def.name) == data.type_names.end()) {
            file << type_def.name << " :: ";
            switch (type_def.is) {
                case TypeDef::IS::STRUCT:
                    file << convert_struct_decl_to_string(&data, type_def.struct_decl) << "\n\n";

                    break;

                case TypeDef::IS::ENUM:
                    file << convert_enum_decl_to_string(&data, type_def.enum_decl) << "\n\n";

                    break;

                case TypeDef::IS::NEITHER:
                    file << "distinct ";

                    file << convert_type_name_to_string(&data, type_def.type_name) << "\n\n";

                    break;
            }
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

    for (auto decl : data.function_decls) {
        if (decl.name != "main")
            file << convert_function_decl_to_string(&data, decl) << "\n\n";
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
    data.remove_prefixes = { "test_" };

    parse_file(file_path[0], data);
    parse_file(file_path[1], data);

    save_to_file(data, "../../test.odin", "tester");

    return 0;
}