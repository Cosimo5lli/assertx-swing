package org.assertx.swing.tests

import org.junit.runner.RunWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.InjectWith
import com.google.inject.Inject
import org.eclipse.xtext.testing.formatter.FormatterTestHelper
import org.junit.Test

@RunWith(XtextRunner)
@InjectWith(AssertXSwingInjectorProvider)
class AssertXSwingFormatterTest {
	
	@Inject extension FormatterTestHelper
	
	@Test
	def void testSettingsFormatter(){
		assertFormatted[
			toBeFormatted = '''testing javax.swing.JDialog settings {delayBetweenEvents = 300}'''
			expectation = '''
			testing javax.swing.JDialog
			
			settings {
				delayBetweenEvents = 300
			}
			'''
		]
	}
	
	@Test
	def void testMethodFormatter(){
		assertFormatted[
			toBeFormatted = '''testing javax.swing.JDialog test 'm1'{} test 'm2' {window.button.click}'''
			expectation = '''
			testing javax.swing.JDialog
			
			test 'm1' {
			}
			
			test 'm2' {
				window.button.click
			}
			'''
		]
	}
	
	@Test
	def void testMethodFormatter2(){
		assertFormatted[
			toBeFormatted = '''testing javax.swing.JDialog settings{} test 'm1' {} test 'm2' {}
			
			'''
			expectation = '''
			testing javax.swing.JDialog
			
			settings {
			}
			
			test 'm1' {
			}
			
			test 'm2' {
			}
			'''
		]
	}
	
	@Test
	def void testMatcherFormatter(){
		assertFormatted[
			toBeFormatted = '''testing javax.swing.JFrame match  name:javax.swing.JButton{}'''
			expectation = '''
			testing javax.swing.JFrame
			
			match name : javax.swing.JButton {
			}
			'''
		]
	}
	
	@Test
	def void testFormatImportSection(){
		assertFormatted[
			toBeFormatted = '''
			testing javax.swing.JFrame import javax.swing.JButton import static java.util.List'''
			
			expectation = '''
			testing javax.swing.JFrame
			
			import javax.swing.JButton
			import static java.util.List
			
			'''
		]
	}
	
	@Test
	def void testFormatCompleteTestCase(){
		assertFormatted[
			toBeFormatted = '''
			testing javax.swing.JFrame import javax.swing.JButton import java.util.List test'm1'{window.button.click val i=null}settings{delayBetweenEvents=200}match name:javax.swing.JLabel{val i=0 true}'''
			
			expectation = '''
			testing javax.swing.JFrame
			
			import javax.swing.JButton
			import java.util.List
			
			test 'm1' {
				window.button.click
				val i = null
			}
			
			settings {
				delayBetweenEvents = 200
			}
			
			match name : javax.swing.JLabel {
				val i = 0
				true
			}
			'''
		]
	}
}