package clang
import _c_ "core:c"
import __LIBC__ "core:c/libc"

when ODIN_OS == .Windows {
	foreign import __LIB__ "libclang.lib"
} else when ODIN_OS == .Linux {
	foreign import __LIB__ "S"
} else when ODIN_OS == .Darwin {
	foreign import __LIB__ "D"
}

/**
 * A character string.
 *
 * The \c CXString type is used to return strings from the interface when
 * the ownership of that string might differ from one call to the next.
 * Use \c clang_getCString() to retrieve the string data and, once finished
 * with the string data, call \c clang_disposeString() to free the string.
 */
CXString :: struct {
	data: rawptr,
	private_flags: _c_.uint,
}

CXStringSet :: struct {
	Strings: ^CXString,
	Count: _c_.uint,
}

CXVirtualFileOverlay :: ^struct {}

CXModuleMapDescriptor :: ^struct {}

/**
 * An "index" that consists of a set of translation units that would
 * typically be linked together into an executable or library.
 */
CXIndex :: distinct rawptr

CXTargetInfo :: ^struct {}

CXTranslationUnit :: ^struct {}

/**
 * Opaque pointer representing client data that will be passed through
 * to various callbacks and visitors.
 */
CXClientData :: distinct rawptr

/**
 * Describes a version number of the form major.minor.subminor.
 */
CXVersion :: struct {
	/**
	   * The major version number, e.g., the '10' in '10.7.3'. A negative
	   * value indicates that there is no version number at all.
	   */
	Major: _c_.int,
	/**
	   * The minor version number, e.g., the '7' in '10.7.3'. This value
	   * will be negative if no minor version number was provided, e.g., for
	   * version '10'.
	   */
	Minor: _c_.int,
	/**
	   * The subminor version number, e.g., the '3' in '10.7.3'. This value
	   * will be negative if no minor or subminor version number was provided,
	   * e.g., in version '10' or '10.7'.
	   */
	Subminor: _c_.int,
}

CXGlobalOptFlags :: enum {
	/**
	   * Used to indicate that no special CXIndex options are needed.
	   */
	CXGlobalOpt_None = 0,
	/**
	   * Used to indicate that threads that libclang creates for indexing
	   * purposes should use background priority.
	   *
	   * Affects #clang_indexSourceFile, #clang_indexTranslationUnit,
	   * #clang_parseTranslationUnit, #clang_saveTranslationUnit.
	   */
	CXGlobalOpt_ThreadBackgroundPriorityForIndexing = 1,
	/**
	   * Used to indicate that threads that libclang creates for editing
	   * purposes should use background priority.
	   *
	   * Affects #clang_reparseTranslationUnit, #clang_codeCompleteAt,
	   * #clang_annotateTokens
	   */
	CXGlobalOpt_ThreadBackgroundPriorityForEditing = 2,
	/**
	   * Used to indicate that all threads that libclang creates should use
	   * background priority.
	   */
	CXGlobalOpt_ThreadBackgroundPriorityForAll = 3,
}

/**
 * A particular source file that is part of a translation unit.
 */
CXFile :: distinct rawptr

/**
 * Uniquely identifies a CXFile, that refers to the same underlying file,
 * across an indexing session.
 */
CXFileUniqueID :: struct {
	data: [3]_c_.ulonglong,
}

/**
 * Identifies a specific source location within a translation
 * unit.
 *
 * Use clang_getExpansionLocation() or clang_getSpellingLocation()
 * to map a source location to a particular file, line, and column.
 */
CXSourceLocation :: struct {
	ptr_data: [2]rawptr,
	int_data: _c_.uint,
}

/**
 * Identifies a half-open character range in the source code.
 *
 * Use clang_getRangeStart() and clang_getRangeEnd() to retrieve the
 * starting and end locations from a source range, respectively.
 */
CXSourceRange :: struct {
	ptr_data: [2]rawptr,
	begin_int_data: _c_.uint,
	end_int_data: _c_.uint,
}

/**
 * Identifies an array of ranges.
 */
CXSourceRangeList :: struct {
	/** The number of ranges in the \c ranges array. */
	count: _c_.uint,
	/**
	   * An array of \c CXSourceRanges.
	   */
	ranges: ^CXSourceRange,
}

/**
 * A single diagnostic, containing the diagnostic's severity,
 * location, text, source ranges, and fix-it hints.
 */
CXDiagnostic :: distinct rawptr

/**
 * A group of CXDiagnostics.
 */
CXDiagnosticSet :: distinct rawptr

CXTUResourceUsageEntry :: struct {
	/* The memory usage category. */
	kind: CXTUResourceUsageKind,
	/* Amount of resources used.
	      The units will depend on the resource kind. */
	amount: _c_.ulong,
}

/**
 * The memory usage of a CXTranslationUnit, broken into categories.
 */
CXTUResourceUsage :: struct {
	/* Private data member, used for queries. */
	data: rawptr,
	/* The number of entries in the 'entries' array. */
	numEntries: _c_.uint,
	/* An array of key-value pairs, representing the breakdown of memory
	            usage. */
	entries: ^CXTUResourceUsageEntry,
}

/**
 * A cursor representing some element in the abstract syntax tree for
 * a translation unit.
 *
 * The cursor abstraction unifies the different kinds of entities in a
 * program--declaration, statements, expressions, references to declarations,
 * etc.--under a single "cursor" abstraction with a common set of operations.
 * Common operation for a cursor include: getting the physical location in
 * a source file where the cursor points, getting the name associated with a
 * cursor, and retrieving cursors for any child nodes of a particular cursor.
 *
 * Cursors can be produced in two specific ways.
 * clang_getTranslationUnitCursor() produces a cursor for a translation unit,
 * from which one can use clang_visitChildren() to explore the rest of the
 * translation unit. clang_getCursor() maps from a physical source location
 * to the entity that resides at that location, allowing one to map from the
 * source code into the AST.
 */
CXCursor :: struct {
	kind: CXCursorKind,
	xdata: _c_.int,
	data: [3]rawptr,
}

/**
 * Describes the availability of a given entity on a particular platform, e.g.,
 * a particular class might only be available on Mac OS 10.7 or newer.
 */
CXPlatformAvailability :: struct {
	/**
	   * A string that describes the platform for which this structure
	   * provides availability information.
	   *
	   * Possible values are "ios" or "macos".
	   */
	Platform: CXString,
	/**
	   * The version number in which this entity was introduced.
	   */
	Introduced: CXVersion,
	/**
	   * The version number in which this entity was deprecated (but is
	   * still available).
	   */
	Deprecated: CXVersion,
	/**
	   * The version number in which this entity was obsoleted, and therefore
	   * is no longer available.
	   */
	Obsoleted: CXVersion,
	/**
	   * Whether the entity is unconditionally unavailable on this platform.
	   */
	Unavailable: _c_.int,
	/**
	   * An optional message to provide to a user of this API, e.g., to
	   * suggest replacement APIs.
	   */
	Message: CXString,
}

CXCursorSet :: ^struct {}

/**
 * The type of an element in the abstract syntax tree.
 *
 */
CXType :: struct {
	kind: CXTypeKind,
	data: [2]rawptr,
}

/**
 * Visitor invoked for each cursor found by a traversal.
 *
 * This visitor function will be invoked for each cursor found by
 * clang_visitCursorChildren(). Its first argument is the cursor being
 * visited, its second argument is the parent visitor for that cursor,
 * and its third argument is the client data provided to
 * clang_visitCursorChildren().
 *
 * The visitor should return one of the \c CXChildVisitResult values
 * to direct clang_visitCursorChildren().
 */
CXCursorVisitor :: distinct proc(CXCursor, CXCursor, CXClientData) -> CXChildVisitResult

/**
 * Opaque pointer representing a policy that controls pretty printing
 * for \c clang_getCursorPrettyPrinted.
 */
CXPrintingPolicy :: distinct rawptr

/**
 * Property attributes for a \c CXCursor_ObjCPropertyDecl.
 */
CXObjCPropertyAttrKind :: enum {
	CXObjCPropertyAttr_noattr = 0,
	CXObjCPropertyAttr_readonly = 1,
	CXObjCPropertyAttr_getter = 2,
	CXObjCPropertyAttr_assign = 4,
	CXObjCPropertyAttr_readwrite = 8,
	CXObjCPropertyAttr_retain = 16,
	CXObjCPropertyAttr_copy = 32,
	CXObjCPropertyAttr_nonatomic = 64,
	CXObjCPropertyAttr_setter = 128,
	CXObjCPropertyAttr_atomic = 256,
	CXObjCPropertyAttr_weak = 512,
	CXObjCPropertyAttr_strong = 1024,
	CXObjCPropertyAttr_unsafe_unretained = 2048,
	CXObjCPropertyAttr_class = 4096,
}

/**
 * 'Qualifiers' written next to the return and parameter types in
 * Objective-C method declarations.
 */
CXObjCDeclQualifierKind :: enum {
	CXObjCDeclQualifier_None = 0,
	CXObjCDeclQualifier_In = 1,
	CXObjCDeclQualifier_Inout = 2,
	CXObjCDeclQualifier_Out = 4,
	CXObjCDeclQualifier_Bycopy = 8,
	CXObjCDeclQualifier_Byref = 16,
	CXObjCDeclQualifier_Oneway = 32,
}

/**
 * \defgroup CINDEX_MODULE Module introspection
 *
 * The functions in this group provide access to information about modules.
 *
 * @{
 */
CXModule :: distinct rawptr

/**
 * Describes a kind of token.
 */
CXTokenKind :: enum {
	/**
	   * A token that contains some kind of punctuation.
	   */
	CXToken_Punctuation = 0,
	/**
	   * A language keyword.
	   */
	CXToken_Keyword = 1,
	/**
	   * An identifier (that is not a keyword).
	   */
	CXToken_Identifier = 2,
	/**
	   * A numeric, string, or character literal.
	   */
	CXToken_Literal = 3,
	/**
	   * A comment.
	   */
	CXToken_Comment = 4,
}

/**
 * Describes a single preprocessing token.
 */
CXToken :: struct {
	int_data: [4]_c_.uint,
	ptr_data: rawptr,
}

/**
 * A semantic string that describes a code-completion result.
 *
 * A semantic string that describes the formatting of a code-completion
 * result as a single "template" of text that should be inserted into the
 * source buffer when a particular code-completion result is selected.
 * Each semantic string is made up of some number of "chunks", each of which
 * contains some text along with a description of what that text means, e.g.,
 * the name of the entity being referenced, whether the text chunk is part of
 * the template, or whether it is a "placeholder" that the user should replace
 * with actual code,of a specific kind. See \c CXCompletionChunkKind for a
 * description of the different kinds of chunks.
 */
CXCompletionString :: distinct rawptr

/**
 * A single result of code completion.
 */
CXCompletionResult :: struct {
	/**
	   * The kind of entity that this completion refers to.
	   *
	   * The cursor kind will be a macro, keyword, or a declaration (one of the
	   * *Decl cursor kinds), describing the entity that the completion is
	   * referring to.
	   *
	   * \todo In the future, we would like to provide a full cursor, to allow
	   * the client to extract additional information from declaration.
	   */
	CursorKind: CXCursorKind,
	/**
	   * The code-completion string that describes how to insert this
	   * code-completion result into the editing buffer.
	   */
	CompletionString: CXCompletionString,
}

/**
 * Contains the results of code-completion.
 *
 * This data structure contains the results of code completion, as
 * produced by \c clang_codeCompleteAt(). Its contents must be freed by
 * \c clang_disposeCodeCompleteResults.
 */
CXCodeCompleteResults :: struct {
	/**
	   * The code-completion results.
	   */
	Results: ^CXCompletionResult,
	/**
	   * The number of code-completion results stored in the
	   * \c Results array.
	   */
	NumResults: _c_.uint,
}

/**
 * Visitor invoked for each file in a translation unit
 *        (used with clang_getInclusions()).
 *
 * This visitor function will be invoked by clang_getInclusions() for each
 * file included (either at the top-level or by \#include directives) within
 * a translation unit.  The first argument is the file being included, and
 * the second and third arguments provide the inclusion stack.  The
 * array is sorted in order of immediate inclusion.  For example,
 * the first element refers to the location that included 'included_file'.
 */
CXInclusionVisitor :: distinct proc(CXFile, ^CXSourceLocation, _c_.uint, CXClientData) 

CXEvalResultKind :: enum {
	CXEval_Int = 1,
	CXEval_Float = 2,
	CXEval_ObjCStrLiteral = 3,
	CXEval_StrLiteral = 4,
	CXEval_CFStr = 5,
	CXEval_Other = 6,
	CXEval_UnExposed = 0,
}

/**
 * Evaluation result of a cursor
 */
CXEvalResult :: distinct rawptr

/**
 * A remapping of original source files and their translated files.
 */
CXRemapping :: distinct rawptr

CXCursorAndRangeVisitor :: struct {
	context_v: rawptr,
	visit: proc(rawptr, CXCursor, CXSourceRange) -> CXVisitorResult,
}

CXResult :: enum {
	/**
	   * Function returned successfully.
	   */
	CXResult_Success = 0,
	/**
	   * One of the parameters was invalid for the function.
	   */
	CXResult_Invalid = 1,
	/**
	   * The function was terminated by a callback (e.g. it returned
	   * CXVisit_Break)
	   */
	CXResult_VisitBreak = 2,
}

/**
 * The client's data object that is associated with a CXFile.
 */
CXIdxClientFile :: distinct rawptr

/**
 * The client's data object that is associated with a semantic entity.
 */
CXIdxClientEntity :: distinct rawptr

/**
 * The client's data object that is associated with a semantic container
 * of entities.
 */
CXIdxClientContainer :: distinct rawptr

/**
 * The client's data object that is associated with an AST file (PCH
 * or module).
 */
CXIdxClientASTFile :: distinct rawptr

/**
 * Source location passed to index callbacks.
 */
CXIdxLoc :: struct {
	ptr_data: [2]rawptr,
	int_data: _c_.uint,
}

/**
 * Data for ppIncludedFile callback.
 */
CXIdxIncludedFileInfo :: struct {
	/**
	   * Location of '#' in the \#include/\#import directive.
	   */
	hashLoc: CXIdxLoc,
	/**
	   * Filename as written in the \#include/\#import directive.
	   */
	filename: cstring,
	/**
	   * The actual file that the \#include/\#import directive resolved to.
	   */
	file: CXFile,
	isImport: _c_.int,
	isAngled: _c_.int,
	/**
	   * Non-zero if the directive was automatically turned into a module
	   * import.
	   */
	isModuleImport: _c_.int,
}

/**
 * Data for IndexerCallbacks#importedASTFile.
 */
CXIdxImportedASTFileInfo :: struct {
	/**
	   * Top level AST file containing the imported PCH, module or submodule.
	   */
	file: CXFile,
	/**
	   * The imported module or NULL if the AST file is a PCH.
	   */
	module: CXModule,
	/**
	   * Location where the file is imported. Applicable only for modules.
	   */
	loc: CXIdxLoc,
	/**
	   * Non-zero if an inclusion directive was automatically turned into
	   * a module import. Applicable only for modules.
	   */
	isImplicit: _c_.int,
}

CXIdxEntityKind :: enum {
	CXIdxEntity_Unexposed = 0,
	CXIdxEntity_Typedef = 1,
	CXIdxEntity_Function = 2,
	CXIdxEntity_Variable = 3,
	CXIdxEntity_Field = 4,
	CXIdxEntity_EnumConstant = 5,
	CXIdxEntity_ObjCClass = 6,
	CXIdxEntity_ObjCProtocol = 7,
	CXIdxEntity_ObjCCategory = 8,
	CXIdxEntity_ObjCInstanceMethod = 9,
	CXIdxEntity_ObjCClassMethod = 10,
	CXIdxEntity_ObjCProperty = 11,
	CXIdxEntity_ObjCIvar = 12,
	CXIdxEntity_Enum = 13,
	CXIdxEntity_Struct = 14,
	CXIdxEntity_Union = 15,
	CXIdxEntity_CXXClass = 16,
	CXIdxEntity_CXXNamespace = 17,
	CXIdxEntity_CXXNamespaceAlias = 18,
	CXIdxEntity_CXXStaticVariable = 19,
	CXIdxEntity_CXXStaticMethod = 20,
	CXIdxEntity_CXXInstanceMethod = 21,
	CXIdxEntity_CXXConstructor = 22,
	CXIdxEntity_CXXDestructor = 23,
	CXIdxEntity_CXXConversionFunction = 24,
	CXIdxEntity_CXXTypeAlias = 25,
	CXIdxEntity_CXXInterface = 26,
}

CXIdxEntityLanguage :: enum {
	CXIdxEntityLang_None = 0,
	CXIdxEntityLang_C = 1,
	CXIdxEntityLang_ObjC = 2,
	CXIdxEntityLang_CXX = 3,
	CXIdxEntityLang_Swift = 4,
}

/**
 * Extra C++ template information for an entity. This can apply to:
 * CXIdxEntity_Function
 * CXIdxEntity_CXXClass
 * CXIdxEntity_CXXStaticMethod
 * CXIdxEntity_CXXInstanceMethod
 * CXIdxEntity_CXXConstructor
 * CXIdxEntity_CXXConversionFunction
 * CXIdxEntity_CXXTypeAlias
 */
CXIdxEntityCXXTemplateKind :: enum {
	CXIdxEntity_NonTemplate = 0,
	CXIdxEntity_Template = 1,
	CXIdxEntity_TemplatePartialSpecialization = 2,
	CXIdxEntity_TemplateSpecialization = 3,
}

CXIdxAttrKind :: enum {
	CXIdxAttr_Unexposed = 0,
	CXIdxAttr_IBAction = 1,
	CXIdxAttr_IBOutlet = 2,
	CXIdxAttr_IBOutletCollection = 3,
}

CXIdxAttrInfo :: struct {
	kind: CXIdxAttrKind,
	cursor: CXCursor,
	loc: CXIdxLoc,
}

CXIdxEntityInfo :: struct {
	kind: CXIdxEntityKind,
	templateKind: CXIdxEntityCXXTemplateKind,
	lang: CXIdxEntityLanguage,
	name: cstring,
	USR: cstring,
	cursor: CXCursor,
	attributes: ^^CXIdxAttrInfo,
	numAttributes: _c_.uint,
}

CXIdxContainerInfo :: struct {
	cursor: CXCursor,
}

CXIdxIBOutletCollectionAttrInfo :: struct {
	attrInfo: ^CXIdxAttrInfo,
	objcClass: ^CXIdxEntityInfo,
	classCursor: CXCursor,
	classLoc: CXIdxLoc,
}

CXIdxDeclInfoFlags :: enum {
	CXIdxDeclFlag_Skipped = 1,
}

CXIdxDeclInfo :: struct {
	entityInfo: ^CXIdxEntityInfo,
	cursor: CXCursor,
	loc: CXIdxLoc,
	semanticContainer: ^CXIdxContainerInfo,
	/**
	   * Generally same as #semanticContainer but can be different in
	   * cases like out-of-line C++ member functions.
	   */
	lexicalContainer: ^CXIdxContainerInfo,
	isRedeclaration: _c_.int,
	isDefinition: _c_.int,
	isContainer: _c_.int,
	declAsContainer: ^CXIdxContainerInfo,
	/**
	   * Whether the declaration exists in code or was created implicitly
	   * by the compiler, e.g. implicit Objective-C methods for properties.
	   */
	isImplicit: _c_.int,
	attributes: ^^CXIdxAttrInfo,
	numAttributes: _c_.uint,
	flags: _c_.uint,
}

CXIdxObjCContainerKind :: enum {
	CXIdxObjCContainer_ForwardRef = 0,
	CXIdxObjCContainer_Interface = 1,
	CXIdxObjCContainer_Implementation = 2,
}

CXIdxObjCContainerDeclInfo :: struct {
	declInfo: ^CXIdxDeclInfo,
	kind: CXIdxObjCContainerKind,
}

CXIdxBaseClassInfo :: struct {
	base: ^CXIdxEntityInfo,
	cursor: CXCursor,
	loc: CXIdxLoc,
}

CXIdxObjCProtocolRefInfo :: struct {
	protocol: ^CXIdxEntityInfo,
	cursor: CXCursor,
	loc: CXIdxLoc,
}

CXIdxObjCProtocolRefListInfo :: struct {
	protocols: ^^CXIdxObjCProtocolRefInfo,
	numProtocols: _c_.uint,
}

CXIdxObjCInterfaceDeclInfo :: struct {
	containerInfo: ^CXIdxObjCContainerDeclInfo,
	superInfo: ^CXIdxBaseClassInfo,
	protocols: ^CXIdxObjCProtocolRefListInfo,
}

CXIdxObjCCategoryDeclInfo :: struct {
	containerInfo: ^CXIdxObjCContainerDeclInfo,
	objcClass: ^CXIdxEntityInfo,
	classCursor: CXCursor,
	classLoc: CXIdxLoc,
	protocols: ^CXIdxObjCProtocolRefListInfo,
}

CXIdxObjCPropertyDeclInfo :: struct {
	declInfo: ^CXIdxDeclInfo,
	getter: ^CXIdxEntityInfo,
	setter: ^CXIdxEntityInfo,
}

CXIdxCXXClassDeclInfo :: struct {
	declInfo: ^CXIdxDeclInfo,
	bases: ^^CXIdxBaseClassInfo,
	numBases: _c_.uint,
}

/**
 * Data for IndexerCallbacks#indexEntityReference.
 *
 * This may be deprecated in a future version as this duplicates
 * the \c CXSymbolRole_Implicit bit in \c CXSymbolRole.
 */
CXIdxEntityRefKind :: enum {
	/**
	   * The entity is referenced directly in user's code.
	   */
	CXIdxEntityRef_Direct = 1,
	/**
	   * An implicit reference, e.g. a reference of an Objective-C method
	   * via the dot syntax.
	   */
	CXIdxEntityRef_Implicit = 2,
}

/**
 * Roles that are attributed to symbol occurrences.
 *
 * Internal: this currently mirrors low 9 bits of clang::index::SymbolRole with
 * higher bits zeroed. These high bits may be exposed in the future.
 */
CXSymbolRole :: enum {
	CXSymbolRole_None = 0,
	CXSymbolRole_Declaration = 1,
	CXSymbolRole_Definition = 2,
	CXSymbolRole_Reference = 4,
	CXSymbolRole_Read = 8,
	CXSymbolRole_Write = 16,
	CXSymbolRole_Call = 32,
	CXSymbolRole_Dynamic = 64,
	CXSymbolRole_AddressOf = 128,
	CXSymbolRole_Implicit = 256,
}

/**
 * Data for IndexerCallbacks#indexEntityReference.
 */
CXIdxEntityRefInfo :: struct {
	kind: CXIdxEntityRefKind,
	/**
	   * Reference cursor.
	   */
	cursor: CXCursor,
	loc: CXIdxLoc,
	/**
	   * The entity that gets referenced.
	   */
	referencedEntity: ^CXIdxEntityInfo,
	/**
	   * Immediate "parent" of the reference. For example:
	   *
	   * \code
	   * Foo *var;
	   * \endcode
	   *
	   * The parent of reference of type 'Foo' is the variable 'var'.
	   * For references inside statement bodies of functions/methods,
	   * the parentEntity will be the function/method.
	   */
	parentEntity: ^CXIdxEntityInfo,
	/**
	   * Lexical container context of the reference.
	   */
	container: ^CXIdxContainerInfo,
	/**
	   * Sets of symbol roles of the reference.
	   */
	role: CXSymbolRole,
}

/**
 * A group of callbacks used by #clang_indexSourceFile and
 * #clang_indexTranslationUnit.
 */
IndexerCallbacks :: struct {
	/**
	   * Called periodically to check whether indexing should be aborted.
	   * Should return 0 to continue, and non-zero to abort.
	   */
	abortQuery: proc(CXClientData, rawptr) -> _c_.int,
	/**
	   * Called at the end of indexing; passes the complete diagnostic set.
	   */
	diagnostic: proc(CXClientData, CXDiagnosticSet, rawptr) ,
	enteredMainFile: proc(CXClientData, CXFile, rawptr) -> CXIdxClientFile,
	/**
	   * Called when a file gets \#included/\#imported.
	   */
	ppIncludedFile: proc(CXClientData, ^CXIdxIncludedFileInfo) -> CXIdxClientFile,
	/**
	   * Called when a AST file (PCH or module) gets imported.
	   *
	   * AST files will not get indexed (there will not be callbacks to index all
	   * the entities in an AST file). The recommended action is that, if the AST
	   * file is not already indexed, to initiate a new indexing job specific to
	   * the AST file.
	   */
	importedASTFile: proc(CXClientData, ^CXIdxImportedASTFileInfo) -> CXIdxClientASTFile,
	/**
	   * Called at the beginning of indexing a translation unit.
	   */
	startedTranslationUnit: proc(CXClientData, rawptr) -> CXIdxClientContainer,
	indexDeclaration: proc(CXClientData, ^CXIdxDeclInfo) ,
	/**
	   * Called to index a reference of an entity.
	   */
	indexEntityReference: proc(CXClientData, ^CXIdxEntityRefInfo) ,
}

/**
 * An indexing action/session, to be applied to one or multiple
 * translation units.
 */
CXIndexAction :: distinct rawptr

CXIndexOptFlags :: enum {
	/**
	   * Used to indicate that no special indexing options are needed.
	   */
	CXIndexOpt_None = 0,
	/**
	   * Used to indicate that IndexerCallbacks#indexEntityReference should
	   * be invoked for only one reference of an entity per source file that does
	   * not also include a declaration/definition of the entity.
	   */
	CXIndexOpt_SuppressRedundantRefs = 1,
	/**
	   * Function-local symbols should be indexed. If this is not set
	   * function-local symbols will be ignored.
	   */
	CXIndexOpt_IndexFunctionLocalSymbols = 2,
	/**
	   * Implicit function/class template instantiations should be indexed.
	   * If this is not set, implicit instantiations will be ignored.
	   */
	CXIndexOpt_IndexImplicitTemplateInstantiations = 4,
	/**
	   * Suppress all compiler warnings when parsing for indexing.
	   */
	CXIndexOpt_SuppressWarnings = 8,
	/**
	   * Skip a function/method body that was already parsed during an
	   * indexing session associated with a \c CXIndexAction object.
	   * Bodies in system headers are always skipped.
	   */
	CXIndexOpt_SkipParsedBodiesInSession = 16,
}

/**
 * Visitor invoked for each field found by a traversal.
 *
 * This visitor function will be invoked for each field found by
 * \c clang_Type_visitFields. Its first argument is the cursor being
 * visited, its second argument is the client data provided to
 * \c clang_Type_visitFields.
 *
 * The visitor should return one of the \c CXVisitorResult values
 * to direct \c clang_Type_visitFields.
 */
CXFieldVisitor :: distinct proc(CXCursor, CXClientData) -> CXVisitorResult

CXErrorCode :: enum {
	/**
	   * No error.
	   */
	CXError_Success = 0,
	/**
	   * A generic error code, no further details are available.
	   *
	   * Errors of this kind can get their own specific error codes in future
	   * libclang versions.
	   */
	CXError_Failure = 1,
	/**
	   * libclang crashed while performing the requested operation.
	   */
	CXError_Crashed = 2,
	/**
	   * The function detected that the arguments violate the function
	   * contract.
	   */
	CXError_InvalidArguments = 3,
	/**
	   * An AST deserialization error has occurred.
	   */
	CXError_ASTReadError = 4,
}

CXAvailabilityKind :: enum {
	/**
	   * The entity is available.
	   */
	CXAvailability_Available = 0,
	/**
	   * The entity is available, but has been deprecated (and its use is
	   * not recommended).
	   */
	CXAvailability_Deprecated = 1,
	/**
	   * The entity is not available; any use of it will be an error.
	   */
	CXAvailability_NotAvailable = 2,
	/**
	   * The entity is available, but not accessible; any use of it will be
	   * an error.
	   */
	CXAvailability_NotAccessible = 3,
}

CXCursor_ExceptionSpecificationKind :: enum {
	/**
	   * The cursor has no exception specification.
	   */
	CXCursor_ExceptionSpecificationKind_None = 0,
	/**
	   * The cursor has exception specification throw()
	   */
	CXCursor_ExceptionSpecificationKind_DynamicNone = 1,
	/**
	   * The cursor has exception specification throw(T1, T2)
	   */
	CXCursor_ExceptionSpecificationKind_Dynamic = 2,
	/**
	   * The cursor has exception specification throw(...).
	   */
	CXCursor_ExceptionSpecificationKind_MSAny = 3,
	/**
	   * The cursor has exception specification basic noexcept.
	   */
	CXCursor_ExceptionSpecificationKind_BasicNoexcept = 4,
	/**
	   * The cursor has exception specification computed noexcept.
	   */
	CXCursor_ExceptionSpecificationKind_ComputedNoexcept = 5,
	/**
	   * The exception specification has not yet been evaluated.
	   */
	CXCursor_ExceptionSpecificationKind_Unevaluated = 6,
	/**
	   * The exception specification has not yet been instantiated.
	   */
	CXCursor_ExceptionSpecificationKind_Uninstantiated = 7,
	/**
	   * The exception specification has not been parsed yet.
	   */
	CXCursor_ExceptionSpecificationKind_Unparsed = 8,
	/**
	   * The cursor has a __declspec(nothrow) exception specification.
	   */
	CXCursor_ExceptionSpecificationKind_NoThrow = 9,
}

CXDiagnosticSeverity :: enum {
	/**
	   * A diagnostic that has been suppressed, e.g., by a command-line
	   * option.
	   */
	CXDiagnostic_Ignored = 0,
	/**
	   * This diagnostic is a note that should be attached to the
	   * previous (non-note) diagnostic.
	   */
	CXDiagnostic_Note = 1,
	/**
	   * This diagnostic indicates suspicious code that may not be
	   * wrong.
	   */
	CXDiagnostic_Warning = 2,
	/**
	   * This diagnostic indicates that the code is ill-formed.
	   */
	CXDiagnostic_Error = 3,
	/**
	   * This diagnostic indicates that the code is ill-formed such
	   * that future parser recovery is unlikely to produce useful
	   * results.
	   */
	CXDiagnostic_Fatal = 4,
}

CXLoadDiag_Error :: enum {
	/**
	   * Indicates that no error occurred.
	   */
	CXLoadDiag_None = 0,
	/**
	   * Indicates that an unknown error occurred while attempting to
	   * deserialize diagnostics.
	   */
	CXLoadDiag_Unknown = 1,
	/**
	   * Indicates that the file containing the serialized diagnostics
	   * could not be opened.
	   */
	CXLoadDiag_CannotLoad = 2,
	/**
	   * Indicates that the serialized diagnostics file is invalid or
	   * corrupt.
	   */
	CXLoadDiag_InvalidFile = 3,
}

CXDiagnosticDisplayOptions :: enum {
	/**
	   * Display the source-location information where the
	   * diagnostic was located.
	   *
	   * When set, diagnostics will be prefixed by the file, line, and
	   * (optionally) column to which the diagnostic refers. For example,
	   *
	   * \code
	   * test.c:28: warning: extra tokens at end of #endif directive
	   * \endcode
	   *
	   * This option corresponds to the clang flag \c -fshow-source-location.
	   */
	CXDiagnostic_DisplaySourceLocation = 1,
	/**
	   * If displaying the source-location information of the
	   * diagnostic, also include the column number.
	   *
	   * This option corresponds to the clang flag \c -fshow-column.
	   */
	CXDiagnostic_DisplayColumn = 2,
	/**
	   * If displaying the source-location information of the
	   * diagnostic, also include information about source ranges in a
	   * machine-parsable format.
	   *
	   * This option corresponds to the clang flag
	   * \c -fdiagnostics-print-source-range-info.
	   */
	CXDiagnostic_DisplaySourceRanges = 4,
	/**
	   * Display the option name associated with this diagnostic, if any.
	   *
	   * The option name displayed (e.g., -Wconversion) will be placed in brackets
	   * after the diagnostic text. This option corresponds to the clang flag
	   * \c -fdiagnostics-show-option.
	   */
	CXDiagnostic_DisplayOption = 8,
	/**
	   * Display the category number associated with this diagnostic, if any.
	   *
	   * The category number is displayed within brackets after the diagnostic text.
	   * This option corresponds to the clang flag
	   * \c -fdiagnostics-show-category=id.
	   */
	CXDiagnostic_DisplayCategoryId = 16,
	/**
	   * Display the category name associated with this diagnostic, if any.
	   *
	   * The category name is displayed within brackets after the diagnostic text.
	   * This option corresponds to the clang flag
	   * \c -fdiagnostics-show-category=name.
	   */
	CXDiagnostic_DisplayCategoryName = 32,
}

CXTranslationUnit_Flags :: enum {
	/**
	   * Used to indicate that no special translation-unit options are
	   * needed.
	   */
	CXTranslationUnit_None = 0,
	/**
	   * Used to indicate that the parser should construct a "detailed"
	   * preprocessing record, including all macro definitions and instantiations.
	   *
	   * Constructing a detailed preprocessing record requires more memory
	   * and time to parse, since the information contained in the record
	   * is usually not retained. However, it can be useful for
	   * applications that require more detailed information about the
	   * behavior of the preprocessor.
	   */
	CXTranslationUnit_DetailedPreprocessingRecord = 1,
	/**
	   * Used to indicate that the translation unit is incomplete.
	   *
	   * When a translation unit is considered "incomplete", semantic
	   * analysis that is typically performed at the end of the
	   * translation unit will be suppressed. For example, this suppresses
	   * the completion of tentative declarations in C and of
	   * instantiation of implicitly-instantiation function templates in
	   * C++. This option is typically used when parsing a header with the
	   * intent of producing a precompiled header.
	   */
	CXTranslationUnit_Incomplete = 2,
	/**
	   * Used to indicate that the translation unit should be built with an
	   * implicit precompiled header for the preamble.
	   *
	   * An implicit precompiled header is used as an optimization when a
	   * particular translation unit is likely to be reparsed many times
	   * when the sources aren't changing that often. In this case, an
	   * implicit precompiled header will be built containing all of the
	   * initial includes at the top of the main file (what we refer to as
	   * the "preamble" of the file). In subsequent parses, if the
	   * preamble or the files in it have not changed, \c
	   * clang_reparseTranslationUnit() will re-use the implicit
	   * precompiled header to improve parsing performance.
	   */
	CXTranslationUnit_PrecompiledPreamble = 4,
	/**
	   * Used to indicate that the translation unit should cache some
	   * code-completion results with each reparse of the source file.
	   *
	   * Caching of code-completion results is a performance optimization that
	   * introduces some overhead to reparsing but improves the performance of
	   * code-completion operations.
	   */
	CXTranslationUnit_CacheCompletionResults = 8,
	/**
	   * Used to indicate that the translation unit will be serialized with
	   * \c clang_saveTranslationUnit.
	   *
	   * This option is typically used when parsing a header with the intent of
	   * producing a precompiled header.
	   */
	CXTranslationUnit_ForSerialization = 16,
	/**
	   * DEPRECATED: Enabled chained precompiled preambles in C++.
	   *
	   * Note: this is a *temporary* option that is available only while
	   * we are testing C++ precompiled preamble support. It is deprecated.
	   */
	CXTranslationUnit_CXXChainedPCH = 32,
	/**
	   * Used to indicate that function/method bodies should be skipped while
	   * parsing.
	   *
	   * This option can be used to search for declarations/definitions while
	   * ignoring the usages.
	   */
	CXTranslationUnit_SkipFunctionBodies = 64,
	/**
	   * Used to indicate that brief documentation comments should be
	   * included into the set of code completions returned from this translation
	   * unit.
	   */
	CXTranslationUnit_IncludeBriefCommentsInCodeCompletion = 128,
	/**
	   * Used to indicate that the precompiled preamble should be created on
	   * the first parse. Otherwise it will be created on the first reparse. This
	   * trades runtime on the first parse (serializing the preamble takes time) for
	   * reduced runtime on the second parse (can now reuse the preamble).
	   */
	CXTranslationUnit_CreatePreambleOnFirstParse = 256,
	/**
	   * Do not stop processing when fatal errors are encountered.
	   *
	   * When fatal errors are encountered while parsing a translation unit,
	   * semantic analysis is typically stopped early when compiling code. A common
	   * source for fatal errors are unresolvable include files. For the
	   * purposes of an IDE, this is undesirable behavior and as much information
	   * as possible should be reported. Use this flag to enable this behavior.
	   */
	CXTranslationUnit_KeepGoing = 512,
	/**
	   * Sets the preprocessor in a mode for parsing a single file only.
	   */
	CXTranslationUnit_SingleFileParse = 1024,
	/**
	   * Used in combination with CXTranslationUnit_SkipFunctionBodies to
	   * constrain the skipping of function bodies to the preamble.
	   *
	   * The function bodies of the main file are not skipped.
	   */
	CXTranslationUnit_LimitSkipFunctionBodiesToPreamble = 2048,
	/**
	   * Used to indicate that attributed types should be included in CXType.
	   */
	CXTranslationUnit_IncludeAttributedTypes = 4096,
	/**
	   * Used to indicate that implicit attributes should be visited.
	   */
	CXTranslationUnit_VisitImplicitAttributes = 8192,
	/**
	   * Used to indicate that non-errors from included files should be ignored.
	   *
	   * If set, clang_getDiagnosticSetFromTU() will not report e.g. warnings from
	   * included files anymore. This speeds up clang_getDiagnosticSetFromTU() for
	   * the case where these warnings are not of interest, as for an IDE for
	   * example, which typically shows only the diagnostics in the main file.
	   */
	CXTranslationUnit_IgnoreNonErrorsFromIncludedFiles = 16384,
	/**
	   * Tells the preprocessor not to skip excluded conditional blocks.
	   */
	CXTranslationUnit_RetainExcludedConditionalBlocks = 32768,
}

CXSaveTranslationUnit_Flags :: enum {
	/**
	   * Used to indicate that no special saving options are needed.
	   */
	CXSaveTranslationUnit_None = 0,
}

CXSaveError :: enum {
	/**
	   * Indicates that no error occurred while saving a translation unit.
	   */
	CXSaveError_None = 0,
	/**
	   * Indicates that an unknown error occurred while attempting to save
	   * the file.
	   *
	   * This error typically indicates that file I/O failed when attempting to
	   * write the file.
	   */
	CXSaveError_Unknown = 1,
	/**
	   * Indicates that errors during translation prevented this attempt
	   * to save the translation unit.
	   *
	   * Errors that prevent the translation unit from being saved can be
	   * extracted using \c clang_getNumDiagnostics() and \c clang_getDiagnostic().
	   */
	CXSaveError_TranslationErrors = 2,
	/**
	   * Indicates that the translation unit to be saved was somehow
	   * invalid (e.g., NULL).
	   */
	CXSaveError_InvalidTU = 3,
}

CXReparse_Flags :: enum {
	/**
	   * Used to indicate that no special reparsing options are needed.
	   */
	CXReparse_None = 0,
}

CXTUResourceUsageKind :: enum {
	CXTUResourceUsage_AST = 1,
	CXTUResourceUsage_Identifiers = 2,
	CXTUResourceUsage_Selectors = 3,
	CXTUResourceUsage_GlobalCompletionResults = 4,
	CXTUResourceUsage_SourceManagerContentCache = 5,
	CXTUResourceUsage_AST_SideTables = 6,
	CXTUResourceUsage_SourceManager_Membuffer_Malloc = 7,
	CXTUResourceUsage_SourceManager_Membuffer_MMap = 8,
	CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc = 9,
	CXTUResourceUsage_ExternalASTSource_Membuffer_MMap = 10,
	CXTUResourceUsage_Preprocessor = 11,
	CXTUResourceUsage_PreprocessingRecord = 12,
	CXTUResourceUsage_SourceManager_DataStructures = 13,
	CXTUResourceUsage_Preprocessor_HeaderSearch = 14,
	CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN = 1,
	CXTUResourceUsage_MEMORY_IN_BYTES_END = 14,
	CXTUResourceUsage_First = 1,
	CXTUResourceUsage_Last = 14,
}

CXCursorKind :: enum {
	/* Declarations */
	  /**
	   * A declaration whose specific kind is not exposed via this
	   * interface.
	   *
	   * Unexposed declarations have the same operations as any other kind
	   * of declaration; one can extract their location information,
	   * spelling, find their definitions, etc. However, the specific kind
	   * of the declaration is not reported.
	   */
	CXCursor_UnexposedDecl = 1,
	/** A C or C++ struct. */
	CXCursor_StructDecl = 2,
	/** A C or C++ union. */
	CXCursor_UnionDecl = 3,
	/** A C++ class. */
	CXCursor_ClassDecl = 4,
	/** An enumeration. */
	CXCursor_EnumDecl = 5,
	/**
	   * A field (in C) or non-static data member (in C++) in a
	   * struct, union, or C++ class.
	   */
	CXCursor_FieldDecl = 6,
	/** An enumerator constant. */
	CXCursor_EnumConstantDecl = 7,
	/** A function. */
	CXCursor_FunctionDecl = 8,
	/** A variable. */
	CXCursor_VarDecl = 9,
	/** A function or method parameter. */
	CXCursor_ParmDecl = 10,
	/** An Objective-C \@interface. */
	CXCursor_ObjCInterfaceDecl = 11,
	/** An Objective-C \@interface for a category. */
	CXCursor_ObjCCategoryDecl = 12,
	/** An Objective-C \@protocol declaration. */
	CXCursor_ObjCProtocolDecl = 13,
	/** An Objective-C \@property declaration. */
	CXCursor_ObjCPropertyDecl = 14,
	/** An Objective-C instance variable. */
	CXCursor_ObjCIvarDecl = 15,
	/** An Objective-C instance method. */
	CXCursor_ObjCInstanceMethodDecl = 16,
	/** An Objective-C class method. */
	CXCursor_ObjCClassMethodDecl = 17,
	/** An Objective-C \@implementation. */
	CXCursor_ObjCImplementationDecl = 18,
	/** An Objective-C \@implementation for a category. */
	CXCursor_ObjCCategoryImplDecl = 19,
	/** A typedef. */
	CXCursor_TypedefDecl = 20,
	/** A C++ class method. */
	CXCursor_CXXMethod = 21,
	/** A C++ namespace. */
	CXCursor_Namespace = 22,
	/** A linkage specification, e.g. 'extern "C"'. */
	CXCursor_LinkageSpec = 23,
	/** A C++ constructor. */
	CXCursor_Constructor = 24,
	/** A C++ destructor. */
	CXCursor_Destructor = 25,
	/** A C++ conversion function. */
	CXCursor_ConversionFunction = 26,
	/** A C++ template type parameter. */
	CXCursor_TemplateTypeParameter = 27,
	/** A C++ non-type template parameter. */
	CXCursor_NonTypeTemplateParameter = 28,
	/** A C++ template template parameter. */
	CXCursor_TemplateTemplateParameter = 29,
	/** A C++ function template. */
	CXCursor_FunctionTemplate = 30,
	/** A C++ class template. */
	CXCursor_ClassTemplate = 31,
	/** A C++ class template partial specialization. */
	CXCursor_ClassTemplatePartialSpecialization = 32,
	/** A C++ namespace alias declaration. */
	CXCursor_NamespaceAlias = 33,
	/** A C++ using directive. */
	CXCursor_UsingDirective = 34,
	/** A C++ using declaration. */
	CXCursor_UsingDeclaration = 35,
	/** A C++ alias declaration */
	CXCursor_TypeAliasDecl = 36,
	/** An Objective-C \@synthesize definition. */
	CXCursor_ObjCSynthesizeDecl = 37,
	/** An Objective-C \@dynamic definition. */
	CXCursor_ObjCDynamicDecl = 38,
	/** An access specifier. */
	CXCursor_CXXAccessSpecifier = 39,
	/** An access specifier. */
	CXCursor_FirstDecl = 1,
	/** An access specifier. */
	CXCursor_LastDecl = 39,
	/* Decl references */
	CXCursor_FirstRef = 40,
	CXCursor_ObjCSuperClassRef = 40,
	CXCursor_ObjCProtocolRef = 41,
	CXCursor_ObjCClassRef = 42,
	/**
	   * A reference to a type declaration.
	   *
	   * A type reference occurs anywhere where a type is named but not
	   * declared. For example, given:
	   *
	   * \code
	   * typedef unsigned size_type;
	   * size_type size;
	   * \endcode
	   *
	   * The typedef is a declaration of size_type (CXCursor_TypedefDecl),
	   * while the type of the variable "size" is referenced. The cursor
	   * referenced by the type of size is the typedef for size_type.
	   */
	CXCursor_TypeRef = 43,
	/**
	   * A reference to a type declaration.
	   *
	   * A type reference occurs anywhere where a type is named but not
	   * declared. For example, given:
	   *
	   * \code
	   * typedef unsigned size_type;
	   * size_type size;
	   * \endcode
	   *
	   * The typedef is a declaration of size_type (CXCursor_TypedefDecl),
	   * while the type of the variable "size" is referenced. The cursor
	   * referenced by the type of size is the typedef for size_type.
	   */
	CXCursor_CXXBaseSpecifier = 44,
	/**
	   * A reference to a class template, function template, template
	   * template parameter, or class template partial specialization.
	   */
	CXCursor_TemplateRef = 45,
	/**
	   * A reference to a namespace or namespace alias.
	   */
	CXCursor_NamespaceRef = 46,
	/**
	   * A reference to a member of a struct, union, or class that occurs in
	   * some non-expression context, e.g., a designated initializer.
	   */
	CXCursor_MemberRef = 47,
	/**
	   * A reference to a labeled statement.
	   *
	   * This cursor kind is used to describe the jump to "start_over" in the
	   * goto statement in the following example:
	   *
	   * \code
	   *   start_over:
	   *     ++counter;
	   *
	   *     goto start_over;
	   * \endcode
	   *
	   * A label reference cursor refers to a label statement.
	   */
	CXCursor_LabelRef = 48,
	/**
	   * A reference to a set of overloaded functions or function templates
	   * that has not yet been resolved to a specific function or function template.
	   *
	   * An overloaded declaration reference cursor occurs in C++ templates where
	   * a dependent name refers to a function. For example:
	   *
	   * \code
	   * template<typename T> void swap(T&, T&);
	   *
	   * struct X { ... };
	   * void swap(X&, X&);
	   *
	   * template<typename T>
	   * void reverse(T* first, T* last) {
	   *   while (first < last - 1) {
	   *     swap(*first, *--last);
	   *     ++first;
	   *   }
	   * }
	   *
	   * struct Y { };
	   * void swap(Y&, Y&);
	   * \endcode
	   *
	   * Here, the identifier "swap" is associated with an overloaded declaration
	   * reference. In the template definition, "swap" refers to either of the two
	   * "swap" functions declared above, so both results will be available. At
	   * instantiation time, "swap" may also refer to other functions found via
	   * argument-dependent lookup (e.g., the "swap" function at the end of the
	   * example).
	   *
	   * The functions \c clang_getNumOverloadedDecls() and
	   * \c clang_getOverloadedDecl() can be used to retrieve the definitions
	   * referenced by this cursor.
	   */
	CXCursor_OverloadedDeclRef = 49,
	/**
	   * A reference to a variable that occurs in some non-expression
	   * context, e.g., a C++ lambda capture list.
	   */
	CXCursor_VariableRef = 50,
	/**
	   * A reference to a variable that occurs in some non-expression
	   * context, e.g., a C++ lambda capture list.
	   */
	CXCursor_LastRef = 50,
	/* Error conditions */
	CXCursor_FirstInvalid = 70,
	/* Error conditions */
	CXCursor_InvalidFile = 70,
	/* Error conditions */
	CXCursor_NoDeclFound = 71,
	/* Error conditions */
	CXCursor_NotImplemented = 72,
	/* Error conditions */
	CXCursor_InvalidCode = 73,
	/* Error conditions */
	CXCursor_LastInvalid = 73,
	/* Expressions */
	CXCursor_FirstExpr = 100,
	/**
	   * An expression whose specific kind is not exposed via this
	   * interface.
	   *
	   * Unexposed expressions have the same operations as any other kind
	   * of expression; one can extract their location information,
	   * spelling, children, etc. However, the specific kind of the
	   * expression is not reported.
	   */
	CXCursor_UnexposedExpr = 100,
	/**
	   * An expression that refers to some value declaration, such
	   * as a function, variable, or enumerator.
	   */
	CXCursor_DeclRefExpr = 101,
	/**
	   * An expression that refers to a member of a struct, union,
	   * class, Objective-C class, etc.
	   */
	CXCursor_MemberRefExpr = 102,
	/** An expression that calls a function. */
	CXCursor_CallExpr = 103,
	/** An expression that sends a message to an Objective-C
	   object or class. */
	CXCursor_ObjCMessageExpr = 104,
	/** An expression that represents a block literal. */
	CXCursor_BlockExpr = 105,
	/** An integer literal.
	   */
	CXCursor_IntegerLiteral = 106,
	/** A floating point number literal.
	   */
	CXCursor_FloatingLiteral = 107,
	/** An imaginary number literal.
	   */
	CXCursor_ImaginaryLiteral = 108,
	/** A string literal.
	   */
	CXCursor_StringLiteral = 109,
	/** A character literal.
	   */
	CXCursor_CharacterLiteral = 110,
	/** A parenthesized expression, e.g. "(1)".
	   *
	   * This AST node is only formed if full location information is requested.
	   */
	CXCursor_ParenExpr = 111,
	/** This represents the unary-expression's (except sizeof and
	   * alignof).
	   */
	CXCursor_UnaryOperator = 112,
	/** [C99 6.5.2.1] Array Subscripting.
	   */
	CXCursor_ArraySubscriptExpr = 113,
	/** A builtin binary operation expression such as "x + y" or
	   * "x <= y".
	   */
	CXCursor_BinaryOperator = 114,
	/** Compound assignment such as "+=".
	   */
	CXCursor_CompoundAssignOperator = 115,
	/** The ?: ternary operator.
	   */
	CXCursor_ConditionalOperator = 116,
	/** An explicit cast in C (C99 6.5.4) or a C-style cast in C++
	   * (C++ [expr.cast]), which uses the syntax (Type)expr.
	   *
	   * For example: (int)f.
	   */
	CXCursor_CStyleCastExpr = 117,
	/** [C99 6.5.2.5]
	   */
	CXCursor_CompoundLiteralExpr = 118,
	/** Describes an C or C++ initializer list.
	   */
	CXCursor_InitListExpr = 119,
	/** The GNU address of label extension, representing &&label.
	   */
	CXCursor_AddrLabelExpr = 120,
	/** This is the GNU Statement Expression extension: ({int X=4; X;})
	   */
	CXCursor_StmtExpr = 121,
	/** Represents a C11 generic selection.
	   */
	CXCursor_GenericSelectionExpr = 122,
	/** Implements the GNU __null extension, which is a name for a null
	   * pointer constant that has integral type (e.g., int or long) and is the same
	   * size and alignment as a pointer.
	   *
	   * The __null extension is typically only used by system headers, which define
	   * NULL as __null in C++ rather than using 0 (which is an integer that may not
	   * match the size of a pointer).
	   */
	CXCursor_GNUNullExpr = 123,
	/** C++'s static_cast<> expression.
	   */
	CXCursor_CXXStaticCastExpr = 124,
	/** C++'s dynamic_cast<> expression.
	   */
	CXCursor_CXXDynamicCastExpr = 125,
	/** C++'s reinterpret_cast<> expression.
	   */
	CXCursor_CXXReinterpretCastExpr = 126,
	/** C++'s const_cast<> expression.
	   */
	CXCursor_CXXConstCastExpr = 127,
	/** Represents an explicit C++ type conversion that uses "functional"
	   * notion (C++ [expr.type.conv]).
	   *
	   * Example:
	   * \code
	   *   x = int(0.5);
	   * \endcode
	   */
	CXCursor_CXXFunctionalCastExpr = 128,
	/** A C++ typeid expression (C++ [expr.typeid]).
	   */
	CXCursor_CXXTypeidExpr = 129,
	/** [C++ 2.13.5] C++ Boolean Literal.
	   */
	CXCursor_CXXBoolLiteralExpr = 130,
	/** [C++0x 2.14.7] C++ Pointer Literal.
	   */
	CXCursor_CXXNullPtrLiteralExpr = 131,
	/** Represents the "this" expression in C++
	   */
	CXCursor_CXXThisExpr = 132,
	/** [C++ 15] C++ Throw Expression.
	   *
	   * This handles 'throw' and 'throw' assignment-expression. When
	   * assignment-expression isn't present, Op will be null.
	   */
	CXCursor_CXXThrowExpr = 133,
	/** A new expression for memory allocation and constructor calls, e.g:
	   * "new CXXNewExpr(foo)".
	   */
	CXCursor_CXXNewExpr = 134,
	/** A delete expression for memory deallocation and destructor calls,
	   * e.g. "delete[] pArray".
	   */
	CXCursor_CXXDeleteExpr = 135,
	/** A unary expression. (noexcept, sizeof, or other traits)
	   */
	CXCursor_UnaryExpr = 136,
	/** An Objective-C string literal i.e. @"foo".
	   */
	CXCursor_ObjCStringLiteral = 137,
	/** An Objective-C \@encode expression.
	   */
	CXCursor_ObjCEncodeExpr = 138,
	/** An Objective-C \@selector expression.
	   */
	CXCursor_ObjCSelectorExpr = 139,
	/** An Objective-C \@protocol expression.
	   */
	CXCursor_ObjCProtocolExpr = 140,
	/** An Objective-C "bridged" cast expression, which casts between
	   * Objective-C pointers and C pointers, transferring ownership in the process.
	   *
	   * \code
	   *   NSString *str = (__bridge_transfer NSString *)CFCreateString();
	   * \endcode
	   */
	CXCursor_ObjCBridgedCastExpr = 141,
	/** Represents a C++0x pack expansion that produces a sequence of
	   * expressions.
	   *
	   * A pack expansion expression contains a pattern (which itself is an
	   * expression) followed by an ellipsis. For example:
	   *
	   * \code
	   * template<typename F, typename ...Types>
	   * void forward(F f, Types &&...args) {
	   *  f(static_cast<Types&&>(args)...);
	   * }
	   * \endcode
	   */
	CXCursor_PackExpansionExpr = 142,
	/** Represents an expression that computes the length of a parameter
	   * pack.
	   *
	   * \code
	   * template<typename ...Types>
	   * struct count {
	   *   static const unsigned value = sizeof...(Types);
	   * };
	   * \endcode
	   */
	CXCursor_SizeOfPackExpr = 143,
	/* Represents a C++ lambda expression that produces a local function
	   * object.
	   *
	   * \code
	   * void abssort(float *x, unsigned N) {
	   *   std::sort(x, x + N,
	   *             [](float a, float b) {
	   *               return std::abs(a) < std::abs(b);
	   *             });
	   * }
	   * \endcode
	   */
	CXCursor_LambdaExpr = 144,
	/** Objective-c Boolean Literal.
	   */
	CXCursor_ObjCBoolLiteralExpr = 145,
	/** Represents the "self" expression in an Objective-C method.
	   */
	CXCursor_ObjCSelfExpr = 146,
	/** OpenMP 5.0 [2.1.5, Array Section].
	   */
	CXCursor_OMPArraySectionExpr = 147,
	/** Represents an @available(...) check.
	   */
	CXCursor_ObjCAvailabilityCheckExpr = 148,
	/**
	   * Fixed point literal
	   */
	CXCursor_FixedPointLiteral = 149,
	/** OpenMP 5.0 [2.1.4, Array Shaping].
	   */
	CXCursor_OMPArrayShapingExpr = 150,
	/**
	   * OpenMP 5.0 [2.1.6 Iterators]
	   */
	CXCursor_OMPIteratorExpr = 151,
	/** OpenCL's addrspace_cast<> expression.
	   */
	CXCursor_CXXAddrspaceCastExpr = 152,
	/** OpenCL's addrspace_cast<> expression.
	   */
	CXCursor_LastExpr = 152,
	/* Statements */
	CXCursor_FirstStmt = 200,
	/**
	   * A statement whose specific kind is not exposed via this
	   * interface.
	   *
	   * Unexposed statements have the same operations as any other kind of
	   * statement; one can extract their location information, spelling,
	   * children, etc. However, the specific kind of the statement is not
	   * reported.
	   */
	CXCursor_UnexposedStmt = 200,
	/** A labelled statement in a function.
	   *
	   * This cursor kind is used to describe the "start_over:" label statement in
	   * the following example:
	   *
	   * \code
	   *   start_over:
	   *     ++counter;
	   * \endcode
	   *
	   */
	CXCursor_LabelStmt = 201,
	/** A group of statements like { stmt stmt }.
	   *
	   * This cursor kind is used to describe compound statements, e.g. function
	   * bodies.
	   */
	CXCursor_CompoundStmt = 202,
	/** A case statement.
	   */
	CXCursor_CaseStmt = 203,
	/** A default statement.
	   */
	CXCursor_DefaultStmt = 204,
	/** An if statement
	   */
	CXCursor_IfStmt = 205,
	/** A switch statement.
	   */
	CXCursor_SwitchStmt = 206,
	/** A while statement.
	   */
	CXCursor_WhileStmt = 207,
	/** A do statement.
	   */
	CXCursor_DoStmt = 208,
	/** A for statement.
	   */
	CXCursor_ForStmt = 209,
	/** A goto statement.
	   */
	CXCursor_GotoStmt = 210,
	/** An indirect goto statement.
	   */
	CXCursor_IndirectGotoStmt = 211,
	/** A continue statement.
	   */
	CXCursor_ContinueStmt = 212,
	/** A break statement.
	   */
	CXCursor_BreakStmt = 213,
	/** A return statement.
	   */
	CXCursor_ReturnStmt = 214,
	/** A GCC inline assembly statement extension.
	   */
	CXCursor_GCCAsmStmt = 215,
	/** A GCC inline assembly statement extension.
	   */
	CXCursor_AsmStmt = 215,
	/** Objective-C's overall \@try-\@catch-\@finally statement.
	   */
	CXCursor_ObjCAtTryStmt = 216,
	/** Objective-C's \@catch statement.
	   */
	CXCursor_ObjCAtCatchStmt = 217,
	/** Objective-C's \@finally statement.
	   */
	CXCursor_ObjCAtFinallyStmt = 218,
	/** Objective-C's \@throw statement.
	   */
	CXCursor_ObjCAtThrowStmt = 219,
	/** Objective-C's \@synchronized statement.
	   */
	CXCursor_ObjCAtSynchronizedStmt = 220,
	/** Objective-C's autorelease pool statement.
	   */
	CXCursor_ObjCAutoreleasePoolStmt = 221,
	/** Objective-C's collection statement.
	   */
	CXCursor_ObjCForCollectionStmt = 222,
	/** C++'s catch statement.
	   */
	CXCursor_CXXCatchStmt = 223,
	/** C++'s try statement.
	   */
	CXCursor_CXXTryStmt = 224,
	/** C++'s for (* : *) statement.
	   */
	CXCursor_CXXForRangeStmt = 225,
	/** Windows Structured Exception Handling's try statement.
	   */
	CXCursor_SEHTryStmt = 226,
	/** Windows Structured Exception Handling's except statement.
	   */
	CXCursor_SEHExceptStmt = 227,
	/** Windows Structured Exception Handling's finally statement.
	   */
	CXCursor_SEHFinallyStmt = 228,
	/** A MS inline assembly statement extension.
	   */
	CXCursor_MSAsmStmt = 229,
	/** The null statement ";": C99 6.8.3p3.
	   *
	   * This cursor kind is used to describe the null statement.
	   */
	CXCursor_NullStmt = 230,
	/** Adaptor class for mixing declarations with statements and
	   * expressions.
	   */
	CXCursor_DeclStmt = 231,
	/** OpenMP parallel directive.
	   */
	CXCursor_OMPParallelDirective = 232,
	/** OpenMP SIMD directive.
	   */
	CXCursor_OMPSimdDirective = 233,
	/** OpenMP for directive.
	   */
	CXCursor_OMPForDirective = 234,
	/** OpenMP sections directive.
	   */
	CXCursor_OMPSectionsDirective = 235,
	/** OpenMP section directive.
	   */
	CXCursor_OMPSectionDirective = 236,
	/** OpenMP single directive.
	   */
	CXCursor_OMPSingleDirective = 237,
	/** OpenMP parallel for directive.
	   */
	CXCursor_OMPParallelForDirective = 238,
	/** OpenMP parallel sections directive.
	   */
	CXCursor_OMPParallelSectionsDirective = 239,
	/** OpenMP task directive.
	   */
	CXCursor_OMPTaskDirective = 240,
	/** OpenMP master directive.
	   */
	CXCursor_OMPMasterDirective = 241,
	/** OpenMP critical directive.
	   */
	CXCursor_OMPCriticalDirective = 242,
	/** OpenMP taskyield directive.
	   */
	CXCursor_OMPTaskyieldDirective = 243,
	/** OpenMP barrier directive.
	   */
	CXCursor_OMPBarrierDirective = 244,
	/** OpenMP taskwait directive.
	   */
	CXCursor_OMPTaskwaitDirective = 245,
	/** OpenMP flush directive.
	   */
	CXCursor_OMPFlushDirective = 246,
	/** Windows Structured Exception Handling's leave statement.
	   */
	CXCursor_SEHLeaveStmt = 247,
	/** OpenMP ordered directive.
	   */
	CXCursor_OMPOrderedDirective = 248,
	/** OpenMP atomic directive.
	   */
	CXCursor_OMPAtomicDirective = 249,
	/** OpenMP for SIMD directive.
	   */
	CXCursor_OMPForSimdDirective = 250,
	/** OpenMP parallel for SIMD directive.
	   */
	CXCursor_OMPParallelForSimdDirective = 251,
	/** OpenMP target directive.
	   */
	CXCursor_OMPTargetDirective = 252,
	/** OpenMP teams directive.
	   */
	CXCursor_OMPTeamsDirective = 253,
	/** OpenMP taskgroup directive.
	   */
	CXCursor_OMPTaskgroupDirective = 254,
	/** OpenMP cancellation point directive.
	   */
	CXCursor_OMPCancellationPointDirective = 255,
	/** OpenMP cancel directive.
	   */
	CXCursor_OMPCancelDirective = 256,
	/** OpenMP target data directive.
	   */
	CXCursor_OMPTargetDataDirective = 257,
	/** OpenMP taskloop directive.
	   */
	CXCursor_OMPTaskLoopDirective = 258,
	/** OpenMP taskloop simd directive.
	   */
	CXCursor_OMPTaskLoopSimdDirective = 259,
	/** OpenMP distribute directive.
	   */
	CXCursor_OMPDistributeDirective = 260,
	/** OpenMP target enter data directive.
	   */
	CXCursor_OMPTargetEnterDataDirective = 261,
	/** OpenMP target exit data directive.
	   */
	CXCursor_OMPTargetExitDataDirective = 262,
	/** OpenMP target parallel directive.
	   */
	CXCursor_OMPTargetParallelDirective = 263,
	/** OpenMP target parallel for directive.
	   */
	CXCursor_OMPTargetParallelForDirective = 264,
	/** OpenMP target update directive.
	   */
	CXCursor_OMPTargetUpdateDirective = 265,
	/** OpenMP distribute parallel for directive.
	   */
	CXCursor_OMPDistributeParallelForDirective = 266,
	/** OpenMP distribute parallel for simd directive.
	   */
	CXCursor_OMPDistributeParallelForSimdDirective = 267,
	/** OpenMP distribute simd directive.
	   */
	CXCursor_OMPDistributeSimdDirective = 268,
	/** OpenMP target parallel for simd directive.
	   */
	CXCursor_OMPTargetParallelForSimdDirective = 269,
	/** OpenMP target simd directive.
	   */
	CXCursor_OMPTargetSimdDirective = 270,
	/** OpenMP teams distribute directive.
	   */
	CXCursor_OMPTeamsDistributeDirective = 271,
	/** OpenMP teams distribute simd directive.
	   */
	CXCursor_OMPTeamsDistributeSimdDirective = 272,
	/** OpenMP teams distribute parallel for simd directive.
	   */
	CXCursor_OMPTeamsDistributeParallelForSimdDirective = 273,
	/** OpenMP teams distribute parallel for directive.
	   */
	CXCursor_OMPTeamsDistributeParallelForDirective = 274,
	/** OpenMP target teams directive.
	   */
	CXCursor_OMPTargetTeamsDirective = 275,
	/** OpenMP target teams distribute directive.
	   */
	CXCursor_OMPTargetTeamsDistributeDirective = 276,
	/** OpenMP target teams distribute parallel for directive.
	   */
	CXCursor_OMPTargetTeamsDistributeParallelForDirective = 277,
	/** OpenMP target teams distribute parallel for simd directive.
	   */
	CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective = 278,
	/** OpenMP target teams distribute simd directive.
	   */
	CXCursor_OMPTargetTeamsDistributeSimdDirective = 279,
	/** C++2a std::bit_cast expression.
	   */
	CXCursor_BuiltinBitCastExpr = 280,
	/** OpenMP master taskloop directive.
	   */
	CXCursor_OMPMasterTaskLoopDirective = 281,
	/** OpenMP parallel master taskloop directive.
	   */
	CXCursor_OMPParallelMasterTaskLoopDirective = 282,
	/** OpenMP master taskloop simd directive.
	   */
	CXCursor_OMPMasterTaskLoopSimdDirective = 283,
	/** OpenMP parallel master taskloop simd directive.
	   */
	CXCursor_OMPParallelMasterTaskLoopSimdDirective = 284,
	/** OpenMP parallel master directive.
	   */
	CXCursor_OMPParallelMasterDirective = 285,
	/** OpenMP depobj directive.
	   */
	CXCursor_OMPDepobjDirective = 286,
	/** OpenMP scan directive.
	   */
	CXCursor_OMPScanDirective = 287,
	/** OpenMP tile directive.
	   */
	CXCursor_OMPTileDirective = 288,
	/** OpenMP canonical loop.
	   */
	CXCursor_OMPCanonicalLoop = 289,
	/** OpenMP interop directive.
	   */
	CXCursor_OMPInteropDirective = 290,
	/** OpenMP dispatch directive.
	   */
	CXCursor_OMPDispatchDirective = 291,
	/** OpenMP masked directive.
	   */
	CXCursor_OMPMaskedDirective = 292,
	/** OpenMP unroll directive.
	   */
	CXCursor_OMPUnrollDirective = 293,
	/** OpenMP metadirective directive.
	   */
	CXCursor_OMPMetaDirective = 294,
	/** OpenMP loop directive.
	   */
	CXCursor_OMPGenericLoopDirective = 295,
	/** OpenMP loop directive.
	   */
	CXCursor_LastStmt = 295,
	/**
	   * Cursor that represents the translation unit itself.
	   *
	   * The translation unit cursor exists primarily to act as the root
	   * cursor for traversing the contents of a translation unit.
	   */
	CXCursor_TranslationUnit = 300,
	/* Attributes */
	CXCursor_FirstAttr = 400,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_UnexposedAttr = 400,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_IBActionAttr = 401,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_IBOutletAttr = 402,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_IBOutletCollectionAttr = 403,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_CXXFinalAttr = 404,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_CXXOverrideAttr = 405,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_AnnotateAttr = 406,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_AsmLabelAttr = 407,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_PackedAttr = 408,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_PureAttr = 409,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ConstAttr = 410,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_NoDuplicateAttr = 411,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_CUDAConstantAttr = 412,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_CUDADeviceAttr = 413,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_CUDAGlobalAttr = 414,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_CUDAHostAttr = 415,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_CUDASharedAttr = 416,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_VisibilityAttr = 417,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_DLLExport = 418,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_DLLImport = 419,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_NSReturnsRetained = 420,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_NSReturnsNotRetained = 421,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_NSReturnsAutoreleased = 422,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_NSConsumesSelf = 423,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_NSConsumed = 424,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCException = 425,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCNSObject = 426,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCIndependentClass = 427,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCPreciseLifetime = 428,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCReturnsInnerPointer = 429,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCRequiresSuper = 430,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCRootClass = 431,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCSubclassingRestricted = 432,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCExplicitProtocolImpl = 433,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCDesignatedInitializer = 434,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCRuntimeVisible = 435,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ObjCBoxable = 436,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_FlagEnum = 437,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_ConvergentAttr = 438,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_WarnUnusedAttr = 439,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_WarnUnusedResultAttr = 440,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_AlignedAttr = 441,
	/**
	   * An attribute whose specific kind is not exposed via this
	   * interface.
	   */
	CXCursor_LastAttr = 441,
	/* Preprocessing */
	CXCursor_PreprocessingDirective = 500,
	/* Preprocessing */
	CXCursor_MacroDefinition = 501,
	/* Preprocessing */
	CXCursor_MacroExpansion = 502,
	/* Preprocessing */
	CXCursor_MacroInstantiation = 502,
	/* Preprocessing */
	CXCursor_InclusionDirective = 503,
	/* Preprocessing */
	CXCursor_FirstPreprocessing = 500,
	/* Preprocessing */
	CXCursor_LastPreprocessing = 503,
	/* Extra Declarations */
	  /**
	   * A module import declaration.
	   */
	CXCursor_ModuleImportDecl = 600,
	/* Extra Declarations */
	  /**
	   * A module import declaration.
	   */
	CXCursor_TypeAliasTemplateDecl = 601,
	/**
	   * A static_assert or _Static_assert node
	   */
	CXCursor_StaticAssert = 602,
	/**
	   * a friend declaration.
	   */
	CXCursor_FriendDecl = 603,
	/**
	   * a friend declaration.
	   */
	CXCursor_FirstExtraDecl = 600,
	/**
	   * a friend declaration.
	   */
	CXCursor_LastExtraDecl = 603,
	/**
	   * A code completion overload candidate.
	   */
	CXCursor_OverloadCandidate = 700,
}

CXLinkageKind :: enum {
	/** This value indicates that no linkage information is available
	   * for a provided CXCursor. */
	CXLinkage_Invalid = 0,
	/**
	   * This is the linkage for variables, parameters, and so on that
	   *  have automatic storage.  This covers normal (non-extern) local variables.
	   */
	CXLinkage_NoLinkage = 1,
	/** This is the linkage for static variables and static functions. */
	CXLinkage_Internal = 2,
	/** This is the linkage for entities with external linkage that live
	   * in C++ anonymous namespaces.*/
	CXLinkage_UniqueExternal = 3,
	/** This is the linkage for entities with true, external linkage. */
	CXLinkage_External = 4,
}

CXVisibilityKind :: enum {
	/** This value indicates that no visibility information is available
	   * for a provided CXCursor. */
	CXVisibility_Invalid = 0,
	/** Symbol not seen by the linker. */
	CXVisibility_Hidden = 1,
	/** Symbol seen by the linker but resolves to a symbol inside this object. */
	CXVisibility_Protected = 2,
	/** Symbol seen by the linker and acts like a normal symbol. */
	CXVisibility_Default = 3,
}

CXLanguageKind :: enum {
	CXLanguage_Invalid = 0,
	CXLanguage_C = 1,
	CXLanguage_ObjC = 2,
	CXLanguage_CPlusPlus = 3,
}

CXTLSKind :: enum {
	CXTLS_None = 0,
	CXTLS_Dynamic = 1,
	CXTLS_Static = 2,
}

CXTypeKind :: enum {
	/**
	   * Represents an invalid type (e.g., where no type is available).
	   */
	CXType_Invalid = 0,
	/**
	   * A type whose specific kind is not exposed via this
	   * interface.
	   */
	CXType_Unexposed = 1,
	/* Builtin types */
	CXType_Void = 2,
	/* Builtin types */
	CXType_Bool = 3,
	/* Builtin types */
	CXType_Char_U = 4,
	/* Builtin types */
	CXType_UChar = 5,
	/* Builtin types */
	CXType_Char16 = 6,
	/* Builtin types */
	CXType_Char32 = 7,
	/* Builtin types */
	CXType_UShort = 8,
	/* Builtin types */
	CXType_UInt = 9,
	/* Builtin types */
	CXType_ULong = 10,
	/* Builtin types */
	CXType_ULongLong = 11,
	/* Builtin types */
	CXType_UInt128 = 12,
	/* Builtin types */
	CXType_Char_S = 13,
	/* Builtin types */
	CXType_SChar = 14,
	/* Builtin types */
	CXType_WChar = 15,
	/* Builtin types */
	CXType_Short = 16,
	/* Builtin types */
	CXType_Int = 17,
	/* Builtin types */
	CXType_Long = 18,
	/* Builtin types */
	CXType_LongLong = 19,
	/* Builtin types */
	CXType_Int128 = 20,
	/* Builtin types */
	CXType_Float = 21,
	/* Builtin types */
	CXType_Double = 22,
	/* Builtin types */
	CXType_LongDouble = 23,
	/* Builtin types */
	CXType_NullPtr = 24,
	/* Builtin types */
	CXType_Overload = 25,
	/* Builtin types */
	CXType_Dependent = 26,
	/* Builtin types */
	CXType_ObjCId = 27,
	/* Builtin types */
	CXType_ObjCClass = 28,
	/* Builtin types */
	CXType_ObjCSel = 29,
	/* Builtin types */
	CXType_Float128 = 30,
	/* Builtin types */
	CXType_Half = 31,
	/* Builtin types */
	CXType_Float16 = 32,
	/* Builtin types */
	CXType_ShortAccum = 33,
	/* Builtin types */
	CXType_Accum = 34,
	/* Builtin types */
	CXType_LongAccum = 35,
	/* Builtin types */
	CXType_UShortAccum = 36,
	/* Builtin types */
	CXType_UAccum = 37,
	/* Builtin types */
	CXType_ULongAccum = 38,
	/* Builtin types */
	CXType_BFloat16 = 39,
	/* Builtin types */
	CXType_Ibm128 = 40,
	/* Builtin types */
	CXType_FirstBuiltin = 2,
	/* Builtin types */
	CXType_LastBuiltin = 40,
	/* Builtin types */
	CXType_Complex = 100,
	/* Builtin types */
	CXType_Pointer = 101,
	/* Builtin types */
	CXType_BlockPointer = 102,
	/* Builtin types */
	CXType_LValueReference = 103,
	/* Builtin types */
	CXType_RValueReference = 104,
	/* Builtin types */
	CXType_Record = 105,
	/* Builtin types */
	CXType_Enum = 106,
	/* Builtin types */
	CXType_Typedef = 107,
	/* Builtin types */
	CXType_ObjCInterface = 108,
	/* Builtin types */
	CXType_ObjCObjectPointer = 109,
	/* Builtin types */
	CXType_FunctionNoProto = 110,
	/* Builtin types */
	CXType_FunctionProto = 111,
	/* Builtin types */
	CXType_ConstantArray = 112,
	/* Builtin types */
	CXType_Vector = 113,
	/* Builtin types */
	CXType_IncompleteArray = 114,
	/* Builtin types */
	CXType_VariableArray = 115,
	/* Builtin types */
	CXType_DependentSizedArray = 116,
	/* Builtin types */
	CXType_MemberPointer = 117,
	/* Builtin types */
	CXType_Auto = 118,
	/**
	   * Represents a type that was referred to using an elaborated type keyword.
	   *
	   * E.g., struct S, or via a qualified name, e.g., N::M::type, or both.
	   */
	CXType_Elaborated = 119,
	/* OpenCL PipeType. */
	CXType_Pipe = 120,
	/* OpenCL builtin types. */
	CXType_OCLImage1dRO = 121,
	/* OpenCL builtin types. */
	CXType_OCLImage1dArrayRO = 122,
	/* OpenCL builtin types. */
	CXType_OCLImage1dBufferRO = 123,
	/* OpenCL builtin types. */
	CXType_OCLImage2dRO = 124,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayRO = 125,
	/* OpenCL builtin types. */
	CXType_OCLImage2dDepthRO = 126,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayDepthRO = 127,
	/* OpenCL builtin types. */
	CXType_OCLImage2dMSAARO = 128,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayMSAARO = 129,
	/* OpenCL builtin types. */
	CXType_OCLImage2dMSAADepthRO = 130,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayMSAADepthRO = 131,
	/* OpenCL builtin types. */
	CXType_OCLImage3dRO = 132,
	/* OpenCL builtin types. */
	CXType_OCLImage1dWO = 133,
	/* OpenCL builtin types. */
	CXType_OCLImage1dArrayWO = 134,
	/* OpenCL builtin types. */
	CXType_OCLImage1dBufferWO = 135,
	/* OpenCL builtin types. */
	CXType_OCLImage2dWO = 136,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayWO = 137,
	/* OpenCL builtin types. */
	CXType_OCLImage2dDepthWO = 138,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayDepthWO = 139,
	/* OpenCL builtin types. */
	CXType_OCLImage2dMSAAWO = 140,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayMSAAWO = 141,
	/* OpenCL builtin types. */
	CXType_OCLImage2dMSAADepthWO = 142,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayMSAADepthWO = 143,
	/* OpenCL builtin types. */
	CXType_OCLImage3dWO = 144,
	/* OpenCL builtin types. */
	CXType_OCLImage1dRW = 145,
	/* OpenCL builtin types. */
	CXType_OCLImage1dArrayRW = 146,
	/* OpenCL builtin types. */
	CXType_OCLImage1dBufferRW = 147,
	/* OpenCL builtin types. */
	CXType_OCLImage2dRW = 148,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayRW = 149,
	/* OpenCL builtin types. */
	CXType_OCLImage2dDepthRW = 150,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayDepthRW = 151,
	/* OpenCL builtin types. */
	CXType_OCLImage2dMSAARW = 152,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayMSAARW = 153,
	/* OpenCL builtin types. */
	CXType_OCLImage2dMSAADepthRW = 154,
	/* OpenCL builtin types. */
	CXType_OCLImage2dArrayMSAADepthRW = 155,
	/* OpenCL builtin types. */
	CXType_OCLImage3dRW = 156,
	/* OpenCL builtin types. */
	CXType_OCLSampler = 157,
	/* OpenCL builtin types. */
	CXType_OCLEvent = 158,
	/* OpenCL builtin types. */
	CXType_OCLQueue = 159,
	/* OpenCL builtin types. */
	CXType_OCLReserveID = 160,
	/* OpenCL builtin types. */
	CXType_ObjCObject = 161,
	/* OpenCL builtin types. */
	CXType_ObjCTypeParam = 162,
	/* OpenCL builtin types. */
	CXType_Attributed = 163,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCMcePayload = 164,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCImePayload = 165,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCRefPayload = 166,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCSicPayload = 167,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCMceResult = 168,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCImeResult = 169,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCRefResult = 170,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCSicResult = 171,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout = 172,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout = 173,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCImeSingleRefStreamin = 174,
	/* OpenCL builtin types. */
	CXType_OCLIntelSubgroupAVCImeDualRefStreamin = 175,
	/* OpenCL builtin types. */
	CXType_ExtVector = 176,
	/* OpenCL builtin types. */
	CXType_Atomic = 177,
}

CXCallingConv :: enum {
	CXCallingConv_Default = 0,
	CXCallingConv_C = 1,
	CXCallingConv_X86StdCall = 2,
	CXCallingConv_X86FastCall = 3,
	CXCallingConv_X86ThisCall = 4,
	CXCallingConv_X86Pascal = 5,
	CXCallingConv_AAPCS = 6,
	CXCallingConv_AAPCS_VFP = 7,
	CXCallingConv_X86RegCall = 8,
	CXCallingConv_IntelOclBicc = 9,
	CXCallingConv_Win64 = 10,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_X86_64Win64 = 10,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_X86_64SysV = 11,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_X86VectorCall = 12,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_Swift = 13,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_PreserveMost = 14,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_PreserveAll = 15,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_AArch64VectorCall = 16,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_SwiftAsync = 17,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_Invalid = 100,
	/* Alias for compatibility with older versions of API. */
	CXCallingConv_Unexposed = 200,
}

CXTemplateArgumentKind :: enum {
	CXTemplateArgumentKind_Null = 0,
	CXTemplateArgumentKind_Type = 1,
	CXTemplateArgumentKind_Declaration = 2,
	CXTemplateArgumentKind_NullPtr = 3,
	CXTemplateArgumentKind_Integral = 4,
	CXTemplateArgumentKind_Template = 5,
	CXTemplateArgumentKind_TemplateExpansion = 6,
	CXTemplateArgumentKind_Expression = 7,
	CXTemplateArgumentKind_Pack = 8,
	/* Indicates an error case, preventing the kind from being deduced. */
	CXTemplateArgumentKind_Invalid = 9,
}

CXTypeNullabilityKind :: enum {
	/**
	   * Values of this type can never be null.
	   */
	CXTypeNullability_NonNull = 0,
	/**
	   * Values of this type can be null.
	   */
	CXTypeNullability_Nullable = 1,
	/**
	   * Whether values of this type can be null is (explicitly)
	   * unspecified. This captures a (fairly rare) case where we
	   * can't conclude anything about the nullability of the type even
	   * though it has been considered.
	   */
	CXTypeNullability_Unspecified = 2,
	/**
	   * Nullability is not applicable to this type.
	   */
	CXTypeNullability_Invalid = 3,
	/**
	   * Generally behaves like Nullable, except when used in a block parameter that
	   * was imported into a swift async method. There, swift will assume that the
	   * parameter can get null even if no error occured. _Nullable parameters are
	   * assumed to only get null on error.
	   */
	CXTypeNullability_NullableResult = 4,
}

CXTypeLayoutError :: enum {
	/**
	   * Type is of kind CXType_Invalid.
	   */
	CXTypeLayoutError_Invalid = -1,
	/**
	   * The type is an incomplete Type.
	   */
	CXTypeLayoutError_Incomplete = -2,
	/**
	   * The type is a dependent Type.
	   */
	CXTypeLayoutError_Dependent = -3,
	/**
	   * The type is not a constant size type.
	   */
	CXTypeLayoutError_NotConstantSize = -4,
	/**
	   * The Field name is not valid for this record.
	   */
	CXTypeLayoutError_InvalidFieldName = -5,
	/**
	   * The type is undeduced.
	   */
	CXTypeLayoutError_Undeduced = -6,
}

CXRefQualifierKind :: enum {
	/** No ref-qualifier was provided. */
	CXRefQualifier_None = 0,
	/** An lvalue ref-qualifier was provided (\c &). */
	CXRefQualifier_LValue = 1,
	/** An rvalue ref-qualifier was provided (\c &&). */
	CXRefQualifier_RValue = 2,
}

CX_CXXAccessSpecifier :: enum {
	CX_CXXInvalidAccessSpecifier = 0,
	CX_CXXPublic = 1,
	CX_CXXProtected = 2,
	CX_CXXPrivate = 3,
}

CX_StorageClass :: enum {
	CX_SC_Invalid = 0,
	CX_SC_None = 1,
	CX_SC_Extern = 2,
	CX_SC_Static = 3,
	CX_SC_PrivateExtern = 4,
	CX_SC_OpenCLWorkGroupLocal = 5,
	CX_SC_Auto = 6,
	CX_SC_Register = 7,
}

CXChildVisitResult :: enum {
	/**
	   * Terminates the cursor traversal.
	   */
	CXChildVisit_Break = 0,
	/**
	   * Continues the cursor traversal with the next sibling of
	   * the cursor just visited, without visiting its children.
	   */
	CXChildVisit_Continue = 1,
	/**
	   * Recursively traverse the children of this cursor, using
	   * the same visitor and client data.
	   */
	CXChildVisit_Recurse = 2,
}

CXPrintingPolicyProperty :: enum {
	CXPrintingPolicy_Indentation = 0,
	CXPrintingPolicy_SuppressSpecifiers = 1,
	CXPrintingPolicy_SuppressTagKeyword = 2,
	CXPrintingPolicy_IncludeTagDefinition = 3,
	CXPrintingPolicy_SuppressScope = 4,
	CXPrintingPolicy_SuppressUnwrittenScope = 5,
	CXPrintingPolicy_SuppressInitializers = 6,
	CXPrintingPolicy_ConstantArraySizeAsWritten = 7,
	CXPrintingPolicy_AnonymousTagLocations = 8,
	CXPrintingPolicy_SuppressStrongLifetime = 9,
	CXPrintingPolicy_SuppressLifetimeQualifiers = 10,
	CXPrintingPolicy_SuppressTemplateArgsInCXXConstructors = 11,
	CXPrintingPolicy_Bool = 12,
	CXPrintingPolicy_Restrict = 13,
	CXPrintingPolicy_Alignof = 14,
	CXPrintingPolicy_UnderscoreAlignof = 15,
	CXPrintingPolicy_UseVoidForZeroParams = 16,
	CXPrintingPolicy_TerseOutput = 17,
	CXPrintingPolicy_PolishForDeclaration = 18,
	CXPrintingPolicy_Half = 19,
	CXPrintingPolicy_MSWChar = 20,
	CXPrintingPolicy_IncludeNewlines = 21,
	CXPrintingPolicy_MSVCFormatting = 22,
	CXPrintingPolicy_ConstantsAsWritten = 23,
	CXPrintingPolicy_SuppressImplicitBase = 24,
	CXPrintingPolicy_FullyQualifiedName = 25,
	CXPrintingPolicy_LastProperty = 25,
}

CXNameRefFlags :: enum {
	/**
	   * Include the nested-name-specifier, e.g. Foo:: in x.Foo::y, in the
	   * range.
	   */
	CXNameRange_WantQualifier = 1,
	/**
	   * Include the explicit template arguments, e.g. \<int> in x.f<int>,
	   * in the range.
	   */
	CXNameRange_WantTemplateArgs = 2,
	/**
	   * If the name is non-contiguous, return the full spanning range.
	   *
	   * Non-contiguous names occur in Objective-C when a selector with two or more
	   * parameters is used, or in C++ when using an operator:
	   * \code
	   * [object doSomething:here withValue:there]; // Objective-C
	   * return some_vector[1]; // C++
	   * \endcode
	   */
	CXNameRange_WantSinglePiece = 4,
}

CXCompletionChunkKind :: enum {
	/**
	   * A code-completion string that describes "optional" text that
	   * could be a part of the template (but is not required).
	   *
	   * The Optional chunk is the only kind of chunk that has a code-completion
	   * string for its representation, which is accessible via
	   * \c clang_getCompletionChunkCompletionString(). The code-completion string
	   * describes an additional part of the template that is completely optional.
	   * For example, optional chunks can be used to describe the placeholders for
	   * arguments that match up with defaulted function parameters, e.g. given:
	   *
	   * \code
	   * void f(int x, float y = 3.14, double z = 2.71828);
	   * \endcode
	   *
	   * The code-completion string for this function would contain:
	   *   - a TypedText chunk for "f".
	   *   - a LeftParen chunk for "(".
	   *   - a Placeholder chunk for "int x"
	   *   - an Optional chunk containing the remaining defaulted arguments, e.g.,
	   *       - a Comma chunk for ","
	   *       - a Placeholder chunk for "float y"
	   *       - an Optional chunk containing the last defaulted argument:
	   *           - a Comma chunk for ","
	   *           - a Placeholder chunk for "double z"
	   *   - a RightParen chunk for ")"
	   *
	   * There are many ways to handle Optional chunks. Two simple approaches are:
	   *   - Completely ignore optional chunks, in which case the template for the
	   *     function "f" would only include the first parameter ("int x").
	   *   - Fully expand all optional chunks, in which case the template for the
	   *     function "f" would have all of the parameters.
	   */
	CXCompletionChunk_Optional = 0,
	/**
	   * Text that a user would be expected to type to get this
	   * code-completion result.
	   *
	   * There will be exactly one "typed text" chunk in a semantic string, which
	   * will typically provide the spelling of a keyword or the name of a
	   * declaration that could be used at the current code point. Clients are
	   * expected to filter the code-completion results based on the text in this
	   * chunk.
	   */
	CXCompletionChunk_TypedText = 1,
	/**
	   * Text that should be inserted as part of a code-completion result.
	   *
	   * A "text" chunk represents text that is part of the template to be
	   * inserted into user code should this particular code-completion result
	   * be selected.
	   */
	CXCompletionChunk_Text = 2,
	/**
	   * Placeholder text that should be replaced by the user.
	   *
	   * A "placeholder" chunk marks a place where the user should insert text
	   * into the code-completion template. For example, placeholders might mark
	   * the function parameters for a function declaration, to indicate that the
	   * user should provide arguments for each of those parameters. The actual
	   * text in a placeholder is a suggestion for the text to display before
	   * the user replaces the placeholder with real code.
	   */
	CXCompletionChunk_Placeholder = 3,
	/**
	   * Informative text that should be displayed but never inserted as
	   * part of the template.
	   *
	   * An "informative" chunk contains annotations that can be displayed to
	   * help the user decide whether a particular code-completion result is the
	   * right option, but which is not part of the actual template to be inserted
	   * by code completion.
	   */
	CXCompletionChunk_Informative = 4,
	/**
	   * Text that describes the current parameter when code-completion is
	   * referring to function call, message send, or template specialization.
	   *
	   * A "current parameter" chunk occurs when code-completion is providing
	   * information about a parameter corresponding to the argument at the
	   * code-completion point. For example, given a function
	   *
	   * \code
	   * int add(int x, int y);
	   * \endcode
	   *
	   * and the source code \c add(, where the code-completion point is after the
	   * "(", the code-completion string will contain a "current parameter" chunk
	   * for "int x", indicating that the current argument will initialize that
	   * parameter. After typing further, to \c add(17, (where the code-completion
	   * point is after the ","), the code-completion string will contain a
	   * "current parameter" chunk to "int y".
	   */
	CXCompletionChunk_CurrentParameter = 5,
	/**
	   * A left parenthesis ('('), used to initiate a function call or
	   * signal the beginning of a function parameter list.
	   */
	CXCompletionChunk_LeftParen = 6,
	/**
	   * A right parenthesis (')'), used to finish a function call or
	   * signal the end of a function parameter list.
	   */
	CXCompletionChunk_RightParen = 7,
	/**
	   * A left bracket ('[').
	   */
	CXCompletionChunk_LeftBracket = 8,
	/**
	   * A right bracket (']').
	   */
	CXCompletionChunk_RightBracket = 9,
	/**
	   * A left brace ('{').
	   */
	CXCompletionChunk_LeftBrace = 10,
	/**
	   * A right brace ('}').
	   */
	CXCompletionChunk_RightBrace = 11,
	/**
	   * A left angle bracket ('<').
	   */
	CXCompletionChunk_LeftAngle = 12,
	/**
	   * A right angle bracket ('>').
	   */
	CXCompletionChunk_RightAngle = 13,
	/**
	   * A comma separator (',').
	   */
	CXCompletionChunk_Comma = 14,
	/**
	   * Text that specifies the result type of a given result.
	   *
	   * This special kind of informative chunk is not meant to be inserted into
	   * the text buffer. Rather, it is meant to illustrate the type that an
	   * expression using the given completion string would have.
	   */
	CXCompletionChunk_ResultType = 15,
	/**
	   * A colon (':').
	   */
	CXCompletionChunk_Colon = 16,
	/**
	   * A semicolon (';').
	   */
	CXCompletionChunk_SemiColon = 17,
	/**
	   * An '=' sign.
	   */
	CXCompletionChunk_Equal = 18,
	/**
	   * Horizontal space (' ').
	   */
	CXCompletionChunk_HorizontalSpace = 19,
	/**
	   * Vertical space ('\\n'), after which it is generally a good idea to
	   * perform indentation.
	   */
	CXCompletionChunk_VerticalSpace = 20,
}

CXCodeComplete_Flags :: enum {
	/**
	   * Whether to include macros within the set of code
	   * completions returned.
	   */
	CXCodeComplete_IncludeMacros = 1,
	/**
	   * Whether to include code patterns for language constructs
	   * within the set of code completions, e.g., for loops.
	   */
	CXCodeComplete_IncludeCodePatterns = 2,
	/**
	   * Whether to include brief documentation within the set of code
	   * completions returned.
	   */
	CXCodeComplete_IncludeBriefComments = 4,
	/**
	   * Whether to speed up completion by omitting top- or namespace-level entities
	   * defined in the preamble. There's no guarantee any particular entity is
	   * omitted. This may be useful if the headers are indexed externally.
	   */
	CXCodeComplete_SkipPreamble = 8,
	/**
	   * Whether to include completions with small
	   * fix-its, e.g. change '.' to '->' on member access, etc.
	   */
	CXCodeComplete_IncludeCompletionsWithFixIts = 16,
}

CXCompletionContext :: enum {
	/**
	   * The context for completions is unexposed, as only Clang results
	   * should be included. (This is equivalent to having no context bits set.)
	   */
	CXCompletionContext_Unexposed = 0,
	/**
	   * Completions for any possible type should be included in the results.
	   */
	CXCompletionContext_AnyType = 1,
	/**
	   * Completions for any possible value (variables, function calls, etc.)
	   * should be included in the results.
	   */
	CXCompletionContext_AnyValue = 2,
	/**
	   * Completions for values that resolve to an Objective-C object should
	   * be included in the results.
	   */
	CXCompletionContext_ObjCObjectValue = 4,
	/**
	   * Completions for values that resolve to an Objective-C selector
	   * should be included in the results.
	   */
	CXCompletionContext_ObjCSelectorValue = 8,
	/**
	   * Completions for values that resolve to a C++ class type should be
	   * included in the results.
	   */
	CXCompletionContext_CXXClassTypeValue = 16,
	/**
	   * Completions for fields of the member being accessed using the dot
	   * operator should be included in the results.
	   */
	CXCompletionContext_DotMemberAccess = 32,
	/**
	   * Completions for fields of the member being accessed using the arrow
	   * operator should be included in the results.
	   */
	CXCompletionContext_ArrowMemberAccess = 64,
	/**
	   * Completions for properties of the Objective-C object being accessed
	   * using the dot operator should be included in the results.
	   */
	CXCompletionContext_ObjCPropertyAccess = 128,
	/**
	   * Completions for enum tags should be included in the results.
	   */
	CXCompletionContext_EnumTag = 256,
	/**
	   * Completions for union tags should be included in the results.
	   */
	CXCompletionContext_UnionTag = 512,
	/**
	   * Completions for struct tags should be included in the results.
	   */
	CXCompletionContext_StructTag = 1024,
	/**
	   * Completions for C++ class names should be included in the results.
	   */
	CXCompletionContext_ClassTag = 2048,
	/**
	   * Completions for C++ namespaces and namespace aliases should be
	   * included in the results.
	   */
	CXCompletionContext_Namespace = 4096,
	/**
	   * Completions for C++ nested name specifiers should be included in
	   * the results.
	   */
	CXCompletionContext_NestedNameSpecifier = 8192,
	/**
	   * Completions for Objective-C interfaces (classes) should be included
	   * in the results.
	   */
	CXCompletionContext_ObjCInterface = 16384,
	/**
	   * Completions for Objective-C protocols should be included in
	   * the results.
	   */
	CXCompletionContext_ObjCProtocol = 32768,
	/**
	   * Completions for Objective-C categories should be included in
	   * the results.
	   */
	CXCompletionContext_ObjCCategory = 65536,
	/**
	   * Completions for Objective-C instance messages should be included
	   * in the results.
	   */
	CXCompletionContext_ObjCInstanceMessage = 131072,
	/**
	   * Completions for Objective-C class messages should be included in
	   * the results.
	   */
	CXCompletionContext_ObjCClassMessage = 262144,
	/**
	   * Completions for Objective-C selector names should be included in
	   * the results.
	   */
	CXCompletionContext_ObjCSelectorName = 524288,
	/**
	   * Completions for preprocessor macro names should be included in
	   * the results.
	   */
	CXCompletionContext_MacroName = 1048576,
	/**
	   * Natural language completions should be included in the results.
	   */
	CXCompletionContext_NaturalLanguage = 2097152,
	/**
	   * #include file completions should be included in the results.
	   */
	CXCompletionContext_IncludedFile = 4194304,
	/**
	   * The current context is unknown, so set all contexts.
	   */
	CXCompletionContext_Unknown = 8388607,
}

CXVisitorResult :: enum {
	CXVisit_Break = 0,
	CXVisit_Continue = 1,
}

CXVirtualFileOverlayImpl :: struct {}

CXModuleMapDescriptorImpl :: struct {}

CXTargetInfoImpl :: struct {}

CXTranslationUnitImpl :: struct {}

CXUnsavedFile :: struct {
	/**
	   * The file whose contents have not yet been saved.
	   *
	   * This file must already exist in the file system.
	   */
	Filename: cstring,
	/**
	   * A buffer containing the unsaved contents of this file.
	   */
	Contents: cstring,
	/**
	   * The length of the unsaved contents of this buffer.
	   */
	Length: _c_.ulong,
}

CXCursorSetImpl :: struct {}

@(default_calling_convention = "c", link_prefix = "clang_")
foreign __LIB__ {
	/**
	 * Retrieve the character data associated with the given string.
	 */
	getCString :: proc(string: CXString) -> cstring --- 
	/**
	 * Free the given string.
	 */
	disposeString :: proc(string: CXString) --- 
	/**
	 * Free the given string set.
	 */
	disposeStringSet :: proc(set: ^CXStringSet) --- 
	/**
	 * Return the timestamp for use with Clang's
	 * \c -fbuild-session-timestamp= option.
	 */
	getBuildSessionTimestamp :: proc() -> _c_.ulonglong --- 
	/**
	 * Create a \c CXVirtualFileOverlay object.
	 * Must be disposed with \c clang_VirtualFileOverlay_dispose().
	 *
	 * \param options is reserved, always pass 0.
	 */
	VirtualFileOverlay_create :: proc(options: _c_.uint) -> CXVirtualFileOverlay --- 
	/**
	 * Map an absolute virtual file path to an absolute real one.
	 * The virtual path must be canonicalized (not contain "."/"..").
	 * \returns 0 for success, non-zero to indicate an error.
	 */
	VirtualFileOverlay_addFileMapping :: proc(_: CXVirtualFileOverlay, virtualPath: cstring, realPath: cstring) -> CXErrorCode --- 
	/**
	 * Set the case sensitivity for the \c CXVirtualFileOverlay object.
	 * The \c CXVirtualFileOverlay object is case-sensitive by default, this
	 * option can be used to override the default.
	 * \returns 0 for success, non-zero to indicate an error.
	 */
	VirtualFileOverlay_setCaseSensitivity :: proc(_: CXVirtualFileOverlay, caseSensitive: _c_.int) -> CXErrorCode --- 
	/**
	 * Write out the \c CXVirtualFileOverlay object to a char buffer.
	 *
	 * \param options is reserved, always pass 0.
	 * \param out_buffer_ptr pointer to receive the buffer pointer, which should be
	 * disposed using \c clang_free().
	 * \param out_buffer_size pointer to receive the buffer size.
	 * \returns 0 for success, non-zero to indicate an error.
	 */
	VirtualFileOverlay_writeToBuffer :: proc(_: CXVirtualFileOverlay, options: _c_.uint, out_buffer_ptr: ^cstring, out_buffer_size: ^_c_.uint) -> CXErrorCode --- 
	/**
	 * free memory allocated by libclang, such as the buffer returned by
	 * \c CXVirtualFileOverlay() or \c clang_ModuleMapDescriptor_writeToBuffer().
	 *
	 * \param buffer memory pointer to free.
	 */
	free :: proc(buffer: rawptr) --- 
	/**
	 * Dispose a \c CXVirtualFileOverlay object.
	 */
	VirtualFileOverlay_dispose :: proc(_: CXVirtualFileOverlay) --- 
	/**
	 * Create a \c CXModuleMapDescriptor object.
	 * Must be disposed with \c clang_ModuleMapDescriptor_dispose().
	 *
	 * \param options is reserved, always pass 0.
	 */
	ModuleMapDescriptor_create :: proc(options: _c_.uint) -> CXModuleMapDescriptor --- 
	/**
	 * Sets the framework module name that the module.map describes.
	 * \returns 0 for success, non-zero to indicate an error.
	 */
	ModuleMapDescriptor_setFrameworkModuleName :: proc(_: CXModuleMapDescriptor, name: cstring) -> CXErrorCode --- 
	/**
	 * Sets the umbrella header name that the module.map describes.
	 * \returns 0 for success, non-zero to indicate an error.
	 */
	ModuleMapDescriptor_setUmbrellaHeader :: proc(_: CXModuleMapDescriptor, name: cstring) -> CXErrorCode --- 
	/**
	 * Write out the \c CXModuleMapDescriptor object to a char buffer.
	 *
	 * \param options is reserved, always pass 0.
	 * \param out_buffer_ptr pointer to receive the buffer pointer, which should be
	 * disposed using \c clang_free().
	 * \param out_buffer_size pointer to receive the buffer size.
	 * \returns 0 for success, non-zero to indicate an error.
	 */
	ModuleMapDescriptor_writeToBuffer :: proc(_: CXModuleMapDescriptor, options: _c_.uint, out_buffer_ptr: ^cstring, out_buffer_size: ^_c_.uint) -> CXErrorCode --- 
	/**
	 * Dispose a \c CXModuleMapDescriptor object.
	 */
	ModuleMapDescriptor_dispose :: proc(_: CXModuleMapDescriptor) --- 
	/**
	 * Provides a shared context for creating translation units.
	 *
	 * It provides two options:
	 *
	 * - excludeDeclarationsFromPCH: When non-zero, allows enumeration of "local"
	 * declarations (when loading any new translation units). A "local" declaration
	 * is one that belongs in the translation unit itself and not in a precompiled
	 * header that was used by the translation unit. If zero, all declarations
	 * will be enumerated.
	 *
	 * Here is an example:
	 *
	 * \code
	 *   // excludeDeclsFromPCH = 1, displayDiagnostics=1
	 *   Idx = clang_createIndex(1, 1);
	 *
	 *   // IndexTest.pch was produced with the following command:
	 *   // "clang -x c IndexTest.h -emit-ast -o IndexTest.pch"
	 *   TU = clang_createTranslationUnit(Idx, "IndexTest.pch");
	 *
	 *   // This will load all the symbols from 'IndexTest.pch'
	 *   clang_visitChildren(clang_getTranslationUnitCursor(TU),
	 *                       TranslationUnitVisitor, 0);
	 *   clang_disposeTranslationUnit(TU);
	 *
	 *   // This will load all the symbols from 'IndexTest.c', excluding symbols
	 *   // from 'IndexTest.pch'.
	 *   char *args[] = { "-Xclang", "-include-pch=IndexTest.pch" };
	 *   TU = clang_createTranslationUnitFromSourceFile(Idx, "IndexTest.c", 2, args,
	 *                                                  0, 0);
	 *   clang_visitChildren(clang_getTranslationUnitCursor(TU),
	 *                       TranslationUnitVisitor, 0);
	 *   clang_disposeTranslationUnit(TU);
	 * \endcode
	 *
	 * This process of creating the 'pch', loading it separately, and using it (via
	 * -include-pch) allows 'excludeDeclsFromPCH' to remove redundant callbacks
	 * (which gives the indexer the same performance benefit as the compiler).
	 */
	createIndex :: proc(excludeDeclarationsFromPCH: _c_.int, displayDiagnostics: _c_.int) -> CXIndex --- 
	/**
	 * Destroy the given index.
	 *
	 * The index must not be destroyed until all of the translation units created
	 * within that index have been destroyed.
	 */
	disposeIndex :: proc(index: CXIndex) --- 
	/**
	 * Sets general options associated with a CXIndex.
	 *
	 * For example:
	 * \code
	 * CXIndex idx = ...;
	 * clang_CXIndex_setGlobalOptions(idx,
	 *     clang_CXIndex_getGlobalOptions(idx) |
	 *     CXGlobalOpt_ThreadBackgroundPriorityForIndexing);
	 * \endcode
	 *
	 * \param options A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags.
	 */
	CXIndex_setGlobalOptions :: proc(_: CXIndex, options: _c_.uint) --- 
	/**
	 * Gets the general options associated with a CXIndex.
	 *
	 * \returns A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags that
	 * are associated with the given CXIndex object.
	 */
	CXIndex_getGlobalOptions :: proc(_: CXIndex) -> _c_.uint --- 
	/**
	 * Sets the invocation emission path option in a CXIndex.
	 *
	 * The invocation emission path specifies a path which will contain log
	 * files for certain libclang invocations. A null value (default) implies that
	 * libclang invocations are not logged..
	 */
	CXIndex_setInvocationEmissionPathOption :: proc(_: CXIndex, Path: cstring) --- 
	/**
	 * Retrieve the complete file and path name of the given file.
	 */
	getFileName :: proc(SFile: CXFile) -> CXString --- 
	/**
	 * Retrieve the last modification time of the given file.
	 */
	getFileTime :: proc(SFile: CXFile) -> __LIBC__.time_t --- 
	/**
	 * Retrieve the unique ID for the given \c file.
	 *
	 * \param file the file to get the ID for.
	 * \param outID stores the returned CXFileUniqueID.
	 * \returns If there was a failure getting the unique ID, returns non-zero,
	 * otherwise returns 0.
	 */
	getFileUniqueID :: proc(file: CXFile, outID: ^CXFileUniqueID) -> _c_.int --- 
	/**
	 * Determine whether the given header is guarded against
	 * multiple inclusions, either with the conventional
	 * \#ifndef/\#define/\#endif macro guards or with \#pragma once.
	 */
	isFileMultipleIncludeGuarded :: proc(tu: CXTranslationUnit, file: CXFile) -> _c_.uint --- 
	/**
	 * Retrieve a file handle within the given translation unit.
	 *
	 * \param tu the translation unit
	 *
	 * \param file_name the name of the file.
	 *
	 * \returns the file handle for the named file in the translation unit \p tu,
	 * or a NULL file handle if the file was not a part of this translation unit.
	 */
	getFile :: proc(tu: CXTranslationUnit, file_name: cstring) -> CXFile --- 
	/**
	 * Retrieve the buffer associated with the given file.
	 *
	 * \param tu the translation unit
	 *
	 * \param file the file for which to retrieve the buffer.
	 *
	 * \param size [out] if non-NULL, will be set to the size of the buffer.
	 *
	 * \returns a pointer to the buffer in memory that holds the contents of
	 * \p file, or a NULL pointer when the file is not loaded.
	 */
	getFileContents :: proc(tu: CXTranslationUnit, file: CXFile, size: ^_c_.size_t) -> cstring --- 
	/**
	 * Returns non-zero if the \c file1 and \c file2 point to the same file,
	 * or they are both NULL.
	 */
	File_isEqual :: proc(file1: CXFile, file2: CXFile) -> _c_.int --- 
	/**
	 * Returns the real path name of \c file.
	 *
	 * An empty string may be returned. Use \c clang_getFileName() in that case.
	 */
	File_tryGetRealPathName :: proc(file: CXFile) -> CXString --- 
	/**
	 * Retrieve a NULL (invalid) source location.
	 */
	getNullLocation :: proc() -> CXSourceLocation --- 
	/**
	 * Determine whether two source locations, which must refer into
	 * the same translation unit, refer to exactly the same point in the source
	 * code.
	 *
	 * \returns non-zero if the source locations refer to the same location, zero
	 * if they refer to different locations.
	 */
	equalLocations :: proc(loc1: CXSourceLocation, loc2: CXSourceLocation) -> _c_.uint --- 
	/**
	 * Retrieves the source location associated with a given file/line/column
	 * in a particular translation unit.
	 */
	getLocation :: proc(tu: CXTranslationUnit, file: CXFile, line: _c_.uint, column: _c_.uint) -> CXSourceLocation --- 
	/**
	 * Retrieves the source location associated with a given character offset
	 * in a particular translation unit.
	 */
	getLocationForOffset :: proc(tu: CXTranslationUnit, file: CXFile, offset: _c_.uint) -> CXSourceLocation --- 
	/**
	 * Returns non-zero if the given source location is in a system header.
	 */
	Location_isInSystemHeader :: proc(location: CXSourceLocation) -> _c_.int --- 
	/**
	 * Returns non-zero if the given source location is in the main file of
	 * the corresponding translation unit.
	 */
	Location_isFromMainFile :: proc(location: CXSourceLocation) -> _c_.int --- 
	/**
	 * Retrieve a NULL (invalid) source range.
	 */
	getNullRange :: proc() -> CXSourceRange --- 
	/**
	 * Retrieve a source range given the beginning and ending source
	 * locations.
	 */
	getRange :: proc(begin: CXSourceLocation, end: CXSourceLocation) -> CXSourceRange --- 
	/**
	 * Determine whether two ranges are equivalent.
	 *
	 * \returns non-zero if the ranges are the same, zero if they differ.
	 */
	equalRanges :: proc(range1: CXSourceRange, range2: CXSourceRange) -> _c_.uint --- 
	/**
	 * Returns non-zero if \p range is null.
	 */
	Range_isNull :: proc(range: CXSourceRange) -> _c_.int --- 
	/**
	 * Retrieve the file, line, column, and offset represented by
	 * the given source location.
	 *
	 * If the location refers into a macro expansion, retrieves the
	 * location of the macro expansion.
	 *
	 * \param location the location within a source file that will be decomposed
	 * into its parts.
	 *
	 * \param file [out] if non-NULL, will be set to the file to which the given
	 * source location points.
	 *
	 * \param line [out] if non-NULL, will be set to the line to which the given
	 * source location points.
	 *
	 * \param column [out] if non-NULL, will be set to the column to which the given
	 * source location points.
	 *
	 * \param offset [out] if non-NULL, will be set to the offset into the
	 * buffer to which the given source location points.
	 */
	getExpansionLocation :: proc(location: CXSourceLocation, file: ^CXFile, line: ^_c_.uint, column: ^_c_.uint, offset: ^_c_.uint) --- 
	/**
	 * Retrieve the file, line and column represented by the given source
	 * location, as specified in a # line directive.
	 *
	 * Example: given the following source code in a file somefile.c
	 *
	 * \code
	 * #123 "dummy.c" 1
	 *
	 * static int func(void)
	 * {
	 *     return 0;
	 * }
	 * \endcode
	 *
	 * the location information returned by this function would be
	 *
	 * File: dummy.c Line: 124 Column: 12
	 *
	 * whereas clang_getExpansionLocation would have returned
	 *
	 * File: somefile.c Line: 3 Column: 12
	 *
	 * \param location the location within a source file that will be decomposed
	 * into its parts.
	 *
	 * \param filename [out] if non-NULL, will be set to the filename of the
	 * source location. Note that filenames returned will be for "virtual" files,
	 * which don't necessarily exist on the machine running clang - e.g. when
	 * parsing preprocessed output obtained from a different environment. If
	 * a non-NULL value is passed in, remember to dispose of the returned value
	 * using \c clang_disposeString() once you've finished with it. For an invalid
	 * source location, an empty string is returned.
	 *
	 * \param line [out] if non-NULL, will be set to the line number of the
	 * source location. For an invalid source location, zero is returned.
	 *
	 * \param column [out] if non-NULL, will be set to the column number of the
	 * source location. For an invalid source location, zero is returned.
	 */
	getPresumedLocation :: proc(location: CXSourceLocation, filename: ^CXString, line: ^_c_.uint, column: ^_c_.uint) --- 
	/**
	 * Legacy API to retrieve the file, line, column, and offset represented
	 * by the given source location.
	 *
	 * This interface has been replaced by the newer interface
	 * #clang_getExpansionLocation(). See that interface's documentation for
	 * details.
	 */
	getInstantiationLocation :: proc(location: CXSourceLocation, file: ^CXFile, line: ^_c_.uint, column: ^_c_.uint, offset: ^_c_.uint) --- 
	/**
	 * Retrieve the file, line, column, and offset represented by
	 * the given source location.
	 *
	 * If the location refers into a macro instantiation, return where the
	 * location was originally spelled in the source file.
	 *
	 * \param location the location within a source file that will be decomposed
	 * into its parts.
	 *
	 * \param file [out] if non-NULL, will be set to the file to which the given
	 * source location points.
	 *
	 * \param line [out] if non-NULL, will be set to the line to which the given
	 * source location points.
	 *
	 * \param column [out] if non-NULL, will be set to the column to which the given
	 * source location points.
	 *
	 * \param offset [out] if non-NULL, will be set to the offset into the
	 * buffer to which the given source location points.
	 */
	getSpellingLocation :: proc(location: CXSourceLocation, file: ^CXFile, line: ^_c_.uint, column: ^_c_.uint, offset: ^_c_.uint) --- 
	/**
	 * Retrieve the file, line, column, and offset represented by
	 * the given source location.
	 *
	 * If the location refers into a macro expansion, return where the macro was
	 * expanded or where the macro argument was written, if the location points at
	 * a macro argument.
	 *
	 * \param location the location within a source file that will be decomposed
	 * into its parts.
	 *
	 * \param file [out] if non-NULL, will be set to the file to which the given
	 * source location points.
	 *
	 * \param line [out] if non-NULL, will be set to the line to which the given
	 * source location points.
	 *
	 * \param column [out] if non-NULL, will be set to the column to which the given
	 * source location points.
	 *
	 * \param offset [out] if non-NULL, will be set to the offset into the
	 * buffer to which the given source location points.
	 */
	getFileLocation :: proc(location: CXSourceLocation, file: ^CXFile, line: ^_c_.uint, column: ^_c_.uint, offset: ^_c_.uint) --- 
	/**
	 * Retrieve a source location representing the first character within a
	 * source range.
	 */
	getRangeStart :: proc(range: CXSourceRange) -> CXSourceLocation --- 
	/**
	 * Retrieve a source location representing the last character within a
	 * source range.
	 */
	getRangeEnd :: proc(range: CXSourceRange) -> CXSourceLocation --- 
	/**
	 * Retrieve all ranges that were skipped by the preprocessor.
	 *
	 * The preprocessor will skip lines when they are surrounded by an
	 * if/ifdef/ifndef directive whose condition does not evaluate to true.
	 */
	getSkippedRanges :: proc(tu: CXTranslationUnit, file: CXFile) -> ^CXSourceRangeList --- 
	/**
	 * Retrieve all ranges from all files that were skipped by the
	 * preprocessor.
	 *
	 * The preprocessor will skip lines when they are surrounded by an
	 * if/ifdef/ifndef directive whose condition does not evaluate to true.
	 */
	getAllSkippedRanges :: proc(tu: CXTranslationUnit) -> ^CXSourceRangeList --- 
	/**
	 * Destroy the given \c CXSourceRangeList.
	 */
	disposeSourceRangeList :: proc(ranges: ^CXSourceRangeList) --- 
	/**
	 * Determine the number of diagnostics in a CXDiagnosticSet.
	 */
	getNumDiagnosticsInSet :: proc(Diags: CXDiagnosticSet) -> _c_.uint --- 
	/**
	 * Retrieve a diagnostic associated with the given CXDiagnosticSet.
	 *
	 * \param Diags the CXDiagnosticSet to query.
	 * \param Index the zero-based diagnostic number to retrieve.
	 *
	 * \returns the requested diagnostic. This diagnostic must be freed
	 * via a call to \c clang_disposeDiagnostic().
	 */
	getDiagnosticInSet :: proc(Diags: CXDiagnosticSet, Index: _c_.uint) -> CXDiagnostic --- 
	/**
	 * Deserialize a set of diagnostics from a Clang diagnostics bitcode
	 * file.
	 *
	 * \param file The name of the file to deserialize.
	 * \param error A pointer to a enum value recording if there was a problem
	 *        deserializing the diagnostics.
	 * \param errorString A pointer to a CXString for recording the error string
	 *        if the file was not successfully loaded.
	 *
	 * \returns A loaded CXDiagnosticSet if successful, and NULL otherwise.  These
	 * diagnostics should be released using clang_disposeDiagnosticSet().
	 */
	loadDiagnostics :: proc(file: cstring, error: ^CXLoadDiag_Error, errorString: ^CXString) -> CXDiagnosticSet --- 
	/**
	 * Release a CXDiagnosticSet and all of its contained diagnostics.
	 */
	disposeDiagnosticSet :: proc(Diags: CXDiagnosticSet) --- 
	/**
	 * Retrieve the child diagnostics of a CXDiagnostic.
	 *
	 * This CXDiagnosticSet does not need to be released by
	 * clang_disposeDiagnosticSet.
	 */
	getChildDiagnostics :: proc(D: CXDiagnostic) -> CXDiagnosticSet --- 
	/**
	 * Determine the number of diagnostics produced for the given
	 * translation unit.
	 */
	getNumDiagnostics :: proc(Unit: CXTranslationUnit) -> _c_.uint --- 
	/**
	 * Retrieve a diagnostic associated with the given translation unit.
	 *
	 * \param Unit the translation unit to query.
	 * \param Index the zero-based diagnostic number to retrieve.
	 *
	 * \returns the requested diagnostic. This diagnostic must be freed
	 * via a call to \c clang_disposeDiagnostic().
	 */
	getDiagnostic :: proc(Unit: CXTranslationUnit, Index: _c_.uint) -> CXDiagnostic --- 
	/**
	 * Retrieve the complete set of diagnostics associated with a
	 *        translation unit.
	 *
	 * \param Unit the translation unit to query.
	 */
	getDiagnosticSetFromTU :: proc(Unit: CXTranslationUnit) -> CXDiagnosticSet --- 
	/**
	 * Destroy a diagnostic.
	 */
	disposeDiagnostic :: proc(Diagnostic: CXDiagnostic) --- 
	/**
	 * Format the given diagnostic in a manner that is suitable for display.
	 *
	 * This routine will format the given diagnostic to a string, rendering
	 * the diagnostic according to the various options given. The
	 * \c clang_defaultDiagnosticDisplayOptions() function returns the set of
	 * options that most closely mimics the behavior of the clang compiler.
	 *
	 * \param Diagnostic The diagnostic to print.
	 *
	 * \param Options A set of options that control the diagnostic display,
	 * created by combining \c CXDiagnosticDisplayOptions values.
	 *
	 * \returns A new string containing for formatted diagnostic.
	 */
	formatDiagnostic :: proc(Diagnostic: CXDiagnostic, Options: _c_.uint) -> CXString --- 
	/**
	 * Retrieve the set of display options most similar to the
	 * default behavior of the clang compiler.
	 *
	 * \returns A set of display options suitable for use with \c
	 * clang_formatDiagnostic().
	 */
	defaultDiagnosticDisplayOptions :: proc() -> _c_.uint --- 
	/**
	 * Determine the severity of the given diagnostic.
	 */
	getDiagnosticSeverity :: proc(_: CXDiagnostic) -> CXDiagnosticSeverity --- 
	/**
	 * Retrieve the source location of the given diagnostic.
	 *
	 * This location is where Clang would print the caret ('^') when
	 * displaying the diagnostic on the command line.
	 */
	getDiagnosticLocation :: proc(_: CXDiagnostic) -> CXSourceLocation --- 
	/**
	 * Retrieve the text of the given diagnostic.
	 */
	getDiagnosticSpelling :: proc(_: CXDiagnostic) -> CXString --- 
	/**
	 * Retrieve the name of the command-line option that enabled this
	 * diagnostic.
	 *
	 * \param Diag The diagnostic to be queried.
	 *
	 * \param Disable If non-NULL, will be set to the option that disables this
	 * diagnostic (if any).
	 *
	 * \returns A string that contains the command-line option used to enable this
	 * warning, such as "-Wconversion" or "-pedantic".
	 */
	getDiagnosticOption :: proc(Diag: CXDiagnostic, Disable: ^CXString) -> CXString --- 
	/**
	 * Retrieve the category number for this diagnostic.
	 *
	 * Diagnostics can be categorized into groups along with other, related
	 * diagnostics (e.g., diagnostics under the same warning flag). This routine
	 * retrieves the category number for the given diagnostic.
	 *
	 * \returns The number of the category that contains this diagnostic, or zero
	 * if this diagnostic is uncategorized.
	 */
	getDiagnosticCategory :: proc(_: CXDiagnostic) -> _c_.uint --- 
	/**
	 * Retrieve the name of a particular diagnostic category.  This
	 *  is now deprecated.  Use clang_getDiagnosticCategoryText()
	 *  instead.
	 *
	 * \param Category A diagnostic category number, as returned by
	 * \c clang_getDiagnosticCategory().
	 *
	 * \returns The name of the given diagnostic category.
	 */
	getDiagnosticCategoryName :: proc(Category: _c_.uint) -> CXString --- 
	/**
	 * Retrieve the diagnostic category text for a given diagnostic.
	 *
	 * \returns The text of the given diagnostic category.
	 */
	getDiagnosticCategoryText :: proc(_: CXDiagnostic) -> CXString --- 
	/**
	 * Determine the number of source ranges associated with the given
	 * diagnostic.
	 */
	getDiagnosticNumRanges :: proc(_: CXDiagnostic) -> _c_.uint --- 
	/**
	 * Retrieve a source range associated with the diagnostic.
	 *
	 * A diagnostic's source ranges highlight important elements in the source
	 * code. On the command line, Clang displays source ranges by
	 * underlining them with '~' characters.
	 *
	 * \param Diagnostic the diagnostic whose range is being extracted.
	 *
	 * \param Range the zero-based index specifying which range to
	 *
	 * \returns the requested source range.
	 */
	getDiagnosticRange :: proc(Diagnostic: CXDiagnostic, Range: _c_.uint) -> CXSourceRange --- 
	/**
	 * Determine the number of fix-it hints associated with the
	 * given diagnostic.
	 */
	getDiagnosticNumFixIts :: proc(Diagnostic: CXDiagnostic) -> _c_.uint --- 
	/**
	 * Retrieve the replacement information for a given fix-it.
	 *
	 * Fix-its are described in terms of a source range whose contents
	 * should be replaced by a string. This approach generalizes over
	 * three kinds of operations: removal of source code (the range covers
	 * the code to be removed and the replacement string is empty),
	 * replacement of source code (the range covers the code to be
	 * replaced and the replacement string provides the new code), and
	 * insertion (both the start and end of the range point at the
	 * insertion location, and the replacement string provides the text to
	 * insert).
	 *
	 * \param Diagnostic The diagnostic whose fix-its are being queried.
	 *
	 * \param FixIt The zero-based index of the fix-it.
	 *
	 * \param ReplacementRange The source range whose contents will be
	 * replaced with the returned replacement string. Note that source
	 * ranges are half-open ranges [a, b), so the source code should be
	 * replaced from a and up to (but not including) b.
	 *
	 * \returns A string containing text that should be replace the source
	 * code indicated by the \c ReplacementRange.
	 */
	getDiagnosticFixIt :: proc(Diagnostic: CXDiagnostic, FixIt: _c_.uint, ReplacementRange: ^CXSourceRange) -> CXString --- 
	/**
	 * Get the original translation unit source file name.
	 */
	getTranslationUnitSpelling :: proc(CTUnit: CXTranslationUnit) -> CXString --- 
	/**
	 * Return the CXTranslationUnit for a given source file and the provided
	 * command line arguments one would pass to the compiler.
	 *
	 * Note: The 'source_filename' argument is optional.  If the caller provides a
	 * NULL pointer, the name of the source file is expected to reside in the
	 * specified command line arguments.
	 *
	 * Note: When encountered in 'clang_command_line_args', the following options
	 * are ignored:
	 *
	 *   '-c'
	 *   '-emit-ast'
	 *   '-fsyntax-only'
	 *   '-o \<output file>'  (both '-o' and '\<output file>' are ignored)
	 *
	 * \param CIdx The index object with which the translation unit will be
	 * associated.
	 *
	 * \param source_filename The name of the source file to load, or NULL if the
	 * source file is included in \p clang_command_line_args.
	 *
	 * \param num_clang_command_line_args The number of command-line arguments in
	 * \p clang_command_line_args.
	 *
	 * \param clang_command_line_args The command-line arguments that would be
	 * passed to the \c clang executable if it were being invoked out-of-process.
	 * These command-line options will be parsed and will affect how the translation
	 * unit is parsed. Note that the following options are ignored: '-c',
	 * '-emit-ast', '-fsyntax-only' (which is the default), and '-o \<output file>'.
	 *
	 * \param num_unsaved_files the number of unsaved file entries in \p
	 * unsaved_files.
	 *
	 * \param unsaved_files the files that have not yet been saved to disk
	 * but may be required for code completion, including the contents of
	 * those files.  The contents and name of these files (as specified by
	 * CXUnsavedFile) are copied when necessary, so the client only needs to
	 * guarantee their validity until the call to this function returns.
	 */
	createTranslationUnitFromSourceFile :: proc(CIdx: CXIndex, source_filename: cstring, num_clang_command_line_args: _c_.int, clang_command_line_args: ^cstring, num_unsaved_files: _c_.uint, unsaved_files: ^CXUnsavedFile) -> CXTranslationUnit --- 
	/**
	 * Same as \c clang_createTranslationUnit2, but returns
	 * the \c CXTranslationUnit instead of an error code.  In case of an error this
	 * routine returns a \c NULL \c CXTranslationUnit, without further detailed
	 * error codes.
	 */
	createTranslationUnit :: proc(CIdx: CXIndex, ast_filename: cstring) -> CXTranslationUnit --- 
	/**
	 * Create a translation unit from an AST file (\c -emit-ast).
	 *
	 * \param[out] out_TU A non-NULL pointer to store the created
	 * \c CXTranslationUnit.
	 *
	 * \returns Zero on success, otherwise returns an error code.
	 */
	createTranslationUnit2 :: proc(CIdx: CXIndex, ast_filename: cstring, out_TU: ^CXTranslationUnit) -> CXErrorCode --- 
	/**
	 * Returns the set of flags that is suitable for parsing a translation
	 * unit that is being edited.
	 *
	 * The set of flags returned provide options for \c clang_parseTranslationUnit()
	 * to indicate that the translation unit is likely to be reparsed many times,
	 * either explicitly (via \c clang_reparseTranslationUnit()) or implicitly
	 * (e.g., by code completion (\c clang_codeCompletionAt())). The returned flag
	 * set contains an unspecified set of optimizations (e.g., the precompiled
	 * preamble) geared toward improving the performance of these routines. The
	 * set of optimizations enabled may change from one version to the next.
	 */
	defaultEditingTranslationUnitOptions :: proc() -> _c_.uint --- 
	/**
	 * Same as \c clang_parseTranslationUnit2, but returns
	 * the \c CXTranslationUnit instead of an error code.  In case of an error this
	 * routine returns a \c NULL \c CXTranslationUnit, without further detailed
	 * error codes.
	 */
	parseTranslationUnit :: proc(CIdx: CXIndex, source_filename: cstring, command_line_args: ^cstring, num_command_line_args: _c_.int, unsaved_files: ^CXUnsavedFile, num_unsaved_files: _c_.uint, options: _c_.uint) -> CXTranslationUnit --- 
	/**
	 * Parse the given source file and the translation unit corresponding
	 * to that file.
	 *
	 * This routine is the main entry point for the Clang C API, providing the
	 * ability to parse a source file into a translation unit that can then be
	 * queried by other functions in the API. This routine accepts a set of
	 * command-line arguments so that the compilation can be configured in the same
	 * way that the compiler is configured on the command line.
	 *
	 * \param CIdx The index object with which the translation unit will be
	 * associated.
	 *
	 * \param source_filename The name of the source file to load, or NULL if the
	 * source file is included in \c command_line_args.
	 *
	 * \param command_line_args The command-line arguments that would be
	 * passed to the \c clang executable if it were being invoked out-of-process.
	 * These command-line options will be parsed and will affect how the translation
	 * unit is parsed. Note that the following options are ignored: '-c',
	 * '-emit-ast', '-fsyntax-only' (which is the default), and '-o \<output file>'.
	 *
	 * \param num_command_line_args The number of command-line arguments in
	 * \c command_line_args.
	 *
	 * \param unsaved_files the files that have not yet been saved to disk
	 * but may be required for parsing, including the contents of
	 * those files.  The contents and name of these files (as specified by
	 * CXUnsavedFile) are copied when necessary, so the client only needs to
	 * guarantee their validity until the call to this function returns.
	 *
	 * \param num_unsaved_files the number of unsaved file entries in \p
	 * unsaved_files.
	 *
	 * \param options A bitmask of options that affects how the translation unit
	 * is managed but not its compilation. This should be a bitwise OR of the
	 * CXTranslationUnit_XXX flags.
	 *
	 * \param[out] out_TU A non-NULL pointer to store the created
	 * \c CXTranslationUnit, describing the parsed code and containing any
	 * diagnostics produced by the compiler.
	 *
	 * \returns Zero on success, otherwise returns an error code.
	 */
	parseTranslationUnit2 :: proc(CIdx: CXIndex, source_filename: cstring, command_line_args: ^cstring, num_command_line_args: _c_.int, unsaved_files: ^CXUnsavedFile, num_unsaved_files: _c_.uint, options: _c_.uint, out_TU: ^CXTranslationUnit) -> CXErrorCode --- 
	/**
	 * Same as clang_parseTranslationUnit2 but requires a full command line
	 * for \c command_line_args including argv[0]. This is useful if the standard
	 * library paths are relative to the binary.
	 */
	parseTranslationUnit2FullArgv :: proc(CIdx: CXIndex, source_filename: cstring, command_line_args: ^cstring, num_command_line_args: _c_.int, unsaved_files: ^CXUnsavedFile, num_unsaved_files: _c_.uint, options: _c_.uint, out_TU: ^CXTranslationUnit) -> CXErrorCode --- 
	/**
	 * Returns the set of flags that is suitable for saving a translation
	 * unit.
	 *
	 * The set of flags returned provide options for
	 * \c clang_saveTranslationUnit() by default. The returned flag
	 * set contains an unspecified set of options that save translation units with
	 * the most commonly-requested data.
	 */
	defaultSaveOptions :: proc(TU: CXTranslationUnit) -> _c_.uint --- 
	/**
	 * Saves a translation unit into a serialized representation of
	 * that translation unit on disk.
	 *
	 * Any translation unit that was parsed without error can be saved
	 * into a file. The translation unit can then be deserialized into a
	 * new \c CXTranslationUnit with \c clang_createTranslationUnit() or,
	 * if it is an incomplete translation unit that corresponds to a
	 * header, used as a precompiled header when parsing other translation
	 * units.
	 *
	 * \param TU The translation unit to save.
	 *
	 * \param FileName The file to which the translation unit will be saved.
	 *
	 * \param options A bitmask of options that affects how the translation unit
	 * is saved. This should be a bitwise OR of the
	 * CXSaveTranslationUnit_XXX flags.
	 *
	 * \returns A value that will match one of the enumerators of the CXSaveError
	 * enumeration. Zero (CXSaveError_None) indicates that the translation unit was
	 * saved successfully, while a non-zero value indicates that a problem occurred.
	 */
	saveTranslationUnit :: proc(TU: CXTranslationUnit, FileName: cstring, options: _c_.uint) -> _c_.int --- 
	/**
	 * Suspend a translation unit in order to free memory associated with it.
	 *
	 * A suspended translation unit uses significantly less memory but on the other
	 * side does not support any other calls than \c clang_reparseTranslationUnit
	 * to resume it or \c clang_disposeTranslationUnit to dispose it completely.
	 */
	suspendTranslationUnit :: proc(_: CXTranslationUnit) -> _c_.uint --- 
	/**
	 * Destroy the specified CXTranslationUnit object.
	 */
	disposeTranslationUnit :: proc(_: CXTranslationUnit) --- 
	/**
	 * Returns the set of flags that is suitable for reparsing a translation
	 * unit.
	 *
	 * The set of flags returned provide options for
	 * \c clang_reparseTranslationUnit() by default. The returned flag
	 * set contains an unspecified set of optimizations geared toward common uses
	 * of reparsing. The set of optimizations enabled may change from one version
	 * to the next.
	 */
	defaultReparseOptions :: proc(TU: CXTranslationUnit) -> _c_.uint --- 
	/**
	 * Reparse the source files that produced this translation unit.
	 *
	 * This routine can be used to re-parse the source files that originally
	 * created the given translation unit, for example because those source files
	 * have changed (either on disk or as passed via \p unsaved_files). The
	 * source code will be reparsed with the same command-line options as it
	 * was originally parsed.
	 *
	 * Reparsing a translation unit invalidates all cursors and source locations
	 * that refer into that translation unit. This makes reparsing a translation
	 * unit semantically equivalent to destroying the translation unit and then
	 * creating a new translation unit with the same command-line arguments.
	 * However, it may be more efficient to reparse a translation
	 * unit using this routine.
	 *
	 * \param TU The translation unit whose contents will be re-parsed. The
	 * translation unit must originally have been built with
	 * \c clang_createTranslationUnitFromSourceFile().
	 *
	 * \param num_unsaved_files The number of unsaved file entries in \p
	 * unsaved_files.
	 *
	 * \param unsaved_files The files that have not yet been saved to disk
	 * but may be required for parsing, including the contents of
	 * those files.  The contents and name of these files (as specified by
	 * CXUnsavedFile) are copied when necessary, so the client only needs to
	 * guarantee their validity until the call to this function returns.
	 *
	 * \param options A bitset of options composed of the flags in CXReparse_Flags.
	 * The function \c clang_defaultReparseOptions() produces a default set of
	 * options recommended for most uses, based on the translation unit.
	 *
	 * \returns 0 if the sources could be reparsed.  A non-zero error code will be
	 * returned if reparsing was impossible, such that the translation unit is
	 * invalid. In such cases, the only valid call for \c TU is
	 * \c clang_disposeTranslationUnit(TU).  The error codes returned by this
	 * routine are described by the \c CXErrorCode enum.
	 */
	reparseTranslationUnit :: proc(TU: CXTranslationUnit, num_unsaved_files: _c_.uint, unsaved_files: ^CXUnsavedFile, options: _c_.uint) -> _c_.int --- 
	/**
	 * Returns the human-readable null-terminated C string that represents
	 *  the name of the memory category.  This string should never be freed.
	 */
	getTUResourceUsageName :: proc(kind: CXTUResourceUsageKind) -> cstring --- 
	/**
	 * Return the memory usage of a translation unit.  This object
	 *  should be released with clang_disposeCXTUResourceUsage().
	 */
	getCXTUResourceUsage :: proc(TU: CXTranslationUnit) -> CXTUResourceUsage --- 
	disposeCXTUResourceUsage :: proc(usage: CXTUResourceUsage) --- 
	/**
	 * Get target information for this translation unit.
	 *
	 * The CXTargetInfo object cannot outlive the CXTranslationUnit object.
	 */
	getTranslationUnitTargetInfo :: proc(CTUnit: CXTranslationUnit) -> CXTargetInfo --- 
	/**
	 * Destroy the CXTargetInfo object.
	 */
	TargetInfo_dispose :: proc(Info: CXTargetInfo) --- 
	/**
	 * Get the normalized target triple as a string.
	 *
	 * Returns the empty string in case of any error.
	 */
	TargetInfo_getTriple :: proc(Info: CXTargetInfo) -> CXString --- 
	/**
	 * Get the pointer width of the target in bits.
	 *
	 * Returns -1 in case of error.
	 */
	TargetInfo_getPointerWidth :: proc(Info: CXTargetInfo) -> _c_.int --- 
	/**
	 * Retrieve the NULL cursor, which represents no entity.
	 */
	getNullCursor :: proc() -> CXCursor --- 
	/**
	 * Retrieve the cursor that represents the given translation unit.
	 *
	 * The translation unit cursor can be used to start traversing the
	 * various declarations within the given translation unit.
	 */
	getTranslationUnitCursor :: proc(_: CXTranslationUnit) -> CXCursor --- 
	/**
	 * Determine whether two cursors are equivalent.
	 */
	equalCursors :: proc(_: CXCursor, _: CXCursor) -> _c_.uint --- 
	/**
	 * Returns non-zero if \p cursor is null.
	 */
	Cursor_isNull :: proc(cursor: CXCursor) -> _c_.int --- 
	/**
	 * Compute a hash value for the given cursor.
	 */
	hashCursor :: proc(_: CXCursor) -> _c_.uint --- 
	/**
	 * Retrieve the kind of the given cursor.
	 */
	getCursorKind :: proc(_: CXCursor) -> CXCursorKind --- 
	/**
	 * Determine whether the given cursor kind represents a declaration.
	 */
	isDeclaration :: proc(_: CXCursorKind) -> _c_.uint --- 
	/**
	 * Determine whether the given declaration is invalid.
	 *
	 * A declaration is invalid if it could not be parsed successfully.
	 *
	 * \returns non-zero if the cursor represents a declaration and it is
	 * invalid, otherwise NULL.
	 */
	isInvalidDeclaration :: proc(_: CXCursor) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor kind represents a simple
	 * reference.
	 *
	 * Note that other kinds of cursors (such as expressions) can also refer to
	 * other cursors. Use clang_getCursorReferenced() to determine whether a
	 * particular cursor refers to another entity.
	 */
	isReference :: proc(_: CXCursorKind) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor kind represents an expression.
	 */
	isExpression :: proc(_: CXCursorKind) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor kind represents a statement.
	 */
	isStatement :: proc(_: CXCursorKind) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor kind represents an attribute.
	 */
	isAttribute :: proc(_: CXCursorKind) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor has any attributes.
	 */
	Cursor_hasAttrs :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor kind represents an invalid
	 * cursor.
	 */
	isInvalid :: proc(_: CXCursorKind) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor kind represents a translation
	 * unit.
	 */
	isTranslationUnit :: proc(_: CXCursorKind) -> _c_.uint --- 
	/***
	 * Determine whether the given cursor represents a preprocessing
	 * element, such as a preprocessor directive or macro instantiation.
	 */
	isPreprocessing :: proc(_: CXCursorKind) -> _c_.uint --- 
	/***
	 * Determine whether the given cursor represents a currently
	 *  unexposed piece of the AST (e.g., CXCursor_UnexposedStmt).
	 */
	isUnexposed :: proc(_: CXCursorKind) -> _c_.uint --- 
	/**
	 * Determine the linkage of the entity referred to by a given cursor.
	 */
	getCursorLinkage :: proc(cursor: CXCursor) -> CXLinkageKind --- 
	/**
	 * Describe the visibility of the entity referred to by a cursor.
	 *
	 * This returns the default visibility if not explicitly specified by
	 * a visibility attribute. The default visibility may be changed by
	 * commandline arguments.
	 *
	 * \param cursor The cursor to query.
	 *
	 * \returns The visibility of the cursor.
	 */
	getCursorVisibility :: proc(cursor: CXCursor) -> CXVisibilityKind --- 
	/**
	 * Determine the availability of the entity that this cursor refers to,
	 * taking the current target platform into account.
	 *
	 * \param cursor The cursor to query.
	 *
	 * \returns The availability of the cursor.
	 */
	getCursorAvailability :: proc(cursor: CXCursor) -> CXAvailabilityKind --- 
	/**
	 * Determine the availability of the entity that this cursor refers to
	 * on any platforms for which availability information is known.
	 *
	 * \param cursor The cursor to query.
	 *
	 * \param always_deprecated If non-NULL, will be set to indicate whether the
	 * entity is deprecated on all platforms.
	 *
	 * \param deprecated_message If non-NULL, will be set to the message text
	 * provided along with the unconditional deprecation of this entity. The client
	 * is responsible for deallocating this string.
	 *
	 * \param always_unavailable If non-NULL, will be set to indicate whether the
	 * entity is unavailable on all platforms.
	 *
	 * \param unavailable_message If non-NULL, will be set to the message text
	 * provided along with the unconditional unavailability of this entity. The
	 * client is responsible for deallocating this string.
	 *
	 * \param availability If non-NULL, an array of CXPlatformAvailability instances
	 * that will be populated with platform availability information, up to either
	 * the number of platforms for which availability information is available (as
	 * returned by this function) or \c availability_size, whichever is smaller.
	 *
	 * \param availability_size The number of elements available in the
	 * \c availability array.
	 *
	 * \returns The number of platforms (N) for which availability information is
	 * available (which is unrelated to \c availability_size).
	 *
	 * Note that the client is responsible for calling
	 * \c clang_disposeCXPlatformAvailability to free each of the
	 * platform-availability structures returned. There are
	 * \c min(N, availability_size) such structures.
	 */
	getCursorPlatformAvailability :: proc(cursor: CXCursor, always_deprecated: ^_c_.int, deprecated_message: ^CXString, always_unavailable: ^_c_.int, unavailable_message: ^CXString, availability: ^CXPlatformAvailability, availability_size: _c_.int) -> _c_.int --- 
	/**
	 * Free the memory associated with a \c CXPlatformAvailability structure.
	 */
	disposeCXPlatformAvailability :: proc(availability: ^CXPlatformAvailability) --- 
	/**
	 * If cursor refers to a variable declaration and it has initializer returns
	 * cursor referring to the initializer otherwise return null cursor.
	 */
	Cursor_getVarDeclInitializer :: proc(cursor: CXCursor) -> CXCursor --- 
	/**
	 * If cursor refers to a variable declaration that has global storage returns 1.
	 * If cursor refers to a variable declaration that doesn't have global storage
	 * returns 0. Otherwise returns -1.
	 */
	Cursor_hasVarDeclGlobalStorage :: proc(cursor: CXCursor) -> _c_.int --- 
	/**
	 * If cursor refers to a variable declaration that has external storage
	 * returns 1. If cursor refers to a variable declaration that doesn't have
	 * external storage returns 0. Otherwise returns -1.
	 */
	Cursor_hasVarDeclExternalStorage :: proc(cursor: CXCursor) -> _c_.int --- 
	/**
	 * Determine the "language" of the entity referred to by a given cursor.
	 */
	getCursorLanguage :: proc(cursor: CXCursor) -> CXLanguageKind --- 
	/**
	 * Determine the "thread-local storage (TLS) kind" of the declaration
	 * referred to by a cursor.
	 */
	getCursorTLSKind :: proc(cursor: CXCursor) -> CXTLSKind --- 
	/**
	 * Returns the translation unit that a cursor originated from.
	 */
	Cursor_getTranslationUnit :: proc(_: CXCursor) -> CXTranslationUnit --- 
	/**
	 * Creates an empty CXCursorSet.
	 */
	createCXCursorSet :: proc() -> CXCursorSet --- 
	/**
	 * Disposes a CXCursorSet and releases its associated memory.
	 */
	disposeCXCursorSet :: proc(cset: CXCursorSet) --- 
	/**
	 * Queries a CXCursorSet to see if it contains a specific CXCursor.
	 *
	 * \returns non-zero if the set contains the specified cursor.
	 */
	CXCursorSet_contains :: proc(cset: CXCursorSet, cursor: CXCursor) -> _c_.uint --- 
	/**
	 * Inserts a CXCursor into a CXCursorSet.
	 *
	 * \returns zero if the CXCursor was already in the set, and non-zero otherwise.
	 */
	CXCursorSet_insert :: proc(cset: CXCursorSet, cursor: CXCursor) -> _c_.uint --- 
	/**
	 * Determine the semantic parent of the given cursor.
	 *
	 * The semantic parent of a cursor is the cursor that semantically contains
	 * the given \p cursor. For many declarations, the lexical and semantic parents
	 * are equivalent (the lexical parent is returned by
	 * \c clang_getCursorLexicalParent()). They diverge when declarations or
	 * definitions are provided out-of-line. For example:
	 *
	 * \code
	 * class C {
	 *  void f();
	 * };
	 *
	 * void C::f() { }
	 * \endcode
	 *
	 * In the out-of-line definition of \c C::f, the semantic parent is
	 * the class \c C, of which this function is a member. The lexical parent is
	 * the place where the declaration actually occurs in the source code; in this
	 * case, the definition occurs in the translation unit. In general, the
	 * lexical parent for a given entity can change without affecting the semantics
	 * of the program, and the lexical parent of different declarations of the
	 * same entity may be different. Changing the semantic parent of a declaration,
	 * on the other hand, can have a major impact on semantics, and redeclarations
	 * of a particular entity should all have the same semantic context.
	 *
	 * In the example above, both declarations of \c C::f have \c C as their
	 * semantic context, while the lexical context of the first \c C::f is \c C
	 * and the lexical context of the second \c C::f is the translation unit.
	 *
	 * For global declarations, the semantic parent is the translation unit.
	 */
	getCursorSemanticParent :: proc(cursor: CXCursor) -> CXCursor --- 
	/**
	 * Determine the lexical parent of the given cursor.
	 *
	 * The lexical parent of a cursor is the cursor in which the given \p cursor
	 * was actually written. For many declarations, the lexical and semantic parents
	 * are equivalent (the semantic parent is returned by
	 * \c clang_getCursorSemanticParent()). They diverge when declarations or
	 * definitions are provided out-of-line. For example:
	 *
	 * \code
	 * class C {
	 *  void f();
	 * };
	 *
	 * void C::f() { }
	 * \endcode
	 *
	 * In the out-of-line definition of \c C::f, the semantic parent is
	 * the class \c C, of which this function is a member. The lexical parent is
	 * the place where the declaration actually occurs in the source code; in this
	 * case, the definition occurs in the translation unit. In general, the
	 * lexical parent for a given entity can change without affecting the semantics
	 * of the program, and the lexical parent of different declarations of the
	 * same entity may be different. Changing the semantic parent of a declaration,
	 * on the other hand, can have a major impact on semantics, and redeclarations
	 * of a particular entity should all have the same semantic context.
	 *
	 * In the example above, both declarations of \c C::f have \c C as their
	 * semantic context, while the lexical context of the first \c C::f is \c C
	 * and the lexical context of the second \c C::f is the translation unit.
	 *
	 * For declarations written in the global scope, the lexical parent is
	 * the translation unit.
	 */
	getCursorLexicalParent :: proc(cursor: CXCursor) -> CXCursor --- 
	/**
	 * Determine the set of methods that are overridden by the given
	 * method.
	 *
	 * In both Objective-C and C++, a method (aka virtual member function,
	 * in C++) can override a virtual method in a base class. For
	 * Objective-C, a method is said to override any method in the class's
	 * base class, its protocols, or its categories' protocols, that has the same
	 * selector and is of the same kind (class or instance).
	 * If no such method exists, the search continues to the class's superclass,
	 * its protocols, and its categories, and so on. A method from an Objective-C
	 * implementation is considered to override the same methods as its
	 * corresponding method in the interface.
	 *
	 * For C++, a virtual member function overrides any virtual member
	 * function with the same signature that occurs in its base
	 * classes. With multiple inheritance, a virtual member function can
	 * override several virtual member functions coming from different
	 * base classes.
	 *
	 * In all cases, this function determines the immediate overridden
	 * method, rather than all of the overridden methods. For example, if
	 * a method is originally declared in a class A, then overridden in B
	 * (which in inherits from A) and also in C (which inherited from B),
	 * then the only overridden method returned from this function when
	 * invoked on C's method will be B's method. The client may then
	 * invoke this function again, given the previously-found overridden
	 * methods, to map out the complete method-override set.
	 *
	 * \param cursor A cursor representing an Objective-C or C++
	 * method. This routine will compute the set of methods that this
	 * method overrides.
	 *
	 * \param overridden A pointer whose pointee will be replaced with a
	 * pointer to an array of cursors, representing the set of overridden
	 * methods. If there are no overridden methods, the pointee will be
	 * set to NULL. The pointee must be freed via a call to
	 * \c clang_disposeOverriddenCursors().
	 *
	 * \param num_overridden A pointer to the number of overridden
	 * functions, will be set to the number of overridden functions in the
	 * array pointed to by \p overridden.
	 */
	getOverriddenCursors :: proc(cursor: CXCursor, overridden: ^^CXCursor, num_overridden: ^_c_.uint) --- 
	/**
	 * Free the set of overridden cursors returned by \c
	 * clang_getOverriddenCursors().
	 */
	disposeOverriddenCursors :: proc(overridden: ^CXCursor) --- 
	/**
	 * Retrieve the file that is included by the given inclusion directive
	 * cursor.
	 */
	getIncludedFile :: proc(cursor: CXCursor) -> CXFile --- 
	/**
	 * Map a source location to the cursor that describes the entity at that
	 * location in the source code.
	 *
	 * clang_getCursor() maps an arbitrary source location within a translation
	 * unit down to the most specific cursor that describes the entity at that
	 * location. For example, given an expression \c x + y, invoking
	 * clang_getCursor() with a source location pointing to "x" will return the
	 * cursor for "x"; similarly for "y". If the cursor points anywhere between
	 * "x" or "y" (e.g., on the + or the whitespace around it), clang_getCursor()
	 * will return a cursor referring to the "+" expression.
	 *
	 * \returns a cursor representing the entity at the given source location, or
	 * a NULL cursor if no such entity can be found.
	 */
	getCursor :: proc(_: CXTranslationUnit, _: CXSourceLocation) -> CXCursor --- 
	/**
	 * Retrieve the physical location of the source constructor referenced
	 * by the given cursor.
	 *
	 * The location of a declaration is typically the location of the name of that
	 * declaration, where the name of that declaration would occur if it is
	 * unnamed, or some keyword that introduces that particular declaration.
	 * The location of a reference is where that reference occurs within the
	 * source code.
	 */
	getCursorLocation :: proc(_: CXCursor) -> CXSourceLocation --- 
	/**
	 * Retrieve the physical extent of the source construct referenced by
	 * the given cursor.
	 *
	 * The extent of a cursor starts with the file/line/column pointing at the
	 * first character within the source construct that the cursor refers to and
	 * ends with the last character within that source construct. For a
	 * declaration, the extent covers the declaration itself. For a reference,
	 * the extent covers the location of the reference (e.g., where the referenced
	 * entity was actually used).
	 */
	getCursorExtent :: proc(_: CXCursor) -> CXSourceRange --- 
	/**
	 * Retrieve the type of a CXCursor (if any).
	 */
	getCursorType :: proc(C: CXCursor) -> CXType --- 
	/**
	 * Pretty-print the underlying type using the rules of the
	 * language of the translation unit from which it came.
	 *
	 * If the type is invalid, an empty string is returned.
	 */
	getTypeSpelling :: proc(CT: CXType) -> CXString --- 
	/**
	 * Retrieve the underlying type of a typedef declaration.
	 *
	 * If the cursor does not reference a typedef declaration, an invalid type is
	 * returned.
	 */
	getTypedefDeclUnderlyingType :: proc(C: CXCursor) -> CXType --- 
	/**
	 * Retrieve the integer type of an enum declaration.
	 *
	 * If the cursor does not reference an enum declaration, an invalid type is
	 * returned.
	 */
	getEnumDeclIntegerType :: proc(C: CXCursor) -> CXType --- 
	/**
	 * Retrieve the integer value of an enum constant declaration as a signed
	 *  long long.
	 *
	 * If the cursor does not reference an enum constant declaration, LLONG_MIN is
	 * returned. Since this is also potentially a valid constant value, the kind of
	 * the cursor must be verified before calling this function.
	 */
	getEnumConstantDeclValue :: proc(C: CXCursor) -> _c_.longlong --- 
	/**
	 * Retrieve the integer value of an enum constant declaration as an unsigned
	 *  long long.
	 *
	 * If the cursor does not reference an enum constant declaration, ULLONG_MAX is
	 * returned. Since this is also potentially a valid constant value, the kind of
	 * the cursor must be verified before calling this function.
	 */
	getEnumConstantDeclUnsignedValue :: proc(C: CXCursor) -> _c_.ulonglong --- 
	/**
	 * Retrieve the bit width of a bit field declaration as an integer.
	 *
	 * If a cursor that is not a bit field declaration is passed in, -1 is returned.
	 */
	getFieldDeclBitWidth :: proc(C: CXCursor) -> _c_.int --- 
	/**
	 * Retrieve the number of non-variadic arguments associated with a given
	 * cursor.
	 *
	 * The number of arguments can be determined for calls as well as for
	 * declarations of functions or methods. For other cursors -1 is returned.
	 */
	Cursor_getNumArguments :: proc(C: CXCursor) -> _c_.int --- 
	/**
	 * Retrieve the argument cursor of a function or method.
	 *
	 * The argument cursor can be determined for calls as well as for declarations
	 * of functions or methods. For other cursors and for invalid indices, an
	 * invalid cursor is returned.
	 */
	Cursor_getArgument :: proc(C: CXCursor, i: _c_.uint) -> CXCursor --- 
	/**
	 *Returns the number of template args of a function decl representing a
	 * template specialization.
	 *
	 * If the argument cursor cannot be converted into a template function
	 * declaration, -1 is returned.
	 *
	 * For example, for the following declaration and specialization:
	 *   template <typename T, int kInt, bool kBool>
	 *   void foo() { ... }
	 *
	 *   template <>
	 *   void foo<float, -7, true>();
	 *
	 * The value 3 would be returned from this call.
	 */
	Cursor_getNumTemplateArguments :: proc(C: CXCursor) -> _c_.int --- 
	/**
	 * Retrieve the kind of the I'th template argument of the CXCursor C.
	 *
	 * If the argument CXCursor does not represent a FunctionDecl, an invalid
	 * template argument kind is returned.
	 *
	 * For example, for the following declaration and specialization:
	 *   template <typename T, int kInt, bool kBool>
	 *   void foo() { ... }
	 *
	 *   template <>
	 *   void foo<float, -7, true>();
	 *
	 * For I = 0, 1, and 2, Type, Integral, and Integral will be returned,
	 * respectively.
	 */
	Cursor_getTemplateArgumentKind :: proc(C: CXCursor, I: _c_.uint) -> CXTemplateArgumentKind --- 
	/**
	 * Retrieve a CXType representing the type of a TemplateArgument of a
	 *  function decl representing a template specialization.
	 *
	 * If the argument CXCursor does not represent a FunctionDecl whose I'th
	 * template argument has a kind of CXTemplateArgKind_Integral, an invalid type
	 * is returned.
	 *
	 * For example, for the following declaration and specialization:
	 *   template <typename T, int kInt, bool kBool>
	 *   void foo() { ... }
	 *
	 *   template <>
	 *   void foo<float, -7, true>();
	 *
	 * If called with I = 0, "float", will be returned.
	 * Invalid types will be returned for I == 1 or 2.
	 */
	Cursor_getTemplateArgumentType :: proc(C: CXCursor, I: _c_.uint) -> CXType --- 
	/**
	 * Retrieve the value of an Integral TemplateArgument (of a function
	 *  decl representing a template specialization) as a signed long long.
	 *
	 * It is undefined to call this function on a CXCursor that does not represent a
	 * FunctionDecl or whose I'th template argument is not an integral value.
	 *
	 * For example, for the following declaration and specialization:
	 *   template <typename T, int kInt, bool kBool>
	 *   void foo() { ... }
	 *
	 *   template <>
	 *   void foo<float, -7, true>();
	 *
	 * If called with I = 1 or 2, -7 or true will be returned, respectively.
	 * For I == 0, this function's behavior is undefined.
	 */
	Cursor_getTemplateArgumentValue :: proc(C: CXCursor, I: _c_.uint) -> _c_.longlong --- 
	/**
	 * Retrieve the value of an Integral TemplateArgument (of a function
	 *  decl representing a template specialization) as an unsigned long long.
	 *
	 * It is undefined to call this function on a CXCursor that does not represent a
	 * FunctionDecl or whose I'th template argument is not an integral value.
	 *
	 * For example, for the following declaration and specialization:
	 *   template <typename T, int kInt, bool kBool>
	 *   void foo() { ... }
	 *
	 *   template <>
	 *   void foo<float, 2147483649, true>();
	 *
	 * If called with I = 1 or 2, 2147483649 or true will be returned, respectively.
	 * For I == 0, this function's behavior is undefined.
	 */
	Cursor_getTemplateArgumentUnsignedValue :: proc(C: CXCursor, I: _c_.uint) -> _c_.ulonglong --- 
	/**
	 * Determine whether two CXTypes represent the same type.
	 *
	 * \returns non-zero if the CXTypes represent the same type and
	 *          zero otherwise.
	 */
	equalTypes :: proc(A: CXType, B: CXType) -> _c_.uint --- 
	/**
	 * Return the canonical type for a CXType.
	 *
	 * Clang's type system explicitly models typedefs and all the ways
	 * a specific type can be represented.  The canonical type is the underlying
	 * type with all the "sugar" removed.  For example, if 'T' is a typedef
	 * for 'int', the canonical type for 'T' would be 'int'.
	 */
	getCanonicalType :: proc(T: CXType) -> CXType --- 
	/**
	 * Determine whether a CXType has the "const" qualifier set,
	 * without looking through typedefs that may have added "const" at a
	 * different level.
	 */
	isConstQualifiedType :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Determine whether a  CXCursor that is a macro, is
	 * function like.
	 */
	Cursor_isMacroFunctionLike :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine whether a  CXCursor that is a macro, is a
	 * builtin one.
	 */
	Cursor_isMacroBuiltin :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine whether a  CXCursor that is a function declaration, is an
	 * inline declaration.
	 */
	Cursor_isFunctionInlined :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine whether a CXType has the "volatile" qualifier set,
	 * without looking through typedefs that may have added "volatile" at
	 * a different level.
	 */
	isVolatileQualifiedType :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Determine whether a CXType has the "restrict" qualifier set,
	 * without looking through typedefs that may have added "restrict" at a
	 * different level.
	 */
	isRestrictQualifiedType :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Returns the address space of the given type.
	 */
	getAddressSpace :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Returns the typedef name of the given type.
	 */
	getTypedefName :: proc(CT: CXType) -> CXString --- 
	/**
	 * For pointer types, returns the type of the pointee.
	 */
	getPointeeType :: proc(T: CXType) -> CXType --- 
	/**
	 * Return the cursor for the declaration of the given type.
	 */
	getTypeDeclaration :: proc(T: CXType) -> CXCursor --- 
	/**
	 * Returns the Objective-C type encoding for the specified declaration.
	 */
	getDeclObjCTypeEncoding :: proc(C: CXCursor) -> CXString --- 
	/**
	 * Returns the Objective-C type encoding for the specified CXType.
	 */
	Type_getObjCEncoding :: proc(type: CXType) -> CXString --- 
	/**
	 * Retrieve the spelling of a given CXTypeKind.
	 */
	getTypeKindSpelling :: proc(K: CXTypeKind) -> CXString --- 
	/**
	 * Retrieve the calling convention associated with a function type.
	 *
	 * If a non-function type is passed in, CXCallingConv_Invalid is returned.
	 */
	getFunctionTypeCallingConv :: proc(T: CXType) -> CXCallingConv --- 
	/**
	 * Retrieve the return type associated with a function type.
	 *
	 * If a non-function type is passed in, an invalid type is returned.
	 */
	getResultType :: proc(T: CXType) -> CXType --- 
	/**
	 * Retrieve the exception specification type associated with a function type.
	 * This is a value of type CXCursor_ExceptionSpecificationKind.
	 *
	 * If a non-function type is passed in, an error code of -1 is returned.
	 */
	getExceptionSpecificationType :: proc(T: CXType) -> _c_.int --- 
	/**
	 * Retrieve the number of non-variadic parameters associated with a
	 * function type.
	 *
	 * If a non-function type is passed in, -1 is returned.
	 */
	getNumArgTypes :: proc(T: CXType) -> _c_.int --- 
	/**
	 * Retrieve the type of a parameter of a function type.
	 *
	 * If a non-function type is passed in or the function does not have enough
	 * parameters, an invalid type is returned.
	 */
	getArgType :: proc(T: CXType, i: _c_.uint) -> CXType --- 
	/**
	 * Retrieves the base type of the ObjCObjectType.
	 *
	 * If the type is not an ObjC object, an invalid type is returned.
	 */
	Type_getObjCObjectBaseType :: proc(T: CXType) -> CXType --- 
	/**
	 * Retrieve the number of protocol references associated with an ObjC object/id.
	 *
	 * If the type is not an ObjC object, 0 is returned.
	 */
	Type_getNumObjCProtocolRefs :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Retrieve the decl for a protocol reference for an ObjC object/id.
	 *
	 * If the type is not an ObjC object or there are not enough protocol
	 * references, an invalid cursor is returned.
	 */
	Type_getObjCProtocolDecl :: proc(T: CXType, i: _c_.uint) -> CXCursor --- 
	/**
	 * Retrieve the number of type arguments associated with an ObjC object.
	 *
	 * If the type is not an ObjC object, 0 is returned.
	 */
	Type_getNumObjCTypeArgs :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Retrieve a type argument associated with an ObjC object.
	 *
	 * If the type is not an ObjC or the index is not valid,
	 * an invalid type is returned.
	 */
	Type_getObjCTypeArg :: proc(T: CXType, i: _c_.uint) -> CXType --- 
	/**
	 * Return 1 if the CXType is a variadic function type, and 0 otherwise.
	 */
	isFunctionTypeVariadic :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Retrieve the return type associated with a given cursor.
	 *
	 * This only returns a valid type if the cursor refers to a function or method.
	 */
	getCursorResultType :: proc(C: CXCursor) -> CXType --- 
	/**
	 * Retrieve the exception specification type associated with a given cursor.
	 * This is a value of type CXCursor_ExceptionSpecificationKind.
	 *
	 * This only returns a valid result if the cursor refers to a function or
	 * method.
	 */
	getCursorExceptionSpecificationType :: proc(C: CXCursor) -> _c_.int --- 
	/**
	 * Return 1 if the CXType is a POD (plain old data) type, and 0
	 *  otherwise.
	 */
	isPODType :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Return the element type of an array, complex, or vector type.
	 *
	 * If a type is passed in that is not an array, complex, or vector type,
	 * an invalid type is returned.
	 */
	getElementType :: proc(T: CXType) -> CXType --- 
	/**
	 * Return the number of elements of an array or vector type.
	 *
	 * If a type is passed in that is not an array or vector type,
	 * -1 is returned.
	 */
	getNumElements :: proc(T: CXType) -> _c_.longlong --- 
	/**
	 * Return the element type of an array type.
	 *
	 * If a non-array type is passed in, an invalid type is returned.
	 */
	getArrayElementType :: proc(T: CXType) -> CXType --- 
	/**
	 * Return the array size of a constant array.
	 *
	 * If a non-array type is passed in, -1 is returned.
	 */
	getArraySize :: proc(T: CXType) -> _c_.longlong --- 
	/**
	 * Retrieve the type named by the qualified-id.
	 *
	 * If a non-elaborated type is passed in, an invalid type is returned.
	 */
	Type_getNamedType :: proc(T: CXType) -> CXType --- 
	/**
	 * Determine if a typedef is 'transparent' tag.
	 *
	 * A typedef is considered 'transparent' if it shares a name and spelling
	 * location with its underlying tag type, as is the case with the NS_ENUM macro.
	 *
	 * \returns non-zero if transparent and zero otherwise.
	 */
	Type_isTransparentTagTypedef :: proc(T: CXType) -> _c_.uint --- 
	/**
	 * Retrieve the nullability kind of a pointer type.
	 */
	Type_getNullability :: proc(T: CXType) -> CXTypeNullabilityKind --- 
	/**
	 * Return the alignment of a type in bytes as per C++[expr.alignof]
	 *   standard.
	 *
	 * If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
	 * If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
	 *   is returned.
	 * If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
	 *   returned.
	 * If the type declaration is not a constant size type,
	 *   CXTypeLayoutError_NotConstantSize is returned.
	 */
	Type_getAlignOf :: proc(T: CXType) -> _c_.longlong --- 
	/**
	 * Return the class type of an member pointer type.
	 *
	 * If a non-member-pointer type is passed in, an invalid type is returned.
	 */
	Type_getClassType :: proc(T: CXType) -> CXType --- 
	/**
	 * Return the size of a type in bytes as per C++[expr.sizeof] standard.
	 *
	 * If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
	 * If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
	 *   is returned.
	 * If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
	 *   returned.
	 */
	Type_getSizeOf :: proc(T: CXType) -> _c_.longlong --- 
	/**
	 * Return the offset of a field named S in a record of type T in bits
	 *   as it would be returned by __offsetof__ as per C++11[18.2p4]
	 *
	 * If the cursor is not a record field declaration, CXTypeLayoutError_Invalid
	 *   is returned.
	 * If the field's type declaration is an incomplete type,
	 *   CXTypeLayoutError_Incomplete is returned.
	 * If the field's type declaration is a dependent type,
	 *   CXTypeLayoutError_Dependent is returned.
	 * If the field's name S is not found,
	 *   CXTypeLayoutError_InvalidFieldName is returned.
	 */
	Type_getOffsetOf :: proc(T: CXType, S: cstring) -> _c_.longlong --- 
	/**
	 * Return the type that was modified by this attributed type.
	 *
	 * If the type is not an attributed type, an invalid type is returned.
	 */
	Type_getModifiedType :: proc(T: CXType) -> CXType --- 
	/**
	 * Gets the type contained by this atomic type.
	 *
	 * If a non-atomic type is passed in, an invalid type is returned.
	 */
	Type_getValueType :: proc(CT: CXType) -> CXType --- 
	/**
	 * Return the offset of the field represented by the Cursor.
	 *
	 * If the cursor is not a field declaration, -1 is returned.
	 * If the cursor semantic parent is not a record field declaration,
	 *   CXTypeLayoutError_Invalid is returned.
	 * If the field's type declaration is an incomplete type,
	 *   CXTypeLayoutError_Incomplete is returned.
	 * If the field's type declaration is a dependent type,
	 *   CXTypeLayoutError_Dependent is returned.
	 * If the field's name S is not found,
	 *   CXTypeLayoutError_InvalidFieldName is returned.
	 */
	Cursor_getOffsetOfField :: proc(C: CXCursor) -> _c_.longlong --- 
	/**
	 * Determine whether the given cursor represents an anonymous
	 * tag or namespace
	 */
	Cursor_isAnonymous :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor represents an anonymous record
	 * declaration.
	 */
	Cursor_isAnonymousRecordDecl :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine whether the given cursor represents an inline namespace
	 * declaration.
	 */
	Cursor_isInlineNamespace :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Returns the number of template arguments for given template
	 * specialization, or -1 if type \c T is not a template specialization.
	 */
	Type_getNumTemplateArguments :: proc(T: CXType) -> _c_.int --- 
	/**
	 * Returns the type template argument of a template class specialization
	 * at given index.
	 *
	 * This function only returns template type arguments and does not handle
	 * template template arguments or variadic packs.
	 */
	Type_getTemplateArgumentAsType :: proc(T: CXType, i: _c_.uint) -> CXType --- 
	/**
	 * Retrieve the ref-qualifier kind of a function or method.
	 *
	 * The ref-qualifier is returned for C++ functions or methods. For other types
	 * or non-C++ declarations, CXRefQualifier_None is returned.
	 */
	Type_getCXXRefQualifier :: proc(T: CXType) -> CXRefQualifierKind --- 
	/**
	 * Returns non-zero if the cursor specifies a Record member that is a
	 *   bitfield.
	 */
	Cursor_isBitField :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Returns 1 if the base class specified by the cursor with kind
	 *   CX_CXXBaseSpecifier is virtual.
	 */
	isVirtualBase :: proc(_: CXCursor) -> _c_.uint --- 
	/**
	 * Returns the access control level for the referenced object.
	 *
	 * If the cursor refers to a C++ declaration, its access control level within
	 * its parent scope is returned. Otherwise, if the cursor refers to a base
	 * specifier or access specifier, the specifier itself is returned.
	 */
	getCXXAccessSpecifier :: proc(_: CXCursor) -> CX_CXXAccessSpecifier --- 
	/**
	 * Returns the storage class for a function or variable declaration.
	 *
	 * If the passed in Cursor is not a function or variable declaration,
	 * CX_SC_Invalid is returned else the storage class.
	 */
	Cursor_getStorageClass :: proc(_: CXCursor) -> CX_StorageClass --- 
	/**
	 * Determine the number of overloaded declarations referenced by a
	 * \c CXCursor_OverloadedDeclRef cursor.
	 *
	 * \param cursor The cursor whose overloaded declarations are being queried.
	 *
	 * \returns The number of overloaded declarations referenced by \c cursor. If it
	 * is not a \c CXCursor_OverloadedDeclRef cursor, returns 0.
	 */
	getNumOverloadedDecls :: proc(cursor: CXCursor) -> _c_.uint --- 
	/**
	 * Retrieve a cursor for one of the overloaded declarations referenced
	 * by a \c CXCursor_OverloadedDeclRef cursor.
	 *
	 * \param cursor The cursor whose overloaded declarations are being queried.
	 *
	 * \param index The zero-based index into the set of overloaded declarations in
	 * the cursor.
	 *
	 * \returns A cursor representing the declaration referenced by the given
	 * \c cursor at the specified \c index. If the cursor does not have an
	 * associated set of overloaded declarations, or if the index is out of bounds,
	 * returns \c clang_getNullCursor();
	 */
	getOverloadedDecl :: proc(cursor: CXCursor, index: _c_.uint) -> CXCursor --- 
	/**
	 * For cursors representing an iboutletcollection attribute,
	 *  this function returns the collection element type.
	 *
	 */
	getIBOutletCollectionType :: proc(_: CXCursor) -> CXType --- 
	/**
	 * Visit the children of a particular cursor.
	 *
	 * This function visits all the direct children of the given cursor,
	 * invoking the given \p visitor function with the cursors of each
	 * visited child. The traversal may be recursive, if the visitor returns
	 * \c CXChildVisit_Recurse. The traversal may also be ended prematurely, if
	 * the visitor returns \c CXChildVisit_Break.
	 *
	 * \param parent the cursor whose child may be visited. All kinds of
	 * cursors can be visited, including invalid cursors (which, by
	 * definition, have no children).
	 *
	 * \param visitor the visitor function that will be invoked for each
	 * child of \p parent.
	 *
	 * \param client_data pointer data supplied by the client, which will
	 * be passed to the visitor each time it is invoked.
	 *
	 * \returns a non-zero value if the traversal was terminated
	 * prematurely by the visitor returning \c CXChildVisit_Break.
	 */
	visitChildren :: proc(parent: CXCursor, visitor: CXCursorVisitor, client_data: CXClientData) -> _c_.uint --- 
	/**
	 * Retrieve a Unified Symbol Resolution (USR) for the entity referenced
	 * by the given cursor.
	 *
	 * A Unified Symbol Resolution (USR) is a string that identifies a particular
	 * entity (function, class, variable, etc.) within a program. USRs can be
	 * compared across translation units to determine, e.g., when references in
	 * one translation refer to an entity defined in another translation unit.
	 */
	getCursorUSR :: proc(_: CXCursor) -> CXString --- 
	/**
	 * Construct a USR for a specified Objective-C class.
	 */
	constructUSR_ObjCClass :: proc(class_name: cstring) -> CXString --- 
	/**
	 * Construct a USR for a specified Objective-C category.
	 */
	constructUSR_ObjCCategory :: proc(class_name: cstring, category_name: cstring) -> CXString --- 
	/**
	 * Construct a USR for a specified Objective-C protocol.
	 */
	constructUSR_ObjCProtocol :: proc(protocol_name: cstring) -> CXString --- 
	/**
	 * Construct a USR for a specified Objective-C instance variable and
	 *   the USR for its containing class.
	 */
	constructUSR_ObjCIvar :: proc(name: cstring, classUSR: CXString) -> CXString --- 
	/**
	 * Construct a USR for a specified Objective-C method and
	 *   the USR for its containing class.
	 */
	constructUSR_ObjCMethod :: proc(name: cstring, isInstanceMethod: _c_.uint, classUSR: CXString) -> CXString --- 
	/**
	 * Construct a USR for a specified Objective-C property and the USR
	 *  for its containing class.
	 */
	constructUSR_ObjCProperty :: proc(property: cstring, classUSR: CXString) -> CXString --- 
	/**
	 * Retrieve a name for the entity referenced by this cursor.
	 */
	getCursorSpelling :: proc(_: CXCursor) -> CXString --- 
	/**
	 * Retrieve a range for a piece that forms the cursors spelling name.
	 * Most of the times there is only one range for the complete spelling but for
	 * Objective-C methods and Objective-C message expressions, there are multiple
	 * pieces for each selector identifier.
	 *
	 * \param pieceIndex the index of the spelling name piece. If this is greater
	 * than the actual number of pieces, it will return a NULL (invalid) range.
	 *
	 * \param options Reserved.
	 */
	Cursor_getSpellingNameRange :: proc(_: CXCursor, pieceIndex: _c_.uint, options: _c_.uint) -> CXSourceRange --- 
	/**
	 * Get a property value for the given printing policy.
	 */
	PrintingPolicy_getProperty :: proc(Policy: CXPrintingPolicy, Property: CXPrintingPolicyProperty) -> _c_.uint --- 
	/**
	 * Set a property value for the given printing policy.
	 */
	PrintingPolicy_setProperty :: proc(Policy: CXPrintingPolicy, Property: CXPrintingPolicyProperty, Value: _c_.uint) --- 
	/**
	 * Retrieve the default policy for the cursor.
	 *
	 * The policy should be released after use with \c
	 * clang_PrintingPolicy_dispose.
	 */
	getCursorPrintingPolicy :: proc(_: CXCursor) -> CXPrintingPolicy --- 
	/**
	 * Release a printing policy.
	 */
	PrintingPolicy_dispose :: proc(Policy: CXPrintingPolicy) --- 
	/**
	 * Pretty print declarations.
	 *
	 * \param Cursor The cursor representing a declaration.
	 *
	 * \param Policy The policy to control the entities being printed. If
	 * NULL, a default policy is used.
	 *
	 * \returns The pretty printed declaration or the empty string for
	 * other cursors.
	 */
	getCursorPrettyPrinted :: proc(Cursor: CXCursor, Policy: CXPrintingPolicy) -> CXString --- 
	/**
	 * Retrieve the display name for the entity referenced by this cursor.
	 *
	 * The display name contains extra information that helps identify the cursor,
	 * such as the parameters of a function or template or the arguments of a
	 * class template specialization.
	 */
	getCursorDisplayName :: proc(_: CXCursor) -> CXString --- 
	/** For a cursor that is a reference, retrieve a cursor representing the
	 * entity that it references.
	 *
	 * Reference cursors refer to other entities in the AST. For example, an
	 * Objective-C superclass reference cursor refers to an Objective-C class.
	 * This function produces the cursor for the Objective-C class from the
	 * cursor for the superclass reference. If the input cursor is a declaration or
	 * definition, it returns that declaration or definition unchanged.
	 * Otherwise, returns the NULL cursor.
	 */
	getCursorReferenced :: proc(_: CXCursor) -> CXCursor --- 
	/**
	 *  For a cursor that is either a reference to or a declaration
	 *  of some entity, retrieve a cursor that describes the definition of
	 *  that entity.
	 *
	 *  Some entities can be declared multiple times within a translation
	 *  unit, but only one of those declarations can also be a
	 *  definition. For example, given:
	 *
	 *  \code
	 *  int f(int, int);
	 *  int g(int x, int y) { return f(x, y); }
	 *  int f(int a, int b) { return a + b; }
	 *  int f(int, int);
	 *  \endcode
	 *
	 *  there are three declarations of the function "f", but only the
	 *  second one is a definition. The clang_getCursorDefinition()
	 *  function will take any cursor pointing to a declaration of "f"
	 *  (the first or fourth lines of the example) or a cursor referenced
	 *  that uses "f" (the call to "f' inside "g") and will return a
	 *  declaration cursor pointing to the definition (the second "f"
	 *  declaration).
	 *
	 *  If given a cursor for which there is no corresponding definition,
	 *  e.g., because there is no definition of that entity within this
	 *  translation unit, returns a NULL cursor.
	 */
	getCursorDefinition :: proc(_: CXCursor) -> CXCursor --- 
	/**
	 * Determine whether the declaration pointed to by this cursor
	 * is also a definition of that entity.
	 */
	isCursorDefinition :: proc(_: CXCursor) -> _c_.uint --- 
	/**
	 * Retrieve the canonical cursor corresponding to the given cursor.
	 *
	 * In the C family of languages, many kinds of entities can be declared several
	 * times within a single translation unit. For example, a structure type can
	 * be forward-declared (possibly multiple times) and later defined:
	 *
	 * \code
	 * struct X;
	 * struct X;
	 * struct X {
	 *   int member;
	 * };
	 * \endcode
	 *
	 * The declarations and the definition of \c X are represented by three
	 * different cursors, all of which are declarations of the same underlying
	 * entity. One of these cursor is considered the "canonical" cursor, which
	 * is effectively the representative for the underlying entity. One can
	 * determine if two cursors are declarations of the same underlying entity by
	 * comparing their canonical cursors.
	 *
	 * \returns The canonical cursor for the entity referred to by the given cursor.
	 */
	getCanonicalCursor :: proc(_: CXCursor) -> CXCursor --- 
	/**
	 * If the cursor points to a selector identifier in an Objective-C
	 * method or message expression, this returns the selector index.
	 *
	 * After getting a cursor with #clang_getCursor, this can be called to
	 * determine if the location points to a selector identifier.
	 *
	 * \returns The selector index if the cursor is an Objective-C method or message
	 * expression and the cursor is pointing to a selector identifier, or -1
	 * otherwise.
	 */
	Cursor_getObjCSelectorIndex :: proc(_: CXCursor) -> _c_.int --- 
	/**
	 * Given a cursor pointing to a C++ method call or an Objective-C
	 * message, returns non-zero if the method/message is "dynamic", meaning:
	 *
	 * For a C++ method: the call is virtual.
	 * For an Objective-C message: the receiver is an object instance, not 'super'
	 * or a specific class.
	 *
	 * If the method/message is "static" or the cursor does not point to a
	 * method/message, it will return zero.
	 */
	Cursor_isDynamicCall :: proc(C: CXCursor) -> _c_.int --- 
	/**
	 * Given a cursor pointing to an Objective-C message or property
	 * reference, or C++ method call, returns the CXType of the receiver.
	 */
	Cursor_getReceiverType :: proc(C: CXCursor) -> CXType --- 
	/**
	 * Given a cursor that represents a property declaration, return the
	 * associated property attributes. The bits are formed from
	 * \c CXObjCPropertyAttrKind.
	 *
	 * \param reserved Reserved for future use, pass 0.
	 */
	Cursor_getObjCPropertyAttributes :: proc(C: CXCursor, reserved: _c_.uint) -> _c_.uint --- 
	/**
	 * Given a cursor that represents a property declaration, return the
	 * name of the method that implements the getter.
	 */
	Cursor_getObjCPropertyGetterName :: proc(C: CXCursor) -> CXString --- 
	/**
	 * Given a cursor that represents a property declaration, return the
	 * name of the method that implements the setter, if any.
	 */
	Cursor_getObjCPropertySetterName :: proc(C: CXCursor) -> CXString --- 
	/**
	 * Given a cursor that represents an Objective-C method or parameter
	 * declaration, return the associated Objective-C qualifiers for the return
	 * type or the parameter respectively. The bits are formed from
	 * CXObjCDeclQualifierKind.
	 */
	Cursor_getObjCDeclQualifiers :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Given a cursor that represents an Objective-C method or property
	 * declaration, return non-zero if the declaration was affected by "\@optional".
	 * Returns zero if the cursor is not such a declaration or it is "\@required".
	 */
	Cursor_isObjCOptional :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Returns non-zero if the given cursor is a variadic function or method.
	 */
	Cursor_isVariadic :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Returns non-zero if the given cursor points to a symbol marked with
	 * external_source_symbol attribute.
	 *
	 * \param language If non-NULL, and the attribute is present, will be set to
	 * the 'language' string from the attribute.
	 *
	 * \param definedIn If non-NULL, and the attribute is present, will be set to
	 * the 'definedIn' string from the attribute.
	 *
	 * \param isGenerated If non-NULL, and the attribute is present, will be set to
	 * non-zero if the 'generated_declaration' is set in the attribute.
	 */
	Cursor_isExternalSymbol :: proc(C: CXCursor, language: ^CXString, definedIn: ^CXString, isGenerated: ^_c_.uint) -> _c_.uint --- 
	/**
	 * Given a cursor that represents a declaration, return the associated
	 * comment's source range.  The range may include multiple consecutive comments
	 * with whitespace in between.
	 */
	Cursor_getCommentRange :: proc(C: CXCursor) -> CXSourceRange --- 
	/**
	 * Given a cursor that represents a declaration, return the associated
	 * comment text, including comment markers.
	 */
	Cursor_getRawCommentText :: proc(C: CXCursor) -> CXString --- 
	/**
	 * Given a cursor that represents a documentable entity (e.g.,
	 * declaration), return the associated \paragraph; otherwise return the
	 * first paragraph.
	 */
	Cursor_getBriefCommentText :: proc(C: CXCursor) -> CXString --- 
	/**
	 * Retrieve the CXString representing the mangled name of the cursor.
	 */
	Cursor_getMangling :: proc(_: CXCursor) -> CXString --- 
	/**
	 * Retrieve the CXStrings representing the mangled symbols of the C++
	 * constructor or destructor at the cursor.
	 */
	Cursor_getCXXManglings :: proc(_: CXCursor) -> ^CXStringSet --- 
	/**
	 * Retrieve the CXStrings representing the mangled symbols of the ObjC
	 * class interface or implementation at the cursor.
	 */
	Cursor_getObjCManglings :: proc(_: CXCursor) -> ^CXStringSet --- 
	/**
	 * Given a CXCursor_ModuleImportDecl cursor, return the associated module.
	 */
	Cursor_getModule :: proc(C: CXCursor) -> CXModule --- 
	/**
	 * Given a CXFile header file, return the module that contains it, if one
	 * exists.
	 */
	getModuleForFile :: proc(_: CXTranslationUnit, _: CXFile) -> CXModule --- 
	/**
	 * \param Module a module object.
	 *
	 * \returns the module file where the provided module object came from.
	 */
	Module_getASTFile :: proc(Module: CXModule) -> CXFile --- 
	/**
	 * \param Module a module object.
	 *
	 * \returns the parent of a sub-module or NULL if the given module is top-level,
	 * e.g. for 'std.vector' it will return the 'std' module.
	 */
	Module_getParent :: proc(Module: CXModule) -> CXModule --- 
	/**
	 * \param Module a module object.
	 *
	 * \returns the name of the module, e.g. for the 'std.vector' sub-module it
	 * will return "vector".
	 */
	Module_getName :: proc(Module: CXModule) -> CXString --- 
	/**
	 * \param Module a module object.
	 *
	 * \returns the full name of the module, e.g. "std.vector".
	 */
	Module_getFullName :: proc(Module: CXModule) -> CXString --- 
	/**
	 * \param Module a module object.
	 *
	 * \returns non-zero if the module is a system one.
	 */
	Module_isSystem :: proc(Module: CXModule) -> _c_.int --- 
	/**
	 * \param Module a module object.
	 *
	 * \returns the number of top level headers associated with this module.
	 */
	Module_getNumTopLevelHeaders :: proc(_: CXTranslationUnit, Module: CXModule) -> _c_.uint --- 
	/**
	 * \param Module a module object.
	 *
	 * \param Index top level header index (zero-based).
	 *
	 * \returns the specified top level header associated with the module.
	 */
	Module_getTopLevelHeader :: proc(_: CXTranslationUnit, Module: CXModule, Index: _c_.uint) -> CXFile --- 
	/**
	 * Determine if a C++ constructor is a converting constructor.
	 */
	CXXConstructor_isConvertingConstructor :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ constructor is a copy constructor.
	 */
	CXXConstructor_isCopyConstructor :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ constructor is the default constructor.
	 */
	CXXConstructor_isDefaultConstructor :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ constructor is a move constructor.
	 */
	CXXConstructor_isMoveConstructor :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ field is declared 'mutable'.
	 */
	CXXField_isMutable :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ method is declared '= default'.
	 */
	CXXMethod_isDefaulted :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ member function or member function template is
	 * pure virtual.
	 */
	CXXMethod_isPureVirtual :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ member function or member function template is
	 * declared 'static'.
	 */
	CXXMethod_isStatic :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ member function or member function template is
	 * explicitly declared 'virtual' or if it overrides a virtual method from
	 * one of the base classes.
	 */
	CXXMethod_isVirtual :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ record is abstract, i.e. whether a class or struct
	 * has a pure virtual member function.
	 */
	CXXRecord_isAbstract :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if an enum declaration refers to a scoped enum.
	 */
	EnumDecl_isScoped :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Determine if a C++ member function or member function template is
	 * declared 'const'.
	 */
	CXXMethod_isConst :: proc(C: CXCursor) -> _c_.uint --- 
	/**
	 * Given a cursor that represents a template, determine
	 * the cursor kind of the specializations would be generated by instantiating
	 * the template.
	 *
	 * This routine can be used to determine what flavor of function template,
	 * class template, or class template partial specialization is stored in the
	 * cursor. For example, it can describe whether a class template cursor is
	 * declared with "struct", "class" or "union".
	 *
	 * \param C The cursor to query. This cursor should represent a template
	 * declaration.
	 *
	 * \returns The cursor kind of the specializations that would be generated
	 * by instantiating the template \p C. If \p C is not a template, returns
	 * \c CXCursor_NoDeclFound.
	 */
	getTemplateCursorKind :: proc(C: CXCursor) -> CXCursorKind --- 
	/**
	 * Given a cursor that may represent a specialization or instantiation
	 * of a template, retrieve the cursor that represents the template that it
	 * specializes or from which it was instantiated.
	 *
	 * This routine determines the template involved both for explicit
	 * specializations of templates and for implicit instantiations of the template,
	 * both of which are referred to as "specializations". For a class template
	 * specialization (e.g., \c std::vector<bool>), this routine will return
	 * either the primary template (\c std::vector) or, if the specialization was
	 * instantiated from a class template partial specialization, the class template
	 * partial specialization. For a class template partial specialization and a
	 * function template specialization (including instantiations), this
	 * this routine will return the specialized template.
	 *
	 * For members of a class template (e.g., member functions, member classes, or
	 * static data members), returns the specialized or instantiated member.
	 * Although not strictly "templates" in the C++ language, members of class
	 * templates have the same notions of specializations and instantiations that
	 * templates do, so this routine treats them similarly.
	 *
	 * \param C A cursor that may be a specialization of a template or a member
	 * of a template.
	 *
	 * \returns If the given cursor is a specialization or instantiation of a
	 * template or a member thereof, the template or member that it specializes or
	 * from which it was instantiated. Otherwise, returns a NULL cursor.
	 */
	getSpecializedCursorTemplate :: proc(C: CXCursor) -> CXCursor --- 
	/**
	 * Given a cursor that references something else, return the source range
	 * covering that reference.
	 *
	 * \param C A cursor pointing to a member reference, a declaration reference, or
	 * an operator call.
	 * \param NameFlags A bitset with three independent flags:
	 * CXNameRange_WantQualifier, CXNameRange_WantTemplateArgs, and
	 * CXNameRange_WantSinglePiece.
	 * \param PieceIndex For contiguous names or when passing the flag
	 * CXNameRange_WantSinglePiece, only one piece with index 0 is
	 * available. When the CXNameRange_WantSinglePiece flag is not passed for a
	 * non-contiguous names, this index can be used to retrieve the individual
	 * pieces of the name. See also CXNameRange_WantSinglePiece.
	 *
	 * \returns The piece of the name pointed to by the given cursor. If there is no
	 * name, or if the PieceIndex is out-of-range, a null-cursor will be returned.
	 */
	getCursorReferenceNameRange :: proc(C: CXCursor, NameFlags: _c_.uint, PieceIndex: _c_.uint) -> CXSourceRange --- 
	/**
	 * Get the raw lexical token starting with the given location.
	 *
	 * \param TU the translation unit whose text is being tokenized.
	 *
	 * \param Location the source location with which the token starts.
	 *
	 * \returns The token starting with the given location or NULL if no such token
	 * exist. The returned pointer must be freed with clang_disposeTokens before the
	 * translation unit is destroyed.
	 */
	getToken :: proc(TU: CXTranslationUnit, Location: CXSourceLocation) -> ^CXToken --- 
	/**
	 * Determine the kind of the given token.
	 */
	getTokenKind :: proc(_: CXToken) -> CXTokenKind --- 
	/**
	 * Determine the spelling of the given token.
	 *
	 * The spelling of a token is the textual representation of that token, e.g.,
	 * the text of an identifier or keyword.
	 */
	getTokenSpelling :: proc(_: CXTranslationUnit, _: CXToken) -> CXString --- 
	/**
	 * Retrieve the source location of the given token.
	 */
	getTokenLocation :: proc(_: CXTranslationUnit, _: CXToken) -> CXSourceLocation --- 
	/**
	 * Retrieve a source range that covers the given token.
	 */
	getTokenExtent :: proc(_: CXTranslationUnit, _: CXToken) -> CXSourceRange --- 
	/**
	 * Tokenize the source code described by the given range into raw
	 * lexical tokens.
	 *
	 * \param TU the translation unit whose text is being tokenized.
	 *
	 * \param Range the source range in which text should be tokenized. All of the
	 * tokens produced by tokenization will fall within this source range,
	 *
	 * \param Tokens this pointer will be set to point to the array of tokens
	 * that occur within the given source range. The returned pointer must be
	 * freed with clang_disposeTokens() before the translation unit is destroyed.
	 *
	 * \param NumTokens will be set to the number of tokens in the \c *Tokens
	 * array.
	 *
	 */
	tokenize :: proc(TU: CXTranslationUnit, Range: CXSourceRange, Tokens: ^^CXToken, NumTokens: ^_c_.uint) --- 
	/**
	 * Annotate the given set of tokens by providing cursors for each token
	 * that can be mapped to a specific entity within the abstract syntax tree.
	 *
	 * This token-annotation routine is equivalent to invoking
	 * clang_getCursor() for the source locations of each of the
	 * tokens. The cursors provided are filtered, so that only those
	 * cursors that have a direct correspondence to the token are
	 * accepted. For example, given a function call \c f(x),
	 * clang_getCursor() would provide the following cursors:
	 *
	 *   * when the cursor is over the 'f', a DeclRefExpr cursor referring to 'f'.
	 *   * when the cursor is over the '(' or the ')', a CallExpr referring to 'f'.
	 *   * when the cursor is over the 'x', a DeclRefExpr cursor referring to 'x'.
	 *
	 * Only the first and last of these cursors will occur within the
	 * annotate, since the tokens "f" and "x' directly refer to a function
	 * and a variable, respectively, but the parentheses are just a small
	 * part of the full syntax of the function call expression, which is
	 * not provided as an annotation.
	 *
	 * \param TU the translation unit that owns the given tokens.
	 *
	 * \param Tokens the set of tokens to annotate.
	 *
	 * \param NumTokens the number of tokens in \p Tokens.
	 *
	 * \param Cursors an array of \p NumTokens cursors, whose contents will be
	 * replaced with the cursors corresponding to each token.
	 */
	annotateTokens :: proc(TU: CXTranslationUnit, Tokens: ^CXToken, NumTokens: _c_.uint, Cursors: ^CXCursor) --- 
	/**
	 * Free the given set of tokens.
	 */
	disposeTokens :: proc(TU: CXTranslationUnit, Tokens: ^CXToken, NumTokens: _c_.uint) --- 
	/* for debug/testing */
	getCursorKindSpelling :: proc(Kind: CXCursorKind) -> CXString --- 
	getDefinitionSpellingAndExtent :: proc(_: CXCursor, startBuf: ^cstring, endBuf: ^cstring, startLine: ^_c_.uint, startColumn: ^_c_.uint, endLine: ^_c_.uint, endColumn: ^_c_.uint) --- 
	enableStackTraces :: proc() --- 
	executeOnThread :: proc(fn: proc(rawptr) , user_data: rawptr, stack_size: _c_.uint) --- 
	/**
	 * Determine the kind of a particular chunk within a completion string.
	 *
	 * \param completion_string the completion string to query.
	 *
	 * \param chunk_number the 0-based index of the chunk in the completion string.
	 *
	 * \returns the kind of the chunk at the index \c chunk_number.
	 */
	getCompletionChunkKind :: proc(completion_string: CXCompletionString, chunk_number: _c_.uint) -> CXCompletionChunkKind --- 
	/**
	 * Retrieve the text associated with a particular chunk within a
	 * completion string.
	 *
	 * \param completion_string the completion string to query.
	 *
	 * \param chunk_number the 0-based index of the chunk in the completion string.
	 *
	 * \returns the text associated with the chunk at index \c chunk_number.
	 */
	getCompletionChunkText :: proc(completion_string: CXCompletionString, chunk_number: _c_.uint) -> CXString --- 
	/**
	 * Retrieve the completion string associated with a particular chunk
	 * within a completion string.
	 *
	 * \param completion_string the completion string to query.
	 *
	 * \param chunk_number the 0-based index of the chunk in the completion string.
	 *
	 * \returns the completion string associated with the chunk at index
	 * \c chunk_number.
	 */
	getCompletionChunkCompletionString :: proc(completion_string: CXCompletionString, chunk_number: _c_.uint) -> CXCompletionString --- 
	/**
	 * Retrieve the number of chunks in the given code-completion string.
	 */
	getNumCompletionChunks :: proc(completion_string: CXCompletionString) -> _c_.uint --- 
	/**
	 * Determine the priority of this code completion.
	 *
	 * The priority of a code completion indicates how likely it is that this
	 * particular completion is the completion that the user will select. The
	 * priority is selected by various internal heuristics.
	 *
	 * \param completion_string The completion string to query.
	 *
	 * \returns The priority of this completion string. Smaller values indicate
	 * higher-priority (more likely) completions.
	 */
	getCompletionPriority :: proc(completion_string: CXCompletionString) -> _c_.uint --- 
	/**
	 * Determine the availability of the entity that this code-completion
	 * string refers to.
	 *
	 * \param completion_string The completion string to query.
	 *
	 * \returns The availability of the completion string.
	 */
	getCompletionAvailability :: proc(completion_string: CXCompletionString) -> CXAvailabilityKind --- 
	/**
	 * Retrieve the number of annotations associated with the given
	 * completion string.
	 *
	 * \param completion_string the completion string to query.
	 *
	 * \returns the number of annotations associated with the given completion
	 * string.
	 */
	getCompletionNumAnnotations :: proc(completion_string: CXCompletionString) -> _c_.uint --- 
	/**
	 * Retrieve the annotation associated with the given completion string.
	 *
	 * \param completion_string the completion string to query.
	 *
	 * \param annotation_number the 0-based index of the annotation of the
	 * completion string.
	 *
	 * \returns annotation string associated with the completion at index
	 * \c annotation_number, or a NULL string if that annotation is not available.
	 */
	getCompletionAnnotation :: proc(completion_string: CXCompletionString, annotation_number: _c_.uint) -> CXString --- 
	/**
	 * Retrieve the parent context of the given completion string.
	 *
	 * The parent context of a completion string is the semantic parent of
	 * the declaration (if any) that the code completion represents. For example,
	 * a code completion for an Objective-C method would have the method's class
	 * or protocol as its context.
	 *
	 * \param completion_string The code completion string whose parent is
	 * being queried.
	 *
	 * \param kind DEPRECATED: always set to CXCursor_NotImplemented if non-NULL.
	 *
	 * \returns The name of the completion parent, e.g., "NSObject" if
	 * the completion string represents a method in the NSObject class.
	 */
	getCompletionParent :: proc(completion_string: CXCompletionString, kind: ^CXCursorKind) -> CXString --- 
	/**
	 * Retrieve the brief documentation comment attached to the declaration
	 * that corresponds to the given completion string.
	 */
	getCompletionBriefComment :: proc(completion_string: CXCompletionString) -> CXString --- 
	/**
	 * Retrieve a completion string for an arbitrary declaration or macro
	 * definition cursor.
	 *
	 * \param cursor The cursor to query.
	 *
	 * \returns A non-context-sensitive completion string for declaration and macro
	 * definition cursors, or NULL for other kinds of cursors.
	 */
	getCursorCompletionString :: proc(cursor: CXCursor) -> CXCompletionString --- 
	/**
	 * Retrieve the number of fix-its for the given completion index.
	 *
	 * Calling this makes sense only if CXCodeComplete_IncludeCompletionsWithFixIts
	 * option was set.
	 *
	 * \param results The structure keeping all completion results
	 *
	 * \param completion_index The index of the completion
	 *
	 * \return The number of fix-its which must be applied before the completion at
	 * completion_index can be applied
	 */
	getCompletionNumFixIts :: proc(results: ^CXCodeCompleteResults, completion_index: _c_.uint) -> _c_.uint --- 
	/**
	 * Fix-its that *must* be applied before inserting the text for the
	 * corresponding completion.
	 *
	 * By default, clang_codeCompleteAt() only returns completions with empty
	 * fix-its. Extra completions with non-empty fix-its should be explicitly
	 * requested by setting CXCodeComplete_IncludeCompletionsWithFixIts.
	 *
	 * For the clients to be able to compute position of the cursor after applying
	 * fix-its, the following conditions are guaranteed to hold for
	 * replacement_range of the stored fix-its:
	 *  - Ranges in the fix-its are guaranteed to never contain the completion
	 *  point (or identifier under completion point, if any) inside them, except
	 *  at the start or at the end of the range.
	 *  - If a fix-it range starts or ends with completion point (or starts or
	 *  ends after the identifier under completion point), it will contain at
	 *  least one character. It allows to unambiguously recompute completion
	 *  point after applying the fix-it.
	 *
	 * The intuition is that provided fix-its change code around the identifier we
	 * complete, but are not allowed to touch the identifier itself or the
	 * completion point. One example of completions with corrections are the ones
	 * replacing '.' with '->' and vice versa:
	 *
	 * std::unique_ptr<std::vector<int>> vec_ptr;
	 * In 'vec_ptr.^', one of the completions is 'push_back', it requires
	 * replacing '.' with '->'.
	 * In 'vec_ptr->^', one of the completions is 'release', it requires
	 * replacing '->' with '.'.
	 *
	 * \param results The structure keeping all completion results
	 *
	 * \param completion_index The index of the completion
	 *
	 * \param fixit_index The index of the fix-it for the completion at
	 * completion_index
	 *
	 * \param replacement_range The fix-it range that must be replaced before the
	 * completion at completion_index can be applied
	 *
	 * \returns The fix-it string that must replace the code at replacement_range
	 * before the completion at completion_index can be applied
	 */
	getCompletionFixIt :: proc(results: ^CXCodeCompleteResults, completion_index: _c_.uint, fixit_index: _c_.uint, replacement_range: ^CXSourceRange) -> CXString --- 
	/**
	 * Returns a default set of code-completion options that can be
	 * passed to\c clang_codeCompleteAt().
	 */
	defaultCodeCompleteOptions :: proc() -> _c_.uint --- 
	/**
	 * Perform code completion at a given location in a translation unit.
	 *
	 * This function performs code completion at a particular file, line, and
	 * column within source code, providing results that suggest potential
	 * code snippets based on the context of the completion. The basic model
	 * for code completion is that Clang will parse a complete source file,
	 * performing syntax checking up to the location where code-completion has
	 * been requested. At that point, a special code-completion token is passed
	 * to the parser, which recognizes this token and determines, based on the
	 * current location in the C/Objective-C/C++ grammar and the state of
	 * semantic analysis, what completions to provide. These completions are
	 * returned via a new \c CXCodeCompleteResults structure.
	 *
	 * Code completion itself is meant to be triggered by the client when the
	 * user types punctuation characters or whitespace, at which point the
	 * code-completion location will coincide with the cursor. For example, if \c p
	 * is a pointer, code-completion might be triggered after the "-" and then
	 * after the ">" in \c p->. When the code-completion location is after the ">",
	 * the completion results will provide, e.g., the members of the struct that
	 * "p" points to. The client is responsible for placing the cursor at the
	 * beginning of the token currently being typed, then filtering the results
	 * based on the contents of the token. For example, when code-completing for
	 * the expression \c p->get, the client should provide the location just after
	 * the ">" (e.g., pointing at the "g") to this code-completion hook. Then, the
	 * client can filter the results based on the current token text ("get"), only
	 * showing those results that start with "get". The intent of this interface
	 * is to separate the relatively high-latency acquisition of code-completion
	 * results from the filtering of results on a per-character basis, which must
	 * have a lower latency.
	 *
	 * \param TU The translation unit in which code-completion should
	 * occur. The source files for this translation unit need not be
	 * completely up-to-date (and the contents of those source files may
	 * be overridden via \p unsaved_files). Cursors referring into the
	 * translation unit may be invalidated by this invocation.
	 *
	 * \param complete_filename The name of the source file where code
	 * completion should be performed. This filename may be any file
	 * included in the translation unit.
	 *
	 * \param complete_line The line at which code-completion should occur.
	 *
	 * \param complete_column The column at which code-completion should occur.
	 * Note that the column should point just after the syntactic construct that
	 * initiated code completion, and not in the middle of a lexical token.
	 *
	 * \param unsaved_files the Files that have not yet been saved to disk
	 * but may be required for parsing or code completion, including the
	 * contents of those files.  The contents and name of these files (as
	 * specified by CXUnsavedFile) are copied when necessary, so the
	 * client only needs to guarantee their validity until the call to
	 * this function returns.
	 *
	 * \param num_unsaved_files The number of unsaved file entries in \p
	 * unsaved_files.
	 *
	 * \param options Extra options that control the behavior of code
	 * completion, expressed as a bitwise OR of the enumerators of the
	 * CXCodeComplete_Flags enumeration. The
	 * \c clang_defaultCodeCompleteOptions() function returns a default set
	 * of code-completion options.
	 *
	 * \returns If successful, a new \c CXCodeCompleteResults structure
	 * containing code-completion results, which should eventually be
	 * freed with \c clang_disposeCodeCompleteResults(). If code
	 * completion fails, returns NULL.
	 */
	codeCompleteAt :: proc(TU: CXTranslationUnit, complete_filename: cstring, complete_line: _c_.uint, complete_column: _c_.uint, unsaved_files: ^CXUnsavedFile, num_unsaved_files: _c_.uint, options: _c_.uint) -> ^CXCodeCompleteResults --- 
	/**
	 * Sort the code-completion results in case-insensitive alphabetical
	 * order.
	 *
	 * \param Results The set of results to sort.
	 * \param NumResults The number of results in \p Results.
	 */
	sortCodeCompletionResults :: proc(Results: ^CXCompletionResult, NumResults: _c_.uint) --- 
	/**
	 * Free the given set of code-completion results.
	 */
	disposeCodeCompleteResults :: proc(Results: ^CXCodeCompleteResults) --- 
	/**
	 * Determine the number of diagnostics produced prior to the
	 * location where code completion was performed.
	 */
	codeCompleteGetNumDiagnostics :: proc(Results: ^CXCodeCompleteResults) -> _c_.uint --- 
	/**
	 * Retrieve a diagnostic associated with the given code completion.
	 *
	 * \param Results the code completion results to query.
	 * \param Index the zero-based diagnostic number to retrieve.
	 *
	 * \returns the requested diagnostic. This diagnostic must be freed
	 * via a call to \c clang_disposeDiagnostic().
	 */
	codeCompleteGetDiagnostic :: proc(Results: ^CXCodeCompleteResults, Index: _c_.uint) -> CXDiagnostic --- 
	/**
	 * Determines what completions are appropriate for the context
	 * the given code completion.
	 *
	 * \param Results the code completion results to query
	 *
	 * \returns the kinds of completions that are appropriate for use
	 * along with the given code completion results.
	 */
	codeCompleteGetContexts :: proc(Results: ^CXCodeCompleteResults) -> _c_.ulonglong --- 
	/**
	 * Returns the cursor kind for the container for the current code
	 * completion context. The container is only guaranteed to be set for
	 * contexts where a container exists (i.e. member accesses or Objective-C
	 * message sends); if there is not a container, this function will return
	 * CXCursor_InvalidCode.
	 *
	 * \param Results the code completion results to query
	 *
	 * \param IsIncomplete on return, this value will be false if Clang has complete
	 * information about the container. If Clang does not have complete
	 * information, this value will be true.
	 *
	 * \returns the container kind, or CXCursor_InvalidCode if there is not a
	 * container
	 */
	codeCompleteGetContainerKind :: proc(Results: ^CXCodeCompleteResults, IsIncomplete: ^_c_.uint) -> CXCursorKind --- 
	/**
	 * Returns the USR for the container for the current code completion
	 * context. If there is not a container for the current context, this
	 * function will return the empty string.
	 *
	 * \param Results the code completion results to query
	 *
	 * \returns the USR for the container
	 */
	codeCompleteGetContainerUSR :: proc(Results: ^CXCodeCompleteResults) -> CXString --- 
	/**
	 * Returns the currently-entered selector for an Objective-C message
	 * send, formatted like "initWithFoo:bar:". Only guaranteed to return a
	 * non-empty string for CXCompletionContext_ObjCInstanceMessage and
	 * CXCompletionContext_ObjCClassMessage.
	 *
	 * \param Results the code completion results to query
	 *
	 * \returns the selector (or partial selector) that has been entered thus far
	 * for an Objective-C message send.
	 */
	codeCompleteGetObjCSelector :: proc(Results: ^CXCodeCompleteResults) -> CXString --- 
	/**
	 * Return a version string, suitable for showing to a user, but not
	 *        intended to be parsed (the format is not guaranteed to be stable).
	 */
	getClangVersion :: proc() -> CXString --- 
	/**
	 * Enable/disable crash recovery.
	 *
	 * \param isEnabled Flag to indicate if crash recovery is enabled.  A non-zero
	 *        value enables crash recovery, while 0 disables it.
	 */
	toggleCrashRecovery :: proc(isEnabled: _c_.uint) --- 
	/**
	 * Visit the set of preprocessor inclusions in a translation unit.
	 *   The visitor function is called with the provided data for every included
	 *   file.  This does not include headers included by the PCH file (unless one
	 *   is inspecting the inclusions in the PCH file itself).
	 */
	getInclusions :: proc(tu: CXTranslationUnit, visitor: CXInclusionVisitor, client_data: CXClientData) --- 
	/**
	 * If cursor is a statement declaration tries to evaluate the
	 * statement and if its variable, tries to evaluate its initializer,
	 * into its corresponding type.
	 * If it's an expression, tries to evaluate the expression.
	 */
	Cursor_Evaluate :: proc(C: CXCursor) -> CXEvalResult --- 
	/**
	 * Returns the kind of the evaluated result.
	 */
	EvalResult_getKind :: proc(E: CXEvalResult) -> CXEvalResultKind --- 
	/**
	 * Returns the evaluation result as integer if the
	 * kind is Int.
	 */
	EvalResult_getAsInt :: proc(E: CXEvalResult) -> _c_.int --- 
	/**
	 * Returns the evaluation result as a long long integer if the
	 * kind is Int. This prevents overflows that may happen if the result is
	 * returned with clang_EvalResult_getAsInt.
	 */
	EvalResult_getAsLongLong :: proc(E: CXEvalResult) -> _c_.longlong --- 
	/**
	 * Returns a non-zero value if the kind is Int and the evaluation
	 * result resulted in an unsigned integer.
	 */
	EvalResult_isUnsignedInt :: proc(E: CXEvalResult) -> _c_.uint --- 
	/**
	 * Returns the evaluation result as an unsigned integer if
	 * the kind is Int and clang_EvalResult_isUnsignedInt is non-zero.
	 */
	EvalResult_getAsUnsigned :: proc(E: CXEvalResult) -> _c_.ulonglong --- 
	/**
	 * Returns the evaluation result as double if the
	 * kind is double.
	 */
	EvalResult_getAsDouble :: proc(E: CXEvalResult) -> _c_.double --- 
	/**
	 * Returns the evaluation result as a constant string if the
	 * kind is other than Int or float. User must not free this pointer,
	 * instead call clang_EvalResult_dispose on the CXEvalResult returned
	 * by clang_Cursor_Evaluate.
	 */
	EvalResult_getAsStr :: proc(E: CXEvalResult) -> cstring --- 
	/**
	 * Disposes the created Eval memory.
	 */
	EvalResult_dispose :: proc(E: CXEvalResult) --- 
	/**
	 * Retrieve a remapping.
	 *
	 * \param path the path that contains metadata about remappings.
	 *
	 * \returns the requested remapping. This remapping must be freed
	 * via a call to \c clang_remap_dispose(). Can return NULL if an error occurred.
	 */
	getRemappings :: proc(path: cstring) -> CXRemapping --- 
	/**
	 * Retrieve a remapping.
	 *
	 * \param filePaths pointer to an array of file paths containing remapping info.
	 *
	 * \param numFiles number of file paths.
	 *
	 * \returns the requested remapping. This remapping must be freed
	 * via a call to \c clang_remap_dispose(). Can return NULL if an error occurred.
	 */
	getRemappingsFromFileList :: proc(filePaths: ^cstring, numFiles: _c_.uint) -> CXRemapping --- 
	/**
	 * Determine the number of remappings.
	 */
	remap_getNumFiles :: proc(_: CXRemapping) -> _c_.uint --- 
	/**
	 * Get the original and the associated filename from the remapping.
	 *
	 * \param original If non-NULL, will be set to the original filename.
	 *
	 * \param transformed If non-NULL, will be set to the filename that the original
	 * is associated with.
	 */
	remap_getFilenames :: proc(_: CXRemapping, index: _c_.uint, original: ^CXString, transformed: ^CXString) --- 
	/**
	 * Dispose the remapping.
	 */
	remap_dispose :: proc(_: CXRemapping) --- 
	/**
	 * Find references of a declaration in a specific file.
	 *
	 * \param cursor pointing to a declaration or a reference of one.
	 *
	 * \param file to search for references.
	 *
	 * \param visitor callback that will receive pairs of CXCursor/CXSourceRange for
	 * each reference found.
	 * The CXSourceRange will point inside the file; if the reference is inside
	 * a macro (and not a macro argument) the CXSourceRange will be invalid.
	 *
	 * \returns one of the CXResult enumerators.
	 */
	findReferencesInFile :: proc(cursor: CXCursor, file: CXFile, visitor: CXCursorAndRangeVisitor) -> CXResult --- 
	/**
	 * Find #import/#include directives in a specific file.
	 *
	 * \param TU translation unit containing the file to query.
	 *
	 * \param file to search for #import/#include directives.
	 *
	 * \param visitor callback that will receive pairs of CXCursor/CXSourceRange for
	 * each directive found.
	 *
	 * \returns one of the CXResult enumerators.
	 */
	findIncludesInFile :: proc(TU: CXTranslationUnit, file: CXFile, visitor: CXCursorAndRangeVisitor) -> CXResult --- 
	index_isEntityObjCContainerKind :: proc(_: CXIdxEntityKind) -> _c_.int --- 
	index_getObjCContainerDeclInfo :: proc(_: ^CXIdxDeclInfo) -> ^CXIdxObjCContainerDeclInfo --- 
	index_getObjCInterfaceDeclInfo :: proc(_: ^CXIdxDeclInfo) -> ^CXIdxObjCInterfaceDeclInfo --- 
	index_getObjCCategoryDeclInfo :: proc(_: ^CXIdxDeclInfo) -> ^CXIdxObjCCategoryDeclInfo --- 
	index_getObjCProtocolRefListInfo :: proc(_: ^CXIdxDeclInfo) -> ^CXIdxObjCProtocolRefListInfo --- 
	index_getObjCPropertyDeclInfo :: proc(_: ^CXIdxDeclInfo) -> ^CXIdxObjCPropertyDeclInfo --- 
	index_getIBOutletCollectionAttrInfo :: proc(_: ^CXIdxAttrInfo) -> ^CXIdxIBOutletCollectionAttrInfo --- 
	index_getCXXClassDeclInfo :: proc(_: ^CXIdxDeclInfo) -> ^CXIdxCXXClassDeclInfo --- 
	/**
	 * For retrieving a custom CXIdxClientContainer attached to a
	 * container.
	 */
	index_getClientContainer :: proc(_: ^CXIdxContainerInfo) -> CXIdxClientContainer --- 
	/**
	 * For setting a custom CXIdxClientContainer attached to a
	 * container.
	 */
	index_setClientContainer :: proc(_: ^CXIdxContainerInfo, _: CXIdxClientContainer) --- 
	/**
	 * For retrieving a custom CXIdxClientEntity attached to an entity.
	 */
	index_getClientEntity :: proc(_: ^CXIdxEntityInfo) -> CXIdxClientEntity --- 
	/**
	 * For setting a custom CXIdxClientEntity attached to an entity.
	 */
	index_setClientEntity :: proc(_: ^CXIdxEntityInfo, _: CXIdxClientEntity) --- 
	/**
	 * An indexing action/session, to be applied to one or multiple
	 * translation units.
	 *
	 * \param CIdx The index object with which the index action will be associated.
	 */
	IndexAction_create :: proc(CIdx: CXIndex) -> CXIndexAction --- 
	/**
	 * Destroy the given index action.
	 *
	 * The index action must not be destroyed until all of the translation units
	 * created within that index action have been destroyed.
	 */
	IndexAction_dispose :: proc(_: CXIndexAction) --- 
	/**
	 * Index the given source file and the translation unit corresponding
	 * to that file via callbacks implemented through #IndexerCallbacks.
	 *
	 * \param client_data pointer data supplied by the client, which will
	 * be passed to the invoked callbacks.
	 *
	 * \param index_callbacks Pointer to indexing callbacks that the client
	 * implements.
	 *
	 * \param index_callbacks_size Size of #IndexerCallbacks structure that gets
	 * passed in index_callbacks.
	 *
	 * \param index_options A bitmask of options that affects how indexing is
	 * performed. This should be a bitwise OR of the CXIndexOpt_XXX flags.
	 *
	 * \param[out] out_TU pointer to store a \c CXTranslationUnit that can be
	 * reused after indexing is finished. Set to \c NULL if you do not require it.
	 *
	 * \returns 0 on success or if there were errors from which the compiler could
	 * recover.  If there is a failure from which there is no recovery, returns
	 * a non-zero \c CXErrorCode.
	 *
	 * The rest of the parameters are the same as #clang_parseTranslationUnit.
	 */
	indexSourceFile :: proc(_: CXIndexAction, client_data: CXClientData, index_callbacks: ^IndexerCallbacks, index_callbacks_size: _c_.uint, index_options: _c_.uint, source_filename: cstring, command_line_args: ^cstring, num_command_line_args: _c_.int, unsaved_files: ^CXUnsavedFile, num_unsaved_files: _c_.uint, out_TU: ^CXTranslationUnit, TU_options: _c_.uint) -> _c_.int --- 
	/**
	 * Same as clang_indexSourceFile but requires a full command line
	 * for \c command_line_args including argv[0]. This is useful if the standard
	 * library paths are relative to the binary.
	 */
	indexSourceFileFullArgv :: proc(_: CXIndexAction, client_data: CXClientData, index_callbacks: ^IndexerCallbacks, index_callbacks_size: _c_.uint, index_options: _c_.uint, source_filename: cstring, command_line_args: ^cstring, num_command_line_args: _c_.int, unsaved_files: ^CXUnsavedFile, num_unsaved_files: _c_.uint, out_TU: ^CXTranslationUnit, TU_options: _c_.uint) -> _c_.int --- 
	/**
	 * Index the given translation unit via callbacks implemented through
	 * #IndexerCallbacks.
	 *
	 * The order of callback invocations is not guaranteed to be the same as
	 * when indexing a source file. The high level order will be:
	 *
	 *   -Preprocessor callbacks invocations
	 *   -Declaration/reference callbacks invocations
	 *   -Diagnostic callback invocations
	 *
	 * The parameters are the same as #clang_indexSourceFile.
	 *
	 * \returns If there is a failure from which there is no recovery, returns
	 * non-zero, otherwise returns 0.
	 */
	indexTranslationUnit :: proc(_: CXIndexAction, client_data: CXClientData, index_callbacks: ^IndexerCallbacks, index_callbacks_size: _c_.uint, index_options: _c_.uint, _: CXTranslationUnit) -> _c_.int --- 
	/**
	 * Retrieve the CXIdxFile, file, line, column, and offset represented by
	 * the given CXIdxLoc.
	 *
	 * If the location refers into a macro expansion, retrieves the
	 * location of the macro expansion and if it refers into a macro argument
	 * retrieves the location of the argument.
	 */
	indexLoc_getFileLocation :: proc(loc: CXIdxLoc, indexFile: ^CXIdxClientFile, file: ^CXFile, line: ^_c_.uint, column: ^_c_.uint, offset: ^_c_.uint) --- 
	/**
	 * Retrieve the CXSourceLocation represented by the given CXIdxLoc.
	 */
	indexLoc_getCXSourceLocation :: proc(loc: CXIdxLoc) -> CXSourceLocation --- 
	/**
	 * Visit the fields of a particular type.
	 *
	 * This function visits all the direct fields of the given cursor,
	 * invoking the given \p visitor function with the cursors of each
	 * visited field. The traversal may be ended prematurely, if
	 * the visitor returns \c CXFieldVisit_Break.
	 *
	 * \param T the record type whose field may be visited.
	 *
	 * \param visitor the visitor function that will be invoked for each
	 * field of \p T.
	 *
	 * \param client_data pointer data supplied by the client, which will
	 * be passed to the visitor each time it is invoked.
	 *
	 * \returns a non-zero value if the traversal was terminated
	 * prematurely by the visitor returning \c CXFieldVisit_Break.
	 */
	Type_visitFields :: proc(T: CXType, visitor: CXFieldVisitor, client_data: CXClientData) -> _c_.uint --- 
}

