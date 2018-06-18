/*
 * generated by Xtext 2.13.0
 */
package org.assertx.swing.tests

import com.google.inject.Inject
import org.assertx.swing.assertXSwing.AXSFile
import org.assertx.swing.assertXSwing.AXSMatcherRef
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.xbase.XBlockExpression
import org.eclipse.xtext.xbase.XStringLiteral
import org.eclipse.xtext.xbase.XVariableDeclaration
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.assertx.swing.util.AssertXSwingStaticExtensions.*
import static extension org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(AssertXSwingInjectorProvider)
class AssertXSwingParsingTest {

	@Inject extension ParseHelper<AXSFile>

	@Test
	def void testRecognizedTypeRef() {
		'''
			def Test testing javax.swing.JFrame
		'''.parse.testCases.head => ['JFrame'.assertEquals(typeRef.simpleName)]
	}

	@Test
	def void testEmptyTestCase() {
		'''
			def Test testing javax.swing.JFrame
		'''.parse.testCases.head => [
			members.empty.assertTrue
		]
	}

	@Test
	def void testSettingsSection() {
		'''
			def Test testing javax.swing.JFrame {
			
			settings {
				val s = 'Hello'
			}
			}
		'''.parse.testCases.head => [
			settings.assertNotNull()
			val block = (settings.block as XBlockExpression)
			val valDec = (block.expressions.head as XVariableDeclaration)
			's'.assertEquals(valDec.simpleName)
			'Hello'.assertEquals((valDec.right as XStringLiteral).value)
		]
	}

	@Test
	def void testEmptyMethodDeclaration() {
		'''
			def Test testing javax.swing.JFrame {
			
			test 'Empty test method' {
				
			}
			}
		'''.parse.testCases.head => [
			'Empty test method'.assertEquals(tests.head.name)
			(tests.head.block as XBlockExpression).expressions.empty.assertTrue
		]
	}

	@Test
	def void testNonEmptyMethodDeclaration() {
		'''
			def Test testing javax.swing.JFrame {
			
			test 'A test method' {
				val s = 'World'
			}
			}
		'''.parse.testCases.head => [
			'A test method'.assertEquals(tests.head.name)
			(tests.head.block as XBlockExpression).expressions.empty.assertFalse
		]
	}

	@Test
	def void testUnnamedMethod() {
		'''
			def Test testing javax.swing.JFrame {
			
			test {
				val n = null
			}
			}
		'''.parse.testCases.head => [
			'JFrame'.assertEquals(typeRef.simpleName)
			1.assertEquals(tests.length)
			tests.head.name.assertNull
			tests.head.assertNotNull()
			(tests.head.block as XBlockExpression).expressions.empty.assertFalse
		]
	}

	@Test
	def void testCustomFieldName() {
		'''
			def Test testing javax.swing.JFrame as custom
		'''.parse.testCases.head => [
			fieldName.assertNotNull
			'custom'.assertEquals(fieldName)
		]
	}

	@Test
	def void testMatcherParsing() {
		'''
			def Test testing javax.swing.JFrame {
			
			def matcherName match javax.swing.JButton {
				
			}
			}
		'''.parse.testCases.head.getMatchers => [
			1.assertEquals(size)
			'matcherName'.assertEquals(head.name)
			'javax.swing.JButton'.assertEquals(head.typeRef.qualifiedName)
		]
	}

	@Test
	def void testMatcherRef() {
		'''
			def Test testing javax.swing.JFrame {
			
			test 'a test' {
				?matcherName?
			}
			
			def matcherName match javax.swing.JButton {
				
			}
			}
		'''.parse.testCases.head.tests.head.block => [
			assertTrue((it as XBlockExpression).expressions.head instanceof AXSMatcherRef)
		]
	}
}
