#include <iostream>
#include <string>
#include <vector>
#include <optional>
#include <tuple>
#include <functional>
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

                                    field.is_type_named = type_name.find("unnamed") == std::string::npos;

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
                TypeDef type_def;

                type_def.name = (char*)clang_getCursorSpelling(cursor).data;

                CXType type = clang_getCursorType(cursor);

                type_def.type_name = (char*)clang_getTypeSpelling(type).data;

                bool is_struct = type_def.type_name.find("struct") != std::string::npos;
                bool is_enum = type_def.type_name.find("enum") != std::string::npos;

                type_def.is = TypeDef::IS::NEITHER;

                if (!(is_struct || is_enum)) {
                    goto TYPEDEF_END;
                }

                bool is_unnamed = type_def.type_name.find("unnamed") != std::string::npos;
                type_def.pointer_level = std::count(type_def.type_name.begin(), type_def.type_name.end(), '*');

                if (is_enum) {
                    type_def.is = TypeDef::IS::ENUM;

                    // TODO: I have no implementation stufffor enums yet

                } else {
                    // we are just going to assume it's an struct at this point
                    type_def.is = TypeDef::IS::STRUCT;

                    if (is_unnamed) {
                        type_def.anonymous = true;
                        type_def.struct_decl = client_data->struct_decls[client_data->struct_decls.size()-1];
                        goto TYPEDEF_END;
                    }

                    if (type_def.pointer_level == 0) {
                        auto type_to_check = type_def.type_name.substr(6, type_def.type_name.size()-6-type_def.pointer_level);

                        for (auto decl : client_data->struct_decls) {
                            
                        }
                    }
                }

                TYPEDEF_END:
                    client_data->push_typedef(type_def);
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

struct DataQueue {
    
};

struct DataQueuer {

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
    if( !tu )
        return -1;
  
    CXCursor rootCursor  = clang_getTranslationUnitCursor(tu);

    std::cout << "DATA:" << std::endl;

    std::cout << rootCursor.kind << std::endl;
    std::cout << rootCursor.xdata << std::endl;
    std::cout << rootCursor.data << std::endl;

    ClientData client_data;

    clang_visitChildren(
        rootCursor, 
        (CXCursorVisitor)visitor,
        &client_data
    );

    for (auto decl : client_data.struct_decls) {
        print_struct(&client_data, decl);
    }

    clang_disposeTranslationUnit(tu);
    clang_disposeIndex(index);
    return 0;
}