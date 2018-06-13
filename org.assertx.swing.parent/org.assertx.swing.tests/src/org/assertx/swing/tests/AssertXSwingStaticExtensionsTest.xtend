package org.assertx.swing.tests

import com.google.inject.Inject
import org.assertx.swing.assertXSwing.AXSMatcher
import org.assertx.swing.assertXSwing.AXSSettings
import org.assertx.swing.assertXSwing.AXSTestCase
import org.assertx.swing.assertXSwing.AXSTestMethod
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.assertx.swing.util.AssertXSwingStaticExtensions.*
import static extension org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(AssertXSwingInjectorProvider)
class AssertXSwingStaticExtensionsTest {

	@Inject extension ParseHelper<AXSTestCase>

	@Test
	def void testMemberFilteringByType() {
		'''
			testing javax.swing.JFrame
			
			test 'method' {
				
			}
			
			settings {
			}
			
			test 'second' {
				
			}
			
			match aMatcher : javax.swing.JLabel {
				
			}
			
			match anotherOne : javax.swing.JTextBox {
				
			}
		'''.parse => [
			(settings instanceof AXSSettings).assertTrue
			settings.assertNotNull
			2.assertEquals(tests.size)
			(tests.head instanceof AXSTestMethod).assertTrue()
			(tests.get(1) instanceof AXSTestMethod).assertTrue
			'method'.assertEquals(tests.head.name)
			'second'.assertEquals(tests.get(1).name)
			2.assertEquals(matchers.size)
			(matchers.head instanceof AXSMatcher).assertTrue()
			(matchers.get(1) instanceof AXSMatcher).assertTrue
			'aMatcher'.assertEquals(matchers.head.name)
			'anotherOne'.assertEquals(matchers.get(1).name)
		]
	}

	@Test
	def void testFieldNameGetterEmptyName() {
		'''
			testing javax.swing.JFrame
		'''.parse => [
			'window'.assertEquals(checkedFieldName)
		]
	}

	@Test
	def void testFieldNameGetter() {
		'''
			testing javax.swing.JFrame as myFrame
		'''.parse => [
			'myFrame'.assertEquals(checkedFieldName)
		]
	}

	@Test
	def void testGetterForTypeUnderTest() {
		'''
			testing javax.swing.JFrame
		'''.parse => [
			'JFrame'.assertEquals(checkedTypeRefName)
		]

		'''
			testing String
		'''.parse => [
			'String'.assertEquals(checkedTypeRefName)
		]
	}

	@Test
	def void testGetterForTypeUnderTestWithEmptyReference() {
		'''
			testing 
		'''.parse => [
			'void'.assertEquals(checkedTypeRefName)
		]
	}

	@Test
	def void testNamesMappingsGeneration() {
		'''
			testing Object
			
			test 'name 1' {}
			
			test 'name two' {}
			
			test 'Name Up' {}
		'''.parse.assertNamesMappings('name1, nameTwo, nameUp')
	}

	@Test
	def void testNamesMappingsGenerationEmptyOrInvalidCharacters_1() {
		'''
			testing Object
			
			test '' {}
			
			test '+*1  me.tho d' {}
		'''.parse.assertNamesMappings('__, _1MethoD')
	}

	@Test
	def void testNamesMappingsGenerationEmptyOrInvalidCharacters_2() {
		'''
			testing Object
			
			test '/*-+' {}
			
			test '1234' {}
		'''.parse.assertNamesMappings('__, _1234')
	}

	@Test
	def void testSameTestCaseGenerateEqualsButNotSameMappings() {
		'''
			testing Object
			
			test 'first name' {}
			
			test 'second name' {}
			
			test 'third name' {}
		'''.parse => [
			val first = camelCaseMethodsNamesMappings
			val second = camelCaseMethodsNamesMappings
			first.assertEquals(second)
			first.assertNotSame(second)
		]
	}

	@Test
	def void testEqualTestCasesGenerateDifferentMappingsWithSameNames() {
		val first = '''
			testing Object
			
			test 'first name' {}
			test 'second name' {}
		'''.parse.camelCaseMethodsNamesMappings

		val second = '''
			testing Object
			
			test 'first name' {}
			test 'second name' {}
		'''.parse.camelCaseMethodsNamesMappings

		first.assertNotEquals(second)
		first.values.sort.toString.assertEquals(second.values.sort.toString)
	}

	@Test
	def void testGeneratedMethodsListWithNullArgument() {
		assertGeneratedMethods(null, '_beforeClass, _setup, _cleanUp, _beforeClass(), _setup(), _cleanUp()')
	}

	@Test
	def void testGeneratedMethodsListOnTestCaseWithoutSettings() {
		'''
			testing Object
		'''.parse.assertGeneratedMethods('_beforeClass, _setup, _cleanUp, _beforeClass(), _setup(), _cleanUp()')
	}

	@Test
	def void testGeneratedMethodsListOnTestCaseWithSettings() {
		'''
			testing Object
			
			settings {}
		'''.parse.assertGeneratedMethods(
			'_beforeClass, _setup, _cleanUp, _beforeClass(), _setup(), _cleanUp(), _customizeSettings, _customizeSettings()')
	}

	@Test
	def void testRemoveSettingsRemoveAllSettings() {
		'''
			testing Object
			
			settings {}
			
			settings {}
		'''.parse => [
			2.assertEquals(members.size)
			removeSettings
			members.empty.assertTrue
		]
	}

	@Test
	def void testRemoveSettingsOnlyRemovesSettings() {
		'''
			testing Object
			
			settings {}
			
			test 'test' {}
			
			match matcher : Object {}
		'''.parse => [
			3.assertEquals(members.size)
			val settings = members.get(0)
			val test = members.get(1)
			val matcher = members.get(2)
			removeSettings
			2.assertEquals(members.size)
			members.contains(settings).assertFalse
			members.contains(test).assertTrue
			members.contains(matcher).assertTrue

		]
	}

	@Test
	def void testRemoveOtherSettingsAndKeepThisOneActuallyRemoveOtherSettingsButKeepsThisOne() {
		'''
			testing Object
			
			settings {}
			
			settings {}
			
			settings {}
		'''.parse => [
			val settings = members.get(1) as AXSSettings
			settings.removeOtherSettingsAndKeepThisOne
			1.assertEquals(members.size)
			settings.assertSame(members.head)
		]
	}

	@Test
	def void testRemoveOtherSettingsAndKeepThisOneDontModifyPositionOfSettings() {
		'''
			testing Object
			
			test '1' {}
			
			settings {}
			
			settings {}
			
			test '2' {}
		'''.parse => [
			4.assertEquals(members.size)
			val settings = settings
			settings.removeOtherSettingsAndKeepThisOne
			3.assertEquals(members.size)
			settings.assertSame(members.get(1))
		]
	}

	@Test
	def void testRemoveOtherSettingsAndKeepThisOneDontExceedIndexConstraints() {
		'''
			testing Object
			
			settings {}
			
			test '1' {}
			
			settings {}
		'''.parse => [
			3.assertEquals(members.size)
			val settings = members.last as AXSSettings
			settings.removeOtherSettingsAndKeepThisOne
			2.assertEquals(members.size)
			settings.assertSame(members.last)
		]
	}

	@Test
	def void testRemoveOtherSettingsAndKeepThisOneOnlyRemovesSettings() {
		'''
			testing Object
			
			test '' {}
			settings {}
			match m : Object {}
		'''.parse => [
			3.assertEquals(members.size)
			settings.removeOtherSettingsAndKeepThisOne
			3.assertEquals(members.size)
		]
	}

	def private void assertGeneratedMethods(AXSTestCase testCase, String expected) {
		val generatedMethods = testCase.generatedMethodsNames

		expected.assertEquals(generatedMethods.join(', '))
	}

	def private void assertNamesMappings(AXSTestCase testCase, String expectedNames) {
		val generatedMapping = testCase.camelCaseMethodsNamesMappings
		val generatedNames = testCase.tests.map[generatedMapping.get(it)].join(', ')
		expectedNames.assertEquals(generatedNames)
	}
}
