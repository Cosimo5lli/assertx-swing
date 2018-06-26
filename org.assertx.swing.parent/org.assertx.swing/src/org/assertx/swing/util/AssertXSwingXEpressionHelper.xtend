package org.assertx.swing.util

import org.assertx.swing.assertXSwing.AXSMatcherRef
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.util.XExpressionHelper

class AssertXSwingXEpressionHelper extends XExpressionHelper {

	override hasSideEffects(XExpression expr) {
		if (expr instanceof AXSMatcherRef) {
			false
		} else {
			super.hasSideEffects(expr)
		}
	}
}
