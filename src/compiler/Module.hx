package compiler;
import haxe.io.Bytes;
import compiler.types.*;
using compiler.Value;

class Module {
    public var imports:Array<ImportDef>;
    public var vars:Array<Value>;
    public var functions:Array<Function>;

    public var exports:Array<ImportDef>;

    public var isNode:Bool = false;

    public var inportTypes:Array<ValueType>;

    public var inports:Array<Value>;



    public function new() {
        this.imports = [];
        this.vars = [];
        this.functions = [];
        this.exports = [];
    }

    public function decode(code:Bytes) {
        
    }

    public function compile(source:String):Bytes {
        return null;
    }

    public function pushInport(index:Int, value:Value){
       if(value.type != inportTypes[index]){
           throw 'expected inport value of type ${inportTypes[index]}, but value of type ${value.type} was assigned';
       }

       inports.insert(index, value);
    }

    public function getOutport(index:Int):Value {
       return vars.filter((v)->{
            return v.kind == OUTPORT;
        })[index];
    }

    public function getOutports():Array<Value> {
        return vars.filter((v)->{
            return v.kind == OUTPORT;
        });
    }
}