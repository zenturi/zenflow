package compiler.ast;

import compiler.ast.Scanner.Token;

enum Stmt {
    Block(statements:Array<Stmt>);
    Class(name:Token, superclass:Expr, methods:Array<Stmt>);
    Expression(expression:Expr);
    Function(name:Token, params:Array<Token>, body:Array<Stmt>);
    If(condition:Expr, thenBranch:Stmt, elseBranch:Stmt);
    Print(expression:Expr);
    Return(keyword:Token, value:Expr);
    Var(name:Token, initializer:Expr);
    While(condition:Expr, body:Stmt);
}