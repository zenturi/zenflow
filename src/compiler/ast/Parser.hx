package compiler.ast;

import compiler.ast.Scanner.Token;
import compiler.ast.Scanner.TokenType;

/**
 * A Recursive Descent Parser
 */
class Parser {
	var match:Dynamic;
	var tokens:Array<Token>;

	var current:Int = 0;

	public function new(tokens:Array<Token>) {
		this.tokens = tokens;
		this.match = Reflect.makeVarArgs(_match);
	}

	public function parse() {
		var statements:Array<Stmt> = [];
		while (!isAtEnd()) {
			statements.push(declaration());
		}
		return statements;
	}

	function _match(types:Array<Dynamic>):Bool {
		for (type in types) {
			if (check(cast type)) {
				next();
				return true;
			}
		}

		return false;
	}

	function check(type:TokenType):Bool {
		if (isAtEnd())
			return false;
		return peek().type == type;
	}

	function next():Token {
		if (!isAtEnd())
			current++;
		return previous();
	}

	function isAtEnd():Bool {
		return peek().type == EOF;
	}

	function peek():Token {
		return tokens[current];
	}

	function previous():Token {
		return tokens[current - 1];
	}

	function consume(type:TokenType, message:String):Token {
		if (check(type))
			return next();
		throw err(peek(), message);
	}

	function expression():Expr {
		return assignment();
	}

	function declaration() {
		try {
			if (match(VAR))
				return varDeclaration();

			return statement();
		} catch (e:Dynamic) {
			Sys.println(e);
			synchronize();
			return null;
		}
	}

	function statement() {
		if (match(FOR))
			return forStatement();
		if (match(IF))
			return ifStatement();
		if (match(PRINT))
			return printStatement();
		if (match(WHILE))
			return whileStatement();
		if (match(LEFT_BRACE))
			return Stmt.Block(block());
		return expressionStatement();
	}

	function forStatement() {
		consume(LEFT_PAREN, "Expect '(' after 'for'.");

		// More here...

		var initializer = expression();
		var condition = null;

		if (match(IN)) {
			var inc = primary();
			if (match(DOT)) {
				var dot = consume(DOT, 'Expect "..." after $inc.');
				consume(DOT, 'Expect "." after "..".');
				var exp = expression();
				condition = Expr.Logical(inc, {
					type: DOT,
					lexeme: "...",
					literal: null,
					line: dot.line
				}, exp);
			} else {
				condition = Expr.Logical(initializer, {
					type: IN,
					lexeme: "in",
					literal: null,
					line: 0
				}, inc);
			}
		} else {
			consume(IN, 'Expect "in" after "$initializer".');
		}

		// var initializer:Stmt = null;
		// if (match(SEMICOLON)) {
		// 	initializer = null;
		// } else if (match(VAR)) {
		// 	initializer = varDeclaration();
		// } else {
		// 	initializer = expressionStatement();
		// }
		// var condition = null;
		// if (!check(SEMICOLON)) {
		// 	condition = expression();
		// }
		// consume(SEMICOLON, "Expect ';' after loop condition.");

		// var increment = null;
		// if (!check(RIGHT_PAREN)) {
		// 	increment = expression();
		// }

		consume(RIGHT_PAREN, "Expect ')' after for clauses.");
		var body = statement();
		if (initializer != null) {
			body = Stmt.Block([body, Stmt.Expression(Expr.Literal(initializer))]);
		}
		if (condition == null)
			condition = Expr.Literal(true);
		body = Stmt.While(condition, body);

		// if (initializer != null) {
		// 	body = Stmt.Block([initializer, body]);
		// }
		return body;
	}

	function ifStatement() {
		consume(LEFT_PAREN, "Expect '(' after 'if'.");
		var condition = expression();
		consume(RIGHT_PAREN, "Expect ')' after if condition.");
		var thenBranch = statement();
		var elseBranch = null;
		if (match(ELSE)) {
			elseBranch = statement();
		}
		return Stmt.If(condition, thenBranch, elseBranch);
	}

	function printStatement() {
		var value = expression();
		consume(SEMICOLON, "Expect ';' after value.");
		return Stmt.Print(value);
	}

	function varDeclaration() {
		var name = consume(IDENTIFIER, "Expect variable name.");

		var initializer:Expr = null;
		if (match(EQUAL)) {
			initializer = expression();
		}

		consume(SEMICOLON, "Expect ';' after variable declaration.");
		return Stmt.Var(name, initializer);
	}

	function whileStatement() {
		consume(LEFT_PAREN, "Expect '(' after 'while'.");
		var condition = expression();
		consume(RIGHT_PAREN, "Expect ')' after condition.");
		var body = statement();
		return Stmt.While(condition, body);
	}

	function expressionStatement() {
		var expr = expression();
		consume(SEMICOLON, "Expect ';' after expression.");
		return Stmt.Expression(expr);
	}

	function block() {
		var statements:Array<Stmt> = [];
		while (!check(RIGHT_BRACE) && !isAtEnd()) {
			statements.push(declaration());
		}
		consume(RIGHT_BRACE, "Expect '}' after block.");
		return statements;
	}

	function assignment() {
		var expr = or();

		if (match(EQUAL)) {
			var equals = previous();
			var value = assignment();

			if (Type.enumConstructor(expr) == "Variable") {
				var name = Type.enumParameters(expr)[0];
				return Expr.Assign(name, value);
			}

			err(equals, "Invalid assignment target.");
		}

		return expr;
	}

	function or() {
		var expr = and();

		while (match(OR)) {
			var op = previous();
			var right = and();
			expr = Expr.Logical(expr, op, right);
		}

		return expr;
	}

	function and() {
		var expr = equality();

		while (match(AND)) {
			var op = previous();
			var right = equality();
			expr = Expr.Logical(expr, op, right);
		}

		return expr;
	}

	function equality():Expr {
		var expr = comparison();
		while (match(BANG_EQUAL, EQUAL_EQUAL)) {
			var op = previous();
			var right = comparison();

			expr = Expr.Binary(expr, op, right);
			trace(expr);
		}

		return expr;
	}

	function comparison():Expr {
		var expr = addition();
		while (match(GREATER, GREATER_EQUAL, LESS, LESS_EQUAL)) {
			var op = previous();
			var right = addition();

			expr = Expr.Binary(expr, op, right);
		}
		return expr;
	}

	function addition():Expr {
		var expr = multiplication();
		while (match(MINUS, PLUS)) {
			var op = previous();
			var right = multiplication();

			expr = Expr.Binary(expr, op, right);
		}
		return expr;
	}

	function multiplication():Expr {
		var expr = unary();
		while (match(MINUS, PLUS)) {
			var op = previous();
			var right = unary();

			expr = Expr.Binary(expr, op, right);
		}
		return expr;
	}

	function unary():Expr {
		if (match(BANG, MINUS)) {
			var op = previous();
			var right = unary();
			return Expr.Unary(op, right);
		}

		return call();
	}

	function call():Expr {
		var expr = primary();

		while (true) {
			if (match(LEFT_PAREN)) {
				expr = finishCall(expr);
			} else {
				break;
			}
		}

		return expr;
	}

	function finishCall(callee:Expr) {
		var arguments:Array<Expr> = [];
		if (!check(RIGHT_PAREN)) {
			do {
				if (arguments.length >= 255) {
					err(peek(), "Cannot have more than 255 arguments.");
				}
				arguments.push(expression());
			} while (match(COMMA));
		}

		var paren = consume(RIGHT_PAREN, "Expect ')' after arguments.");

		return Expr.Call(callee, paren, arguments);
	}

	function primary():Expr {
		if (match(FALSE))
			return Expr.Literal(false);
		if (match(TRUE))
			return Expr.Literal(true);
		if (match(NIL))
			return Expr.Literal(null);

		if (match(NUMBER, STRING)) {
			return Expr.Literal(previous().literal);
		}

		if (match(IDENTIFIER)) {
			return Expr.Variable(previous());
		}

		if (match(LEFT_PAREN)) {
			var expr = expression();
			consume(RIGHT_PAREN, "Expect ')' after expression.");
			return Expr.Grouping(expr);
		}

		throw err(peek(), "Expect expression.");
	}

	function err(token:Token, message:String) {
		if (token.type == TokenType.EOF) {
			return report(token.line, " at end", message);
		} else {
			return report(token.line, " at '" + token.lexeme + "'", message);
		}
	}

	function report(line:Int, where:String, message:String) {
		return 'Parser Error:\n\t$message\n\t\tline $line:\n\t\t\t$where';
	}

	function synchronize() {
		next();

		while (!isAtEnd()) {
			if (previous().type == SEMICOLON)
				return;

			switch (peek().type) {
				case CLASS:
				case FUN:
				case VAR:
				case FOR:
				case IF:
				case WHILE:
				case PRINT:
				case RETURN:
					return;
				default:
			}

			next();
		}
	}
}
