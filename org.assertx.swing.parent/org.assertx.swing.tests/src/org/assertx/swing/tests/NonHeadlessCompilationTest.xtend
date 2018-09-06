package org.assertx.swing.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.util.JavaVersion
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.junit.Before
import org.junit.Test
import org.junit.runner.JUnitCore
import org.junit.runner.RunWith

import static extension org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(AssertXSwingInjectorProvider)
class NonHeadlessCompilationTest {

	@Inject extension CompilationTestHelper

	@Before
	def void setJavaVersion() {
		// otherwise it doesn't compile lambdas. Maybe default is JAVA7
		javaVersion = JavaVersion.JAVA8
	}

	@Test
	def void testJUnitTestCaseInstantiation() {
		'''
			def Prova testing «ExampleJFrame.canonicalName» {
			
			test 'First test' {
				window.textBox('textToCopy').deleteText
				window.textBox('textToCopy').enterText('Hello!')
				window.button('copyButton').click
				window.label('copiedText').requireText('Hello!')
			}
			}
		'''.compile [
			val result = JUnitCore.runClasses(compiledClass)
			1.assertEquals(result.runCount)
			assertTrue(result.wasSuccessful)
		]
	}
	
	@Test
	def void testBadJUnitTestCaseRunIsNotSuccessfull(){
		'''
			def Prova testing «ExampleJFrame.canonicalName» {
			
			test 'Bad test' {
				window.textBox('textToCopy').deleteText
				window.textBox('textToCopy').enterText('Hello!')
				window.button('copyButton').click
				window.label('copiedText').requireText('Goodbye!')
			}
			}
		'''.compile [
			val result = JUnitCore.runClasses(compiledClass)
			1.assertEquals(result.runCount)
			assertFalse(result.wasSuccessful)
		]
	}
}
