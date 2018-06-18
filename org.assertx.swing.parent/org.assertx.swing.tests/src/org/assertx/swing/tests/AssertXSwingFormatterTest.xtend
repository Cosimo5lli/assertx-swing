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
			toBeFormatted = '''def Test testing javax.swing.JDialog { settings {delayBetweenEvents = 300}}'''
			expectation = '''
			def Test testing javax.swing.JDialog {
				settings {
					delayBetweenEvents = 300
				}
			}
			'''
		]
	}
	
	@Test
	def void testMethodFormatter(){
		assertFormatted[
			toBeFormatted = '''def Test testing javax.swing.JDialog{ test 'm1'{} test 'm2' {window.button.click}}'''
			expectation = '''
			def Test testing javax.swing.JDialog {
				test 'm1' {
				}
			
				test 'm2' {
					window.button.click
				}
			}
			'''
		]
	}
	
	@Test
	def void testMethodFormatter2(){
		assertFormatted[
			toBeFormatted = '''def Test testing javax.swing.JDialog {settings{} test 'm1' {} test 'm2' {}}
			
			'''
			expectation = '''
			def Test testing javax.swing.JDialog {
				settings {
				}
			
				test 'm1' {
				}
			
				test 'm2' {
				}
			}
			'''
		]
	}
	
	@Test
	def void testMatcherFormatter(){
		assertFormatted[
			toBeFormatted = '''def Test testing javax.swing.JFrame{ def  name match javax.swing.JButton{}}'''
			expectation = '''
			def Test testing javax.swing.JFrame {
				def name match javax.swing.JButton {
				}
			}
			'''
		]
	}
	
	@Test
	def void testFormatImportSection(){
		assertFormatted[
			toBeFormatted = '''
			import javax.swing.JButton import static java.util.List def Test  testing javax.swing.JFrame{}'''
			
			expectation = '''
			import javax.swing.JButton
			import static java.util.List
			
			def Test testing javax.swing.JFrame {
			}
			'''
		]
	}
	
	@Test
	def void testFormatCompleteTestCase(){
		assertFormatted[
			toBeFormatted = '''
			import javax.swing.JButton
			import java.util.List
			
			def Test testing javax.swing.JFrame {
				test 'm1' {
					window.button.click
					val i = null
				}
			
				settings {
					delayBetweenEvents = 200
				}
			
				def name match javax.swing.JLabel {
					val i = 0
					true
				}
			}
			'''
		]
	}
}