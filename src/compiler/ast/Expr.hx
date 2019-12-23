package compiler.ast;

import compiler.ast.Scanner.Token;

enum Expr {
    Assign(name:Token, value:Expr);
    Binary(left:Expr, op:Token, right:Expr);
    Grouping(expression:Expr);
    Literal(value:Dynamic);
    Unary(op:Token, right:Expr);
    Call(callee:Expr, paren:Token, args:Array<Expr>);
    Get(obj:Expr, name:Token);
    Logical(left:Expr, op:Token, right:Expr);
    Set(obj:Expr, name:Token, value:Expr);
    Super(keyword:Token, method:Token);
    This(keyword:Token);
    Variable(keyword:Token);
}