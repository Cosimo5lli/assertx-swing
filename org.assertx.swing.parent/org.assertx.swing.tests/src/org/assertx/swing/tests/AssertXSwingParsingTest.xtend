/*
 * generated by Xtext 2.13.0
 */
package org.assertx.swing.tests

import com.google.inject.Inject
import org.assertx.swing.assertXSwing.AXSTestCase
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import static  extension org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.xtext.xbase.XBlockExpression
import org.eclipse.xtext.xbase.XVariableDeclaration
import org.eclipse.xtext.xbase.XStringLiteral

import static extension org.assertx.swing.AssertXSwingStaticExtensions.*

@RunWith(XtextRunner)
@InjectWith(AssertXSwingInjectorProvider)
class AssertXSwingParsingTest {
	
	@Inject extension ParseHelper<AXSTestCase>
	
	@Test
	def void testRecognizedTypeRef() {
		'''
		testing javax.swing.JFrame
		'''.parse => ['JFrame'.assertEquals(testedTypeRef.simpleName)]
	}
	
	@Test
	def void testEmptyTestCase(){
		'''
		testing javax.swing.JFrame
		'''.parse => [
			settings.assertNull
			tests.empty.assertTrue
		]
	}
	
	@Test
	def void testSettingsSection(){
		'''
		testing javax.swing.JFrame
		
		settings {
			val s = 'Hello'
		}
		'''.parse => [
			settings.assertNotNull()
			val block = (settings.block as XBlockExpression)
			val valDec = (block.expressions.head as XVariableDeclaration)
			's'.assertEquals(valDec.simpleName)
			'Hello'.assertEquals((valDec.right as XStringLiteral).value)
		]
	}
	
	@Test
	def void testEmptyMethodDeclaration(){
		'''
		testing javax.swing.JFrame
		
		test 'Empty test method' {
			
		}
		'''.parse => [
			'Empty test method'.assertEquals(tests.head.name)
			(tests.head.block as XBlockExpression).expressions.empty.assertTrue
		]
	}
	
	@Test
	def void testNonEmptyMethodDeclaration(){
		'''
		testing javax.swing.JFrame
		
		test 'A test method' {
			val s = 'World'
		}
		'''.parse => [
			'A test method'.assertEquals(tests.head.name)
			(tests.head.block as XBlockExpression).expressions.empty.assertFalse
		]
	}
	
	@Test
	def void testUnnamedMethod(){
		'''
		testing javax.swing.JFrame
		
		test {
			val n = null
		}
		'''.parse => [
			'JFrame'.assertEquals(testedTypeRef.simpleName)
			1.assertEquals(tests.length)
			tests.head.name.assertNull
			tests.head.assertNotNull()
			(tests.head.block as XBlockExpression).expressions.empty.assertFalse
		]
	}
	
	@Test
	def void testCustomFieldName(){
		'''
		testing javax.swing.JFrame as custom
		'''.parse =>[
			fieldName.assertNotNull
			'custom'.assertEquals(fieldName)
		]
	}
}
