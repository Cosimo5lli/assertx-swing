package org.assertx.swing.ui.tests

import com.google.inject.Inject
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.ui.testing.AbstractContentAssistTest
import org.eclipse.xtext.ui.testing.ContentAssistProcessorTestBuilder
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*
import org.example.testutils.PDETargetPlatformUtils
import org.junit.BeforeClass

@RunWith(XtextRunner)
@InjectWith(AssertXSwingUiInjectorProvider)
class AssertXSwingContentAssistTest extends AbstractContentAssistTest {
	
	var IJavaProject project
	
	@Inject AssertXSwingUiTestUtils testUtils
	
	@BeforeClass
	def static void setTargetPlatform(){
		PDETargetPlatformUtils.setTargetPlatform
	}
	
	@Before
	def void init(){
		project = JavaCore.create(testUtils.createPluginProject('contentAssistTest'))
	}
	
	@After
	def void clear(){
		project.project.delete(true, new NullProgressMonitor)
	}
	
	override getJavaProject(ResourceSet set){
		project
	}
	
	@Test
	def void testCompletionInEmptyTestMethodBody(){
		newBuilder.withDirtyState.append('''
		testing javax.swing.JFrame
		
		settings {
			
		}
		
		test 'my method' {
			<|>
		}
		''').assertTextAtCursorIndicator('class', 'clone', 'do', 'emptyList', 'emptyMap', 'emptySet', 'equals', 
			'false', 'finalize', 'for', 'hashCode', 'identityEquals()', 'if', 'myMethod', 'new',
			 'newArrayList', 'newArrayList()', 'newArrayOfSize()', 'newBooleanArrayOfSize()', 
			 'newByteArrayOfSize()', 'newCharArrayOfSize()', 'newDoubleArrayOfSize()', 'newFloatArrayOfSize()', 
			 'newHashMap', 'newHashMap()', 'newHashSet', 'newHashSet()', 'newImmutableList()', 
			 'newImmutableMap()', 'newImmutableSet()', 'newIntArrayOfSize()', 'newLinkedHashMap', 
			 'newLinkedHashMap()', 'newLinkedHashSet', 'newLinkedHashSet()', 'newLinkedList', 
			 'newLinkedList()', 'newLongArrayOfSize()', 'newShortArrayOfSize()', 'newTreeMap()', 
			 'newTreeMap()', 'newTreeSet()', 'newTreeSet()', 'notify', 'notifyAll', 'null', 'print()', 
			 'println', 'println()', 'return', 'super', 'switch', 'synchronized', 'this', 'throw', 
			 'toString', 'true', 'try', 'typeof', 'val', 'var', 'wait', 'wait()', 'wait()', 'while', 'window')
	}
	
	@Test
	def void testClassUnderTestCompletion(){
		newBuilder.withDirtyState.append('''
		testing <|>
		''').assertTextAtCursorIndicator('javax.swing.JDialog', 'javax.swing.JFrame')
	}
	
	@Test
	def void testMethodCompletion(){
		newBuilder.withDirtyState.append('''
		testing javax.swing.JFrame
		
		test 'my method' {
			s<|>
		}
		''').assertTextAtCursorIndicator('super', 'switch', 'synchronized')
	}
	
	@Test
	def void testMemberMethodCompletion(){
		newBuilder.withDirtyState.append('''
		testing javax.swing.JFrame
		
		settings {
			
		}
		
		test 'my method' {
			this.<|>
		}
		''').assertTextAtCursorIndicator('class', 'clone', 'equals', 'finalize', 
			'hashCode', 'identityEquals()', 'myMethod', 'notify', 'notifyAll', 'toString', 
			'wait', 'wait()', 'wait()', 'window'
		)
	}
	
	def private assertTextAtCursorIndicator(extension ContentAssistProcessorTestBuilder model, String... expectedElements){
		val proposals = model.proposalsAtCursorIndicator.toString
		val expected = expectedElements.toList
		expected.sort
		proposals.sort
		if(!proposals.elementsEqual(expectedElements))
			fail('Expected <' + expected + '> but got <' + proposals + '>')
	}
}