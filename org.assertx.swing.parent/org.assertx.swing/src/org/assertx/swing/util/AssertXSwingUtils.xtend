package org.assertx.swing.util

import com.google.inject.Inject
import javax.swing.JDialog
import javax.swing.JFrame
import org.assertj.swing.fixture.DialogFixture
import org.assertj.swing.fixture.FrameFixture
import org.assertx.swing.assertXSwing.AXSTestCase
import org.eclipse.xtext.common.types.JvmParameterizedTypeReference
import org.eclipse.xtext.xbase.typesystem.references.LightweightTypeReferenceFactory
import org.eclipse.xtext.xbase.typesystem.references.StandardTypeReferenceOwner
import org.eclipse.xtext.xbase.typesystem.util.CommonTypeComputationServices

class AssertXSwingUtils {

	@Inject CommonTypeComputationServices services

	def Class<?> getFieldType(AXSTestCase tc) {
		val typeRef = tc.typeRef.toLightweightTypeRef
		return switch (typeRef) {
			case null: Void.TYPE
			case typeRef.isSubtypeOf(JFrame): return FrameFixture
			case typeRef.isSubtypeOf(JDialog): return DialogFixture
			default: Void.TYPE
		}
	}

	def toLightweightTypeRef(JvmParameterizedTypeReference typeRef) {
		if(typeRef === null || typeRef.type === null) return null

		val owner = new StandardTypeReferenceOwner(services, typeRef)
		val factory = new LightweightTypeReferenceFactory(owner, false)
		return factory.toLightweightReference(typeRef.type)
	}

}
