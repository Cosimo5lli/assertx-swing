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
	
}