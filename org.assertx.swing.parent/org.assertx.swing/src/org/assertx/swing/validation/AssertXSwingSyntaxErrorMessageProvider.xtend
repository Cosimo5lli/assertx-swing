package org.assertx.swing.validation

import org.eclipse.xtext.nodemodel.SyntaxErrorMessage
import org.eclipse.xtext.parser.antlr.SyntaxErrorMessageProvider

class AssertXSwingSyntaxErrorMessageProvider extends SyntaxErrorMessageProvider {
	
	override getSyntaxErrorMessage(IParserErrorContext context){
		val token = context?.recognitionException?.token?.text
		
		if( '{' == token &&  context.defaultMessage == "missing RULE_STRING at '{'"){
			return new SyntaxErrorMessage('Missing method name after "test" keyword',AssertXSwingValidator.NULL_METHOD_NAME)
		} else {
			return super.getSyntaxErrorMessage(context)
		}
	}
}