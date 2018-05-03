package org.assertx.swing

import java.util.HashMap
import org.assertx.swing.assertXSwing.AXSSettings
import org.assertx.swing.assertXSwing.AXSTestCase
import org.assertx.swing.assertXSwing.AXSTestMethod
import org.eclipse.xtext.common.types.JvmGenericType
import org.eclipse.xtext.xbase.jvmmodel.JvmTypeExtensions
import org.eclipse.xtext.xbase.jvmmodel.JvmTypeReferenceBuilder

class AssertXSwingUtil {
	
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
	
//	def getTestedClassSuperType(AXSTestCase tc){
//		val type = tc.testedTypeRef.type as JvmGenericType
//		type.extendedClass
//	}
}
