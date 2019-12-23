package compiler;

import compiler.Value.ValueType;
import haxe.io.Bytes;

class Function {
    public var name:String;
    public var locals:Array<Value>;

    public var signature:FunctionSignature;

    public var code:Bytes;

    public var isNode:Bool = false;

    public var inports:Array<Value>;
    public var outports:Array<Value>;

    public function new(name:String, locals:Array<Value>, code:Bytes) {
        this.code = code;
        this.name = name;
        this.locals = locals;
        this.inports = [];
        this.outports = [];
    }

    public function exec() {
        
    }
}


class FunctionSignature {
    public var paramTypes:Array<ValueType>;
    public var returnTypes:Array<ValueType>;

    public function toString() {
        return '<func ${[for (_p in paramTypes) _p]} -> ${[for (_r in returnTypes) _r]}>';
    }
}