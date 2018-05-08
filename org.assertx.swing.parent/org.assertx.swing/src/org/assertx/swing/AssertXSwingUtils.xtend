package org.assertx.swing

import com.google.inject.Inject
import java.util.HashMap
import javax.swing.JDialog
import javax.swing.JFrame
import org.assertj.swing.fixture.DialogFixture
import org.assertj.swing.fixture.FrameFixture
import org.assertx.swing.assertXSwing.AXSTestCase
import org.assertx.swing.assertXSwing.AXSTestMethod
import org.eclipse.xtext.common.types.JvmParameterizedTypeReference
import org.eclipse.xtext.xbase.typesystem.references.LightweightTypeReferenceFactory
import org.eclipse.xtext.xbase.typesystem.references.StandardTypeReferenceOwner
import org.eclipse.xtext.xbase.typesystem.util.CommonTypeComputationServices

class AssertXSwingUtils {
	
	@Inject CommonTypeComputationServices services
	
	val HashMap<String, Integer> methodsNamesCollisions = newHashMap

	def getCamelCaseName(AXSTestMethod tm) {
		val name = tm.name
		if (name === null) return null
		
		var ccn = name.replaceAll('[^a-zA-Z0-9$_ ]', '').split(' ').map[toFirstUpper].join.toFirstLower
		if(!ccn.matches('[a-z$_][a-zA-Z0-9$_]*'))
			ccn = '_' + ccn
		
		return getNameAfterCheckingCollisions(ccn)
	}
	
	def private String getNameAfterCheckingCollisions(String ccn) {
		if(methodsNamesCollisions.containsKey(ccn)){
			val num = methodsNamesCollisions.get(ccn)
			methodsNamesCollisions.put(ccn, num + 1)
			return ccn + '_' + num + '_'
		} else {
			methodsNamesCollisions.put(ccn, 1)
			return ccn
		}
	}
	
	def getCheckedFieldName(AXSTestCase tc) {
		tc.fieldName ?: 'window'
	}
	
	def getCheckedTypeRefName(AXSTestCase tc) {
		tc.testedTypeRef?.simpleName ?: Void.TYPE.simpleName
	}
	
	def Class<?> getFieldType(AXSTestCase tc){
		val typeRef = tc.testedTypeRef.toLightweightTypeRef
		return switch(typeRef){
			case null: Void.TYPE
			case typeRef.isSubtypeOf(JFrame): return FrameFixture
			case typeRef.isSubtypeOf(JDialog): return DialogFixture
			default: Void.TYPE
		}
	}
	
	def toLightweightTypeRef(JvmParameterizedTypeReference typeRef){
		if(typeRef?.type === null) return null
		
		val owner = if(typeRef !== null){
			new StandardTypeReferenceOwner(services, typeRef)
		} else return null
		val factory = if(owner !== null){
			new LightweightTypeReferenceFactory(owner, false)
		} else return null
		if(factory !== null) {
			return factory.toLightweightReference(typeRef.type)
		} else return null
	}
}
