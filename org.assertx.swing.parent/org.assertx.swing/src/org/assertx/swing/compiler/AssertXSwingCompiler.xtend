package org.assertx.swing.compiler

import org.assertx.swing.assertXSwing.AXSMatcherRef
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.compiler.XbaseCompiler
import org.eclipse.xtext.xbase.compiler.output.ITreeAppendable

import static extension org.assertx.swing.AssertXSwingStaticExtensions.*

class AssertXSwingCompiler extends XbaseCompiler {

	override protected doInternalToJavaStatement(XExpression expr, ITreeAppendable a, boolean isReferenced) {
		if (expr instanceof AXSMatcherRef) {
			val expectedVarName = '_' + expr.reference.name
			if (!a.hasObject(expectedVarName)) {
				val name = a.declareSyntheticVariable(expr.reference, expectedVarName)
				val typeName = expr.typeName
				a.newLine
				a.append('''«typeName» «name» = new «typeName»();''')
//				a.newLine
			} //else there's nothing to do, we reuse the same matcher, that is the same variable
		} else {
			super.doInternalToJavaStatement(expr, a, isReferenced)
		}
	}
	
	override protected internalToConvertedExpression(XExpression expr, ITreeAppendable a){
		if(expr instanceof AXSMatcherRef){
			a.append(a.getName(expr.reference))
		} else {
			super.internalToConvertedExpression(expr, a)
		}
	}
}
