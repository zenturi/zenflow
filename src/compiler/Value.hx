package compiler;

class Value {
    public var type:ValueType;

    public var kind:ValueKind;
    public var name:String;

    var module:String;

    public function new(name:String, type:ValueType, kind:ValueKind = DEFAULT, ?module:String) {
        this.module = module != null ? module : null;
        this.type = type;
        this.name = name;
        this.kind = kind;
    }
}



enum ValueType {
    STRING;
    NUMBER;
    ANY;
    FUNC;
    TABLE;
    MOD;
}

enum ValueKind {
    INPORT;
    OUTPORT;
    DEFAULT;
}