package org.assertx.swing.ui.tests

import com.google.inject.Inject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.ui.testing.AbstractOutlineTest
import org.junit.Test
import org.junit.runner.RunWith

import static org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil.*

@RunWith(XtextRunner)
@InjectWith(AssertXSwingUiInjectorProvider)
class AssertXSwingOutlineTest extends AbstractOutlineTest {
	
	@Inject AssertXSwingUiTestUtils testUtils
	
	override protected getEditorId() {
		'org.assertx.swing.AssertXSwing'
	}
	
	override protected createjavaProject(String name){
		val project = testUtils.createPluginProject(name)
		return JavaCore.create(project)
	}
	
	override setUp(){
		super.setUp
		waitForBuild
	}
	
	@Test
	def void testOnlyTestedClass(){
		'''
		def Prova testing javax.swing.JFrame {}
		'''.assertAllLabels('''
		Prova : Test Case
		  JFrame
		  window : FrameFixture
		''')
	}
	
	@Test
	def void testCustomFieldName(){
		'''
		def Prova testing javax.swing.JFrame as frame {}
		'''.assertAllLabels('''
		Prova : Test Case
		  JFrame
		  frame : FrameFixture
		''')
	}
	
	@Test
	def void testSettings(){
		'''
		def Prova testing javax.swing.JFrame {
		
			settings ¸{
				
			}
		}
		'''.assertAllLabels('''
		Prova : Test Case
		  JFrame
		  window : FrameFixture
		  Settings
		''')
	}
	
	@Test
	def void testMethodsWithoutSettings(){
		'''
		def Prova testing javax.swing.JFrame {
		
			test 'my method' {
				
			}
			
			test 'another one' {
				
			}
		}
		'''.assertAllLabels('''
		Prova : Test Case
		  JFrame
		  window : FrameFixture
		  my method : Test
		  another one : Test
		''')
	}
	
	@Test
	def void testCompleteStructureWithJFrame(){
		assertCompleteStructure('javax.swing.JFrame', 'JFrame', 'FrameFixture')
	}
	
	@Test
	def void testNullTestedTypeReference(){
		'''
		def Prova testing
		'''.assertAllLabels('''
		Prova : Test Case
		  void
		  window : void
		''')
	}
	
	@Test
	def void testCompleteStructureWithJDialog(){
		assertCompleteStructure('javax.swing.JDialog', 'JDialog', 'DialogFixture')
	}
		
	@Test
	def void testCompleteStructureWithEmptyTypeReference(){
		assertCompleteStructure('', 'void', 'void')	
	}
	
	def private assertCompleteStructure(CharSequence testedTypeReference, 
		CharSequence expectedTestedTypeName, CharSequence expectedFieldType
	) {
		'''
		def Prova testing «testedTypeReference» {
			settings {
				
			}
			
			test 'm1' {
				
			}
			
			test 'm2' {
				
			}
		}
		'''.assertAllLabels('''
		Prova : Test Case
		  «expectedTestedTypeName»
		  window : «expectedFieldType»
		  Settings
		  m1 : Test
		  m2 : Test
		''')
	}
	
}