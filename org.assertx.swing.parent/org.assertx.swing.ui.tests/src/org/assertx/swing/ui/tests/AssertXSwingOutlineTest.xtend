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

	override protected createjavaProject(String name) {
		val project = testUtils.createPluginProject(name)
		return JavaCore.create(project)
	}

	override setUp() {
		super.setUp
		waitForBuild
	}

	@Test
	def void testTestCaseWithJustTestedClassType() {
		'''
			def Prova testing javax.swing.JFrame {}
		'''.assertAllLabels('''
			Prova : JFrame
			  window : FrameFixture
		''')
	}

	@Test
	def void testCustomFieldName() {
		'''
			def Prova testing javax.swing.JFrame as frame {}
		'''.assertAllLabels('''
			Prova : JFrame
			  frame : FrameFixture
		''')
	}

	@Test
	def void testSettings() {
		'''
			def Prova testing javax.swing.JFrame {
			
				settings ¸{
					
				}
			}
		'''.assertAllLabels('''
			Prova : JFrame
			  window : FrameFixture
			  Settings
		''')
	}

	@Test
	def void testMethodsWithoutSettings() {
		'''
			def Prova testing javax.swing.JFrame {
			
				test 'my method' {
					
				}
				
				test 'another one' {
					
				}
			}
		'''.assertAllLabels('''
			Prova : JFrame
			  window : FrameFixture
			  my method
			  another one
		''')
	}

	@Test
	def void testOneTestCaseWithJFrame() {
		assertOneTestCase('javax.swing.JFrame', 'JFrame', 'FrameFixture')
	}

	@Test
	def void testNullTestedTypeReference() {
		'''
			def Prova testing
		'''.assertAllLabels('''
			Prova : void
			  window : void
		''')
	}

	@Test
	def void testOneTestCaseWithJDialog() {
		assertOneTestCase('javax.swing.JDialog', 'JDialog', 'DialogFixture')
	}

	@Test
	def void testOneTestCaseWithEmptyTypeReference() {
		assertOneTestCase('', 'void', 'void')
	}

	@Test
	def void testMatcherInTestCase() {
		'javax.swing.JLabel'.assertMatcherInTestCaseTypeString('JLabel')
	}

	@Test
	def void testMatcherInTestCaseEmptyReference() {
		''.assertMatcherInTestCaseTypeString('void')
	}

	@Test
	def void testPackageName() {
		'''
			package org.example.assertxswing
		'''.assertAllLabels(
			'''
				org.example.assertxswing
			'''
		)
	}

	@Test
	def void testImportSection() {
		'''
			import javax.swing.JFrame
			import javax.swing.JDialog
			import java.util.List
		'''.assertAllLabels('''
			import declarations
			  javax.swing.JFrame
			  javax.swing.JDialog
			  java.util.List
		''')
	}

	@Test
	def void testMatcherInFile() {
		'javax.swing.JLabel'.assertMatcherInFile('JLabel')
	}

	@Test
	def void testMatcherInFileEmptyReference() {
		''.assertMatcherInFile('void')
	}

	@Test
	def void testMultipleSettings() {
		'''
			def Prova testing javax.swing.JFrame {
				settings {}
				settings {}
				settings {}
			}
		'''.assertAllLabels(
			'''
				Prova : JFrame
				  window : FrameFixture
				  Settings
				  Settings
				  Settings
			'''
		)
	}

	@Test
	def testCompleteFileStructure() {
		'''
			package org.example
			
			import java.util.List
			import java.io.File
			import javax.swing.JFrame
			
			def Prova testing JFrame {
				test 'm1' {}
				
				settings {}
				
				def badButton match javax.swing.JButton {
					false
				}
			}
			
			def goodButton match javax.swing.JButton {
				true
			}
			
			def TestCase testing javax.swing.JDialog {
				test 'm1' {}
				test 'm2' {}
			}
		'''.assertAllLabels(
		'''
			org.example
			import declarations
			  java.util.List
			  java.io.File
			  javax.swing.JFrame
			Prova : JFrame
			  window : FrameFixture
			  m1
			  Settings
			  badButton : JButton
			goodButton : JButton
			TestCase : JDialog
			  window : DialogFixture
			  m1
			  m2
		''')
	}

	def private assertMatcherInFile(CharSequence matchingType, CharSequence expectedMatcherTypeString) {
		'''
			def finder match «matchingType» {
				true
			}
		'''.assertAllLabels(
			'''
				finder : «expectedMatcherTypeString»
			'''
		)
	}

	def private assertMatcherInTestCaseTypeString(CharSequence matchingType, CharSequence expectedMatcherTypeString) {
		'''
			def Prova testing javax.swing.JFrame {
				def finder match «matchingType» {
					true
				}
			}
		'''.assertAllLabels(
			'''
				Prova : JFrame
				  window : FrameFixture
				  finder : «expectedMatcherTypeString»
			'''
		)
	}

	def private assertOneTestCase(
		CharSequence testedTypeReference,
		CharSequence expectedTestedTypeName,
		CharSequence expectedFieldType
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
			Prova : «expectedTestedTypeName»
			  window : «expectedFieldType»
			  Settings
			  m1
			  m2
		''')
	}

}
