package ;

import compiler.ast.Scanner;
import compiler.ast.Parser;
/**
	@author $author
**/
class Main {

	static var source:String = '
for(i in array)
	print whenFalse;
run(a, b, c, d, e);
if (first) 
	if(second) 
		whenTrue(); 
	else 
		whenFalse();
		var i = 0;
		while (i < 10)
			print i;
			i = i + 1;
		for(i in 0...1000)
			print whenFalse;

var a = "global a";
var b = "global b";
var c = "global c";
{
  var a = "outer a";
  var b = "outer b";
  {
    var a = "inner a";
    print a;
    print b;
    print c;
  }
  print a;
  print b;
  print c;
}
print a;
print b;
print c;
	';
	public static function main() {
		new Main(source);
	}

	public function new(s:String) {
		var s = new Scanner(s);
		// trace(s.scanTokens());
		var ast = new Parser(s.scanTokens());
		trace(ast.parse());
	}
}