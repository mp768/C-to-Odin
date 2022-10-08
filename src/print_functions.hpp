#pragma once
#include "keywords.hpp"
#include "data_types.hpp"
#include "essential_macros.hpp"

function print_struct(SaveData ptr save_data, StructDecl decl) -> void 
Begin
    std::cout << std::string(save_data->recursion_level, '\t') << "Struct \"" << decl.name << "\":" << std::endl;

    For let field in decl.fields Then
        If field.is_type_named Then
            std::cout << std::string(save_data->recursion_level+1, '\t') << field.type_named.type_name << " " << field.name << std::endl;
        Else
            Switch field.type_not_named.type Then
                Case(FieldType::STRUCT)
                    save_data->recursion_level += 1;

                    print_struct(save_data, save_data->struct_decls[field.type_not_named.index]);

                    save_data->recursion_level -= 1;
                EndCase
                
                Case(FieldType::ENUM)
                    // TODO: once enums are implemented.
                EndCase
            End

            std::cout << std::string(save_data->recursion_level+1, '\t') <<  
                            std::string(field.type_not_named.pointer_level, '*') << " " << field.name << std::endl;
        End
    End
End

function print_type_def(SaveData ptr data, TypeDef type_def) -> void 
Begin
    std::cout << std::string(data->recursion_level, '\t') << "TYPEDEF \"" << type_def.name << "\": ";

    Switch type_def.is Then
        Case(TypeDef::IS::STRUCT)
            // std::cout << "Struct " << std::endl; 

            If type_def.anonymous Then
                std::cout << std::endl;

                data->recursion_level += 1;
                print_struct(data, type_def.struct_decl);
                data->recursion_level -= 1;

                std::cout << std::string(data->recursion_level+1, '\t') << "Pointer level: " << type_def.pointer_level << std::endl;
            Else
                std::cout << type_def.type_name << std::endl;
            End
        EndCase
        
        Case(TypeDef::IS::ENUM)
            // TODO: Once enums are implemented.
            std::cout << std::endl;
        EndCase

        Case(TypeDef::IS::NEITHER)
            std::cout << type_def.type_name << std::endl;
        EndCase
    End
End
