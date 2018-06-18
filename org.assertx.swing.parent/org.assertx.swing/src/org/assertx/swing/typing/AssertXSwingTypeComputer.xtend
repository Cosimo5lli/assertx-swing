package org.assertx.swing.typing;

import org.eclipse.xtext.xbase.typesystem.computation.XbaseTypeComputer
import org.assertx.swing.assertXSwing.AXSMatcherRef
import org.eclipse.xtext.xbase.typesystem.computation.ITypeComputationState
import org.assertj.swing.core.GenericTypeMatcher
import org.eclipse.xtext.xbase.typesystem.references.ParameterizedTypeReference
import org.eclipse.xtext.common.types.JvmVoid

class AssertXSwingTypeComputer extends XbaseTypeComputer {

	def dispatch void computeTypes(AXSMatcherRef matcherRef, ITypeComputationState state) {
		val matcherType = getRawTypeForName(GenericTypeMatcher, state).type
		val parameterType = matcherRef?.reference?.typeRef?.type
		val actualType = if (parameterType !== null && !(parameterType instanceof JvmVoid)) {
				val owner = state.referenceOwner
				val completeType = new ParameterizedTypeReference(owner, matcherType)
				completeType.addTypeArgument(owner.toLightweightTypeReference(parameterType))
				completeType
			} else {
				getRawTypeForName(GenericTypeMatcher, state)
			}
		state.acceptActualType(actualType)
	}
}
