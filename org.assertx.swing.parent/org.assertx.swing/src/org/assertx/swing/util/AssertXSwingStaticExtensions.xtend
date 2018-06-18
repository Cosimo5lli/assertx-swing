package org.assertx.swing.util

import java.util.HashMap
import java.util.List
import org.assertx.swing.assertXSwing.AXSDefinable
import org.assertx.swing.assertXSwing.AXSFile
import org.assertx.swing.assertXSwing.AXSMatcher
import org.assertx.swing.assertXSwing.AXSMatcherRef
import org.assertx.swing.assertXSwing.AXSSettings
import org.assertx.swing.assertXSwing.AXSTestCase
import org.assertx.swing.assertXSwing.AXSTestMethod
import org.assertx.swing.jvmmodel.AssertXSwingJvmModelInferrer
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.common.types.JvmParameterizedTypeReference

class AssertXSwingStaticExtensions {

	def static getCheckedFieldName(AXSTestCase tc) {
		tc.fieldName ?: 'window'
	}

	def static getCheckedTypeRefName(AXSTestCase tc) {
		tc.typeRef.checkedTypeRefName
	}
	
	def static getCheckedTypeRefName(JvmParameterizedTypeReference ref){
		ref?.simpleName ?: Void.TYPE.simpleName
	}

	def static getSettings(AXSTestCase tc) {
		tc.allSettings.head
	}

	def static removeOtherSettingsAndKeepThisOne(AXSSettings settings) {
		val testCase = EcoreUtil2.getContainerOfType(settings, AXSTestCase)
		testCase.members.removeIf[it instanceof AXSSettings && !(settings === it)]
	}

	def static getAllSettings(AXSTestCase tc) {
		tc.members.filter(AXSSettings)
	}

	def static getTests(AXSTestCase tc) {
		tc.members.filter(AXSTestMethod)
	}

	def static removeSettings(AXSTestCase tc) {
		tc.members.removeAll(tc.allSettings)
	}

	def static getMatchers(AXSTestCase tc) {
		tc.members.filter(AXSMatcher)
	}

	def static getTypeName(AXSMatcherRef ref) {
		ref.reference.typeName
	}

	def static getTypeName(AXSMatcher m) {
		m.name.toFirstUpper
	}

	def static getCamelCaseMethodsNamesMappings(AXSTestCase tc) {
		val methodsNamesMappings = newHashMap
		val collisions = newHashMap
		for (test : tc.tests) {
			methodsNamesMappings.put(test, test.generateCamelCaseName(collisions))
		}
		return methodsNamesMappings
	}

	def static private generateCamelCaseName(AXSTestMethod tm, HashMap<String, Integer> methodsNamesCollisions) {
		val name = tm.name
		if(name === null) return null

		var ccn = name.replaceAll('[^a-zA-Z0-9$_ ]', '').split(' ').map[toFirstUpper].join.toFirstLower
		if (!ccn.matches('[a-z$_][a-zA-Z0-9$_]*'))
			ccn = '_' + ccn

		val finalName = methodsNamesCollisions.manageCollisionsAndGetName(ccn)
		// cause '_' is a keyword in Java 8
		if(finalName == '_') return '__'
		return finalName
	}

	def static private String manageCollisionsAndGetName(HashMap<String, Integer> methodsNamesCollisions, String ccn) {
		if (methodsNamesCollisions.containsKey(ccn)) {
			val num = methodsNamesCollisions.get(ccn)
			methodsNamesCollisions.put(ccn, num + 1)
			return ccn + '_' + num + '_'
		} else {
			methodsNamesCollisions.put(ccn, 1)
			return ccn
		}
	}

	def static List<String> getGeneratedMethodsNames(AXSTestCase tc) {
		val list = newLinkedList
		list += AssertXSwingJvmModelInferrer.BEFORE_CLASS_METHOD_NAME
		list += AssertXSwingJvmModelInferrer.BEFORE_METHOD_NAME
		list += AssertXSwingJvmModelInferrer.AFTER_METHOD_NAME
		list += AssertXSwingJvmModelInferrer.BEFORE_CLASS_METHOD_NAME + '()'
		list += AssertXSwingJvmModelInferrer.BEFORE_METHOD_NAME + '()'
		list += AssertXSwingJvmModelInferrer.AFTER_METHOD_NAME + '()'
		if (tc?.settings !== null) {
			list += AssertXSwingJvmModelInferrer.SETTINGS_METHOD_NAME
			list += AssertXSwingJvmModelInferrer.SETTINGS_METHOD_NAME + '()'
		}
		return list
	}

	def static getPackage(AXSDefinable definable) {
		val fileName = definable.eResource.URI.trimFileExtension.lastSegment
		val declaredPackage = EcoreUtil2.getContainerOfType(definable, AXSFile).packName
		if (declaredPackage !== null) {
			return declaredPackage + '.' + fileName
		} else {
			return fileName
		}
	}

	def static getQualifiedName(AXSDefinable definable) {
		return definable.package + '.' + definable.name.toFirstUpper
	}

	def static getTestCases(AXSFile file) {
		file.definitions.filter(AXSTestCase)
	}

	def static getMatchers(AXSFile file) {
		file.definitions.filter(AXSMatcher)
	}
}
