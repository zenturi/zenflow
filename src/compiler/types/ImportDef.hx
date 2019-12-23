package compiler.types;

typedef ImportDef = {
    var fieldName: String;
    var moduleName: String;
    var type: ImportType;
    var kind: ImportKind;
    var isNode: Bool;
}


enum ImportType {
    FUNCTION;
    GLOBALVAR;
    CLASS;
}

enum ImportKind {
    EXTERN;
    DEFAULT;
}