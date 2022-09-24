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
                recurse_enum(&data, entry.name, entry.cursor);

                break;

            case DataEntry::IS::STRUCT:
                recurse_struct(&data, entry.name, entry.cursor);
                break;

            case DataEntry::IS::TYPEDEF:
                // go through typedefs assign with anonoymous structs first, then correct them in the next phase.
                {
                    TypeDef type_def;

                    type_def.name = entry.name;

                    CXType type = clang_getTypedefDeclUnderlyingType(entry.cursor);

                    type_def.type_name = (char*)clang_getTypeSpelling(type).data;
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

    for (auto decl : data.struct_decls) {
        print_struct(&data, decl);
    }

    for (auto type_def : data.type_defs) {
        print_type_def(&data, type_def);
    }

    std::ofstream file("../../test.odin");

    file << "package test\n";
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

                    file << convert_type_name_to_string(type_def.type_name) << "\n\n";

                    break;
            }
        }

        data.type_names.emplace(type_def.name, "");
    }

    for (auto decl : data.enum_decls) {
        if (decl.name != "" && data.type_names.find(decl.name) == data.type_names.end()) {
            file << decl.name << " :: ";
            file << convert_enum_decl_to_string(&data, decl);
            file << "\n\n";

            data.type_names.emplace(decl.name, "");
        }
    }

    for (auto decl : data.struct_decls) {
        if (decl.name != "" && data.type_names.find(decl.name) == data.type_names.end()) {
            file << decl.name << " :: ";
            file << convert_struct_decl_to_string(&data, decl);
            file << "\n\n";

            data.type_names.emplace(decl.name, "");
        }
    }

    for (auto decl : data.function_decls) {
        std::cout << decl.name << " (";
        for (auto argument : decl.arguments) {
            std::cout << argument.name << ": ";

            if (std::holds_alternative<TypeNamed>(argument.type)) {
                auto type_named = std::get<TypeNamed>(argument.type);
                
                std::cout << (type_named.type_name.find("proc") != std::string::npos ? 
                              type_named.type_name :
                              convert_type_name_to_string(type_named.type_name));
            } else {
                auto type_not_named = std::get<TypeNotNamed>(argument.type);

                std::cout << std::string(type_not_named.pointer_level, '^') << 
                              (type_not_named.type == FieldType::ENUM ?
                              convert_enum_decl_to_string(&data, data.enum_decls[type_not_named.index]) :
                              convert_struct_decl_to_string(&data, data.struct_decls[type_not_named.index]));
            }
        }

        std::cout << ")";

        if (std::holds_alternative<TypeNamed>(decl.return_type)) {
            auto type_named = std::get<TypeNamed>(decl.return_type);

            trim_spaces_string(type_named.type_name);

            if (type_named.type_name != "") {
                std::cout << " -> ";
                std::cout << convert_type_name_to_string(type_named.type_name);
            }
        } else {
            auto type_not_named = std::get<TypeNotNamed>(decl.return_type);

            std::cout << " -> " << std::string(type_not_named.pointer_level, '^');

            if (type_not_named.type == FieldType::ENUM) {
                std::cout << convert_enum_decl_to_string(&data, data.enum_decls[type_not_named.index]);
            } else {
                std::cout << convert_struct_decl_to_string(&data, data.struct_decls[type_not_named.index]);
            }
        }

        std::cout << '\n';
    }

    file.close();

    clang_disposeTranslationUnit(tu);
    clang_disposeIndex(index);
    return 0;
}