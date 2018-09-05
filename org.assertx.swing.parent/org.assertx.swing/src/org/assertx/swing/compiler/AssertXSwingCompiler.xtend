package org.assertx.swing.compiler

import org.assertx.swing.assertXSwing.AXSMatcherRef
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.compiler.XbaseCompiler
import org.eclipse.xtext.xbase.compiler.output.ITreeAppendable

import static extension org.assertx.swing.util.AssertXSwingStaticExtensions.*

class AssertXSwingCompiler extends XbaseCompiler {

	override protected doInternalToJavaStatement(XExpression expr, ITreeAppendable a, boolean isReferenced) {
		if (expr instanceof AXSMatcherRef) {
			if (!a.hasName(expr.reference)) {
				val name = a.declareSyntheticVariable(expr.reference, '_' + expr.reference.name)
				val typeName = expr.reference.typeName
				a.newLine
				a.append('''«typeName» «name» = new «typeName»();''')
			} // else there's nothing to do, we reuse the same matcher, that is the same variable
		} else {
			super.doInternalToJavaStatement(expr, a, isReferenced)
		}
	}

	override protected internalToConvertedExpression(XExpression expr, ITreeAppendable a) {
		if (expr instanceof AXSMatcherRef) {
			a.append(a.getName(expr.reference))
		} else {
			super.internalToConvertedExpression(expr, a)
		}
	}
}
