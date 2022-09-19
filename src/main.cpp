#include <iostream>
#include <string>
#include <vector>
#include <optional>
#include <tuple>
#include <functional>
#include <fstream>
#include <sstream>
#include <clang-c/Index.h>
#include "keywords.hpp"

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

struct DataEntry {
    enum class IS {
        STRUCT,
        ENUM,
        TYPEDEF,
        FUNCTION,
        NONE,
    } is;

    CXCursor cursor;
    std::string name;
};

struct DataQueue {
    std::vector<DataEntry> data;
};

CXVisitorResult build_queue(CXCursor cursor, CXCursor parent, CXClientData client_data) {
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

struct SaveData {
    std::vector<StructDecl> struct_decls;
    std::vector<TypeDef> type_defs;
    std::unordered_map<std::string, std::string> type_names;
    void* current_data;

    size_t recursion_level;

    SaveData() {
        struct_decls.reserve(8);
        type_defs.reserve(8);
        recursion_level = 0;
        current_data = nullptr;
    }
};

void recurse_struct(SaveData* data, std::string name, CXCursor cursor) {
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
                            field.type_not_named.pointer_level = std::count(type_name.begin(), type_name.end(), '*');

                            if (type_name.find("struct") != std::string::npos) {
                                field.type_not_named.type = FieldType::STRUCT;

                                field.type_not_named.index = data->struct_decls.size()-1;
                            } else {
                                field.type_not_named.type = FieldType::ENUM;

                                // TODO: Once enum's are defined
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
                    // TODO: do the enum stuff once it's implemented 

                    break;
            }

            return CXChildVisit_Continue;
        },       
        data
    );

    data->struct_decls.push_back(decl);
}

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

                break;

            case DataEntry::IS::STRUCT:
                recurse_struct(&data, entry.name, entry.cursor);
                break;

            case DataEntry::IS::TYPEDEF:
                // TODO: go through typedefs assign with anonoymous structs first, then correct them in the next phase.
                // It would be way easier to do.
                {
                    TypeDef type_def;

                    type_def.name = entry.name;

                    CXType type = clang_getTypedefDeclUnderlyingType(entry.cursor);

                    type_def.type_name = (char*)clang_getTypeSpelling(type).data;
                    type_def.struct_decl = data.struct_decls.size() != 0 ?
                                           data.struct_decls[data.struct_decls.size()-1] :
                                           StructDecl {  };

                    type_def.is = TypeDef::IS::NEITHER;

                    data.type_defs.push_back(type_def);
                }

                break;
        }
    }

    for (auto& type_def : data.type_defs) {
        // std::cout << "TYPEDEF TYPE NAME: " << type_def.type_name << std::endl;

        if (unallowed_keywords_in_odin.find(type_def.name) != unallowed_keywords_in_odin.end()) {
            type_def.name += "_t";
        }

        bool is_struct = type_def.type_name.find("struct ") != std::string::npos;
        bool is_enum = type_def.type_name.find("enum ") != std::string::npos;

        if (!(is_struct || is_enum)) {
            continue;
        }

        type_def.anonymous = false;

        bool is_unnamed = type_def.type_name.find("unnamed ") != std::string::npos || 
                          type_def.type_name.find("anonymous ") != std::string::npos;
        type_def.pointer_level = std::count(type_def.type_name.begin(), type_def.type_name.end(), '*');

        if (is_enum) {
            type_def.is = TypeDef::IS::ENUM;

            // TODO: I have no implementation stufffor enums yet

        } else {
            // we are just going to assume it's an struct at this point
            type_def.is = TypeDef::IS::STRUCT;

            if (is_unnamed) {
                type_def.anonymous = true;
                continue;
            }

            if (type_def.pointer_level == 0) {
                auto type_to_check = type_def.type_name.substr(7, type_def.type_name.size()-6-type_def.pointer_level);

                int i = 0;
                bool found = false;

                // std::cout << "SUBSTR RESULT: " << type_to_check << " " << type_to_check.size() << std::endl;

                for (auto decl : data.struct_decls) {
                    if (type_to_check == decl.name) {
                        type_def.struct_decl = data.struct_decls[i];
                        found = true;
                    }

                    i++;
                }

                if (!found) {
                    type_def.anonymous = true;
                }
            }
        }
    }

    for (auto entry : queue.data) {
        switch (entry.is) {
            case DataEntry::IS::FUNCTION:
                break;
        }
    }

    std::function<void(SaveData*, StructDecl)> print_struct;

    print_struct = [&](SaveData* save_data, StructDecl decl) -> void {
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
    };

    std::function<void(SaveData*, TypeDef)> print_type_def;

    print_type_def = [&](SaveData* data, TypeDef type_def) -> void {
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
    }; 

    for (auto decl : data.struct_decls) {
        print_struct(&data, decl);
    }

    for (auto type_def : data.type_defs) {
        print_type_def(&data, type_def);
    }

    std::ofstream file("../../test.odin");

    file << "package test\n";
    file << "import " << __C_TYPE_LITERAL << " \"core:c\"\n\n";

    std::function<std::string(std::string)> convert_type_name_to_string;

    convert_type_name_to_string = [&](std::string type_name) -> std::string {
        std::stringstream ss;

        if (type_name.find("enum ") != std::string::npos)
            type_name = type_name.erase(0, 5);
        else if (type_name.find("struct ") != std::string::npos)
            type_name = type_name.erase(0, 6);
        
        auto const_index = 0;
        const_index = type_name.find("const ");

        auto decrease = false;

        while (const_index != std::string::npos) {
            type_name = type_name.erase(const_index, (decrease ? 5 : 6));
            const_index = type_name.find("const");

            decrease = true;
        }

        // std::cout << "TYPE BEFORE: " << type_name << std::endl;

        {
            auto const_index = type_name.find("*");

            auto pointer_level = 0;

            auto found_pointer = false;

            while (const_index != std::string::npos) {
                type_name = type_name.erase(const_index, 1);
                const_index = type_name.find("*");
                found_pointer = true;

                pointer_level++;
            }

            if (found_pointer) {
                type_name = type_name.erase(type_name.size()-1, 1);
            }

            ss << std::string(pointer_level, '^');

            if (unallowed_keywords_in_odin.find(type_name) != unallowed_keywords_in_odin.end()) {
                type_name += "_t";
            }

            // std::cout << "TYPE: " << type_name << "|" << std::endl;

            if (c_keyword_to_odin.find(type_name) != c_keyword_to_odin.end()) {
                ss << c_keyword_to_odin[type_name];
            } else {
                ss << type_name;
            }
        }

        return ss.str();
    };

    std::function<std::string(SaveData*, StructDecl)> convert_struct_decl_to_string;

    convert_struct_decl_to_string = [&](SaveData* data, StructDecl decl) -> std::string {
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
                            // TODO: Once enum is implemented.

                            break;
                    } 

                    break;
            }

            ss << ",\n";
        }

        ss << std::string(data->recursion_level, '\t') << '}';
        
        return ss.str();
    };

    for (auto type_def : data.type_defs) {
        if (type_def.name != "" && data.type_names.find(type_def.name) == data.type_names.end()) {
            // temporary statement since enums aren't implemented yet
            if (type_def.is == TypeDef::IS::ENUM)
                break;

            file << type_def.name << " :: ";
            switch (type_def.is) {
                case TypeDef::IS::STRUCT:
                    file << convert_struct_decl_to_string(&data, type_def.struct_decl) << "\n\n";

                    break;

                case TypeDef::IS::ENUM:
                    break;

                case TypeDef::IS::NEITHER:
                    file << "distinct ";

                    file << convert_type_name_to_string(type_def.type_name) << "\n\n";

                    break;
            }
        }

        data.type_names.emplace(type_def.name, "");
    }

    for (auto decl : data.struct_decls) {
        if (decl.name != "" && data.type_names.find(decl.name) == data.type_names.end()) {
            file << decl.name << " :: ";
            file << convert_struct_decl_to_string(&data, decl);
            file << "\n\n";

            data.type_names.emplace(decl.name, "");
        }
    }

    file.close();

    clang_disposeTranslationUnit(tu);
    clang_disposeIndex(index);
    return 0;
}