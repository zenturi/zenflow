package compiler.ast;

/**
 * Scanner class based on http://craftinginterpreters.com/scanning.html
 */
class Scanner {
	var source:String;
	var tokens:Array<Token>;

	var start:Int = 0;
	var current:Int = 0;
	var line:Int = 1;

    var keywords:Map<String, TokenType> = [
        "and" => AND,
        "class" => CLASS,
        "else" => ELSE,
        "false" => FALSE,
        "for" => FOR,
        "fun" => FUN,
        "if" => IF,
        "nil" => NIL,
        "or" => OR,
        "print" => PRINT,
        "return" => RETURN,
        "super" => SUPER,
        "this" => THIS,
        "true" => TRUE,
        "var" => VAR,
        "while" => WHILE,
		"in"=> IN
    ];

	public function new(source:String) {
		this.source = source;
		this.tokens = [];
	}

	public function scanTokens():Array<Token> {
		while (!isAtEnd()) {
			// We are at the beginning of the next lexeme.
			start = current;
			scanToken();
		}

		tokens.push({
			type: EOF,
			lexeme: "",
			literal: null,
			line: line
		});

		return tokens;
	}

	function isAtEnd():Bool {
		return current >= source.length;
	}

	function scanToken() {
		var c:String = next();
		switch c {
			case "(":
				addToken(LEFT_PAREN);
			case ")":
				addToken(RIGHT_PAREN);
			case '{':
				addToken(LEFT_BRACE);
			case '}':
				addToken(RIGHT_BRACE);
			case ',':
				addToken(COMMA);
			case '.':
				addToken(DOT);
			case '-':
				addToken(MINUS);
			case '+':
				addToken(PLUS);
			case ';':
				addToken(SEMICOLON);
			case '*':
				addToken(STAR);
			case '!':
				addToken(match('=') ? BANG_EQUAL : BANG);
			case '=':
				addToken(match('=') ? EQUAL_EQUAL : EQUAL);
			case '<':
				addToken(match('=') ? LESS_EQUAL : LESS);
			case '>':
				addToken(match('=') ? GREATER_EQUAL : GREATER);
			case '/':
				if (match('/')) {
					// A comment goes until the end of the line.
					while (peek() != '\n' && !isAtEnd())
						next();
				} else {
					addToken(SLASH);
				}
			case ' ' | '\r' | '\t':
			case '\n':
				line++;
			case '"':
				string();
			default:
				if (isDigit(c))
					number();
				else if (isAlpha(c)) {
					identifier();
				} else
					throw 'Unexpected Character $c at line $line';
		}
	}

	function string() {
		while (peek() != '"' && !isAtEnd()) {
			if (peek() == '\n')
				line++;
			next();
		}

		// Unterminated string.
		if (isAtEnd()) {
			throw 'Unterminated string. $line';
			return;
		}

		// the closing "
		next();
		// Trim the surrounding quotes.
		var value = source.substring(start + 1, current - 1);
		addToken(STRING, value);
	}

	function number() {
		while (isDigit(peek()))
			next();
		// Look for a fractional part.
		if (peek() == '.' && isDigit(peekNext())) {
			// Consume the "."
			next();

			while (isDigit(peek()))
				next();
		}

		addToken(NUMBER, Std.parseFloat(source.substring(start, current)));
	}

	function identifier() {
		while (isAlphaNumeric(peek()))
			next();
        // See if the identifier is a reserved word.   
        var text = source.substring(start, current);
        var type = keywords.get(text);
        if (type == null) type = IDENTIFIER;
		addToken(type);
	}

	function isAlpha(c:String) {
		return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
	}

	function isAlphaNumeric(c:String) {
		return isAlpha(c) || isDigit(c);
	}

	function isDigit(c:String):Bool {
		return c >= '0' && c <= '9';
	}

	function next():String {
		current++;
		return source.charAt(current - 1);
	}

	function peek():String {
		if (isAtEnd())
			return '\\0';
		return source.charAt(current);
	}

	function peekNext():String {
		if (current + 1 >= source.length)
			return '\\0';
		return source.charAt(current + 1);
	}

	function match(expected:String) {
		if (isAtEnd())
			return false;
		if (source.charAt(current) != expected)
			return false;
		current++;
		return true;
	}

	function addToken(type:TokenType, literal:Dynamic = null) {
		var text = source.substring(start, current);
		tokens.push({
			type: type,
			lexeme: text,
			literal: literal != null ? literal : null,
			line: line
		});
	}
}

enum TokenType {
	// Single-character tokens.
	LEFT_PAREN;
	RIGHT_PAREN;
	LEFT_BRACE;
	RIGHT_BRACE;
	COMMA;
	DOT;
	MINUS;
	PLUS;
	SEMICOLON;
	SLASH;
	STAR;

	// One or two character tokens.
	BANG;
	BANG_EQUAL;
	EQUAL;
	EQUAL_EQUAL;
	GREATER;
	GREATER_EQUAL;
	LESS;
	LESS_EQUAL;
	// Literals.
	IDENTIFIER;
	STRING;
	NUMBER;
	// Keywords.
	AND;
	CLASS;
	ELSE;
	FALSE;
	FUN;
	FOR;
	IF;
	NIL;
	OR;
	PRINT;
	RETURN;
	SUPER;
	THIS;
	TRUE;
	VAR;
	WHILE;

	IN;
	EOF;
}

typedef TToken = {
	var type:TokenType;
	var lexeme:String;
	var literal:Dynamic;
	var line:Int;
}


@:forward(
	type,
	lexeme,
	literal,
	line
)
abstract Token(TToken) {
	inline function new(t:TToken) {
		this = t;
	}

	@:from static public function fromToken(t:TToken):Token {
		return new Token(t);
	}

	@:to public function toToken():TToken {
		return {
			type: this.type,
			lexeme: this.lexeme,
			literal: this.literal,
			line: this.line
		};
	}

	public inline function toString() {
		return '${this.type} ${this.lexeme} ${this.literal}';
	}
}
