package org.assertx.swing.tests

import com.google.inject.Inject
import org.assertx.swing.assertXSwing.AXSDefinable
import org.assertx.swing.assertXSwing.AXSFile
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

	@Inject extension ParseHelper<AXSFile>

	@Test
	def void testMemberFilteringByType() {
		'''
			def Test testing javax.swing.JFrame {
			
				test 'method' {
					
				}
				
				settings {
				}
				
				test 'second' {
					
				}
				
				def aMatcher match javax.swing.JLabel {
					
				}
				
				def anotherOne match javax.swing.JTextBox {
					
				}
			}
		'''.parse.testCases.head => [
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
			def Test testing javax.swing.JFrame
		'''.parse.testCases.head => [
			'window'.assertEquals(checkedFieldName)
		]
	}

	@Test
	def void testFieldNameGetter() {
		'''
			def Test testing javax.swing.JFrame as myFrame
		'''.parse.testCases.head => [
			'myFrame'.assertEquals(checkedFieldName)
		]
	}

	@Test
	def void testGetterForTypeUnderTest() {
		'''
			def Test testing javax.swing.JFrame
		'''.parse.testCases.head => [
			'JFrame'.assertEquals(checkedTypeRefName)
		]

		'''
			def Test testing String
		'''.parse.testCases.head => [
			'String'.assertEquals(checkedTypeRefName)
		]
	}

	@Test
	def void testGetterForTypeUnderTestWithEmptyReference() {
		'''
			def Test testing 
		'''.parse.testCases.head => [
			'void'.assertEquals(checkedTypeRefName)
		]
	}

	@Test
	def void testNamesMappingsGeneration() {
		'''
			def Test testing Object {
			
			test 'name 1' {}
			
			test 'name two' {}
			
			test 'Name Up' {}
			}
		'''.parse.testCases.head.assertNamesMappings('name1, nameTwo, nameUp')
	}

	@Test
	def void testNamesMappingsGenerationEmptyOrInvalidCharacters_1() {
		'''
			def Test testing Object{
			
			test '' {}
			
			test '+*1  me.tho d' {}
			}
		'''.parse.testCases.head.assertNamesMappings('__, _1MethoD')
	}

	@Test
	def void testNamesMappingsGenerationEmptyOrInvalidCharacters_2() {
		'''
			def Test testing Object{
			
			test '/*-+' {}
			
			test '1234' {}
			}
		'''.parse.testCases.head.assertNamesMappings('__, _1234')
	}

	@Test
	def void testSameTestCaseGenerateEqualsButNotSameMappings() {
		'''
			def Test testing Object {
			
			test 'first name' {}
			
			test 'second name' {}
			
			test 'third name' {}
			}
		'''.parse.testCases.head => [
			val first = camelCaseMethodsNamesMappings
			val second = camelCaseMethodsNamesMappings
			first.assertEquals(second)
			first.assertNotSame(second)
		]
	}

	@Test
	def void testEqualTestCasesGenerateDifferentMappingsWithSameNames() {
		val first = '''
			def Test testing Object {
			
			test 'first name' {}
			test 'second name' {}
			}
		'''.parse.testCases.head.camelCaseMethodsNamesMappings

		val second = '''
			def Test testing Object {
			
			test 'first name' {}
			test 'second name' {}
			}
		'''.parse.testCases.head.camelCaseMethodsNamesMappings

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
			def Test testing Object
		'''.parse.testCases.head.assertGeneratedMethods(
			'_beforeClass, _setup, _cleanUp, _beforeClass(), _setup(), _cleanUp()')
	}

	@Test
	def void testGeneratedMethodsListOnTestCaseWithSettings() {
		'''
			def Test testing Object {
			
			settings {}
			}
		'''.parse.testCases.head.assertGeneratedMethods(
			'_beforeClass, _setup, _cleanUp, _beforeClass(), _setup(), _cleanUp(), _customizeSettings, _customizeSettings()')
	}

	@Test
	def void testRemoveSettingsRemoveAllSettings() {
		'''
			def Test testing Object {
			
			settings {}
			
			settings {}
			}
		'''.parse.testCases.head => [
			2.assertEquals(members.size)
			removeSettings
			members.empty.assertTrue
		]
	}

	@Test
	def void testRemoveSettingsOnlyRemovesSettings() {
		'''
			def Test testing Object {
			
			settings {}
			
			test 'test' {}
			
			def matcher match Object {}
			}
		'''.parse.testCases.head => [
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
			def Test testing Object {
			
			settings {}
			
			settings {}
			
			settings {}
			}
		'''.parse.testCases.head => [
			val settings = members.get(1) as AXSSettings
			settings.removeOtherSettingsAndKeepThisOne
			1.assertEquals(members.size)
			settings.assertSame(members.head)
		]
	}

	@Test
	def void testRemoveOtherSettingsAndKeepThisOneDontModifyPositionOfSettings() {
		'''
			def Test testing Object {
			
			test '1' {}
			
			settings {}
			
			settings {}
			
			test '2' {}
			}
		'''.parse.testCases.head => [
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
			def Test testing Object {
			
			settings {}
			
			test '1' {}
			
			settings {}
			}
		'''.parse.testCases.head => [
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
			def Test testing Object {
			
			test '' {}
			settings {}
			def m match Object {}
			}
		'''.parse.testCases.head => [
			3.assertEquals(members.size)
			settings.removeOtherSettingsAndKeepThisOne
			3.assertEquals(members.size)
		]
	}

	@Test
	def void testGetPackageOnTestCase() {
		'''
			def Test testing Object {}
		'''.parse.definitions.head.assertPackage
	}

	@Test
	def void testGetPackageOnMatcher_1() {
		'''
			def matcher match Object {}
		'''.parse.definitions.head.assertPackage
	}

	@Test
	def void testGetPackageOnMatcher_2() {
		'''
			def Test testing Object {
				def matcher match Object {}
			}
		'''.parse.testCases.head.matchers.head.assertPackage
	}

	@Test
	def void testGetQualifiedNameOnTestCase() {
		'''
			def Test testing Object {}
		'''.parse.definitions.head.assertQualifiedName
	}

	@Test
	def void testGetQualifiedNameOnMatcher_1() {
		'''
			def Test match Object {}
		'''.parse.definitions.head.assertQualifiedName
	}

	@Test
	def void testGetQualifiedNameOnMatcher_2() {
		'''
			def Test testing Object {
				def Test match Object
			}
		'''.parse.testCases.head.matchers.head.assertQualifiedName
	}

	@Test
	def void testGetTestCases() {
		'''
			def Test testing Object {}
			
			def Test2 testing Object {}
			
			def Test3 testing Object {}
		'''.parse => [
			definitions.elementsEqual(testCases).assertTrue
		]
	}

	@Test
	def void testGetTestCasesReturnsAllAndOnlyTestCases() {
		'''
			def Test testing Object {}
			
			def matcher match Object {}
			
			def Test2 testing Object {}
		'''.parse => [
			2.assertEquals(testCases.size)
			definitions.filter(AXSTestCase).elementsEqual(testCases).assertTrue
		]
	}

	def void assertQualifiedName(AXSDefinable definable) {
		'__synthetic0.Test'.assertEquals(definable.qualifiedName)
	}

	def void assertPackage(AXSDefinable definable) {
		// the filename given by the ParseHelper
		'__synthetic0'.assertEquals(definable.package)
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
