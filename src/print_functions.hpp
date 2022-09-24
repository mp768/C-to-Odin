#pragma once
#include "keywords.hpp"
#include "data_types.hpp"

static inline auto print_struct(SaveData* save_data, StructDecl decl) -> void {
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
}

static inline auto print_type_def(SaveData* data, TypeDef type_def) -> void {
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
}
