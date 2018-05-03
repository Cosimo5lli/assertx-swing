package org.assertx.swing.tests

import com.google.inject.Inject
import org.assertx.swing.assertXSwing.AXSTestCase
import org.assertx.swing.assertXSwing.AssertXSwingPackage
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith
import org.assertx.swing.validation.AssertXSwingValidator
import org.eclipse.xtext.xbase.XbasePackage

@RunWith(XtextRunner)
@InjectWith(AssertXSwingInjectorProvider)
class AssertXSwingValidationTest {
	
	@Inject extension ParseHelper<AXSTestCase>
	
	@Inject extension ValidationTestHelper
	
	@Test
	def void testWarningOnMethodWithSameName(){
		val name = "'Good name'"
		val input = '''
		testing «ExampleJFrame.canonicalName»
		
		test «name» {}
		
		test «name» {}
		'''
		
		input.parse => [
			assertWarning(
				AssertXSwingPackage.eINSTANCE.AXSTestMethod, AssertXSwingValidator.SAME_NAME_METHODS,
				input.indexOf(name),
				name.length,
				'Duplicate method ' + name + ': methods should use different and explanatory names'
			)
			assertWarning(
				AssertXSwingPackage.eINSTANCE.AXSTestMethod, AssertXSwingValidator.SAME_NAME_METHODS,
				input.lastIndexOf(name),
				name.length,
				'Duplicate method ' + name + ': methods should use different and explanatory names'
			)
		]
	}
	
	@Test
	def void testNoWarningOnMethodsWhichCompilesToSameIdsButHaveDifferentNames(){
		'''
		testing «ExampleJFrame.canonicalName»
		
		test 'Method 1' {}
		
		test 'method 1' {}
		'''.parse.assertNoErrors
	}
	
	@Test
	def void testWindowFieldIsAccessibleFromTestMethodBody(){
		'''
		testing «ExampleJFrame.canonicalName»
		
		test 'm' {
			window.button('copyButton')
		}
		'''.parse.assertNoErrors
	}
	
	@Test
	def void testCustomFieldIsAccessibleFromTestMethodBody(){
		'''
		testing «ExampleJFrame.canonicalName» as custom
		
		test 'l' {
			custom.button('copyButton')
		}
		'''.parse.assertNoErrors
	}
	
	@Test
	def void testClassMustBeSubclassOfJFrame(){
		val wrongClass = 'java.lang.Object'
		val input = '''
		testing «wrongClass»
		'''
		
		input.parse.assertError(AssertXSwingPackage.eINSTANCE.AXSTestCase,
			AssertXSwingValidator.UNTESTABLE_TYPE,
			input.indexOf(wrongClass), wrongClass.length,
			"Untestable type: the class under test must be a subclass of either 'javax.swing.JFrame', 'javax.swing.JDialog' or 'javax.swing.JWindow'"
		)
	}
	
	@Test
	def void testCorrectTestClassIsAccepted(){
		'''
		testing «ExampleJFrame.canonicalName»
		'''.parse.assertNoErrors
	}
	
	@Test
	def void testNullMethodName(){
		'''
		testing «ExampleJFrame.canonicalName»
		
		test {
			window.button('copyButton')
		}
		'''.parse.assertError(XbasePackage.eINSTANCE.XBlockExpression, 
			AssertXSwingValidator.NULL_METHOD_NAME,
			'Missing method name after "test" keyword'
		)
	}
}