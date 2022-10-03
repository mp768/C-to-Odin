package clang
import _c_ "core:c"

when ODIN_OS == .Windows {
	foreign import __LIB__ "libclang.lib"
} else when ODIN_OS == .Linux {
	foreign import __LIB__ "UNKNOWN"
} else when ODIN_OS == .Darwin {
	foreign import __LIB__ "UNKNOWN"
}

CXIndex :: distinct ^_c_.int

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
	Platform: _c_.int,
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
	Message: _c_.int,
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
	context: rawptr,
	visit: ^^CXVisitorResult ()(void , CXCursor, CXSourceRange),
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

