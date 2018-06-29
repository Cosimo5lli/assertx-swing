package org.assertx.swing.ui.tests

import com.google.inject.Inject
import java.util.List
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.ui.testing.AbstractContentAssistTest
import org.eclipse.xtext.ui.testing.ContentAssistProcessorTestBuilder
import org.example.testutils.PDETargetPlatformUtils
import org.junit.After
import org.junit.Before
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith

import static org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil.*

import static extension org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(AssertXSwingUiInjectorProvider)
class AssertXSwingContentAssistTest extends AbstractContentAssistTest {

	var IJavaProject project

	@Inject AssertXSwingUiTestUtils testUtils
	
	@BeforeClass
	def static void setTargetPlatform() {
		PDETargetPlatformUtils.setTargetPlatform
	}

	@Before
	def void init() {
		project = JavaCore.create(testUtils.createPluginProject('contentAssistTest'))
		waitForBuild
	}

	@After
	def void clear() {
		project.project.delete(true, new NullProgressMonitor)
	}

	override getJavaProject(ResourceSet set) {
		project
	}
	
	@Test
	def void testCompletionInEmptyTestMethodBody() {
		newBuilder.withDirtyState.append('''
			def Prova testing javax.swing.JFrame {
			
				settings {
					
				}
			
				test 'my method' {
					<|>
				}
			}
		''').assertTextAtCursorIndicator('class', 'clone', 'do', 'emptyList', 'emptyMap', 'emptySet', 'equals', 'false',
			'finalize', 'for', 'hashCode', 'identityEquals()', 'if', 'myMethod', 'new', 'newArrayList',
			'newArrayList()', 'newArrayOfSize()', 'newBooleanArrayOfSize()', 'newByteArrayOfSize()',
			'newCharArrayOfSize()', 'newDoubleArrayOfSize()', 'newFloatArrayOfSize()', 'newHashMap', 'newHashMap()',
			'newHashSet', 'newHashSet()', 'newImmutableList()', 'newImmutableMap()', 'newImmutableSet()',
			'newIntArrayOfSize()', 'newLinkedHashMap', 'newLinkedHashMap()', 'newLinkedHashSet', 'newLinkedHashSet()',
			'newLinkedList', 'newLinkedList()', 'newLongArrayOfSize()', 'newShortArrayOfSize()', 'newTreeMap()',
			'newTreeMap()', 'newTreeSet()', 'newTreeSet()', 'notify', 'notifyAll', 'null', 'print()', 'println',
			'println()', 'return', 'super', 'switch', 'synchronized', 'this', 'throw', 'toString', 'true', 'try',
			'typeof', 'val', 'var', 'wait', 'wait()', 'wait()', 'while', 'window')
	}

	@Test
	def void testClassUnderTestCompletion() {
		newBuilder.append('''
			def Prova testing <|>
		''').assertTextAtCursorIndicator('javax.swing.JDialog', 'javax.swing.JFrame')
	}

	@Test
	def void testMethodCompletion() {
		newBuilder.withDirtyState.append('''
			def Prova testing javax.swing.JFrame {
			
				test 'my method' {
					_<|>
				}
			}
		''').assertTextAtCursorIndicator()
	}

	@Test
	def void testMemberMethodCompletion() {
		newBuilder.withDirtyState.append('''
			def Prova testing javax.swing.JFrame {
			
				settings {
					
				}
			
				test 'my method' {
					this.<|>
				}
			}
		''').assertTextAtCursorIndicator(
			'class',
			'clone',
			'equals',
			'finalize',
			'hashCode',
			'identityEquals()',
			'myMethod',
			'notify',
			'notifyAll',
			'toString',
			'wait',
			'wait()',
			'wait()',
			'window'
		)
	}

	@Test
	def void testDoProposeCorrectTypesCompletingTypeReferenceOfMatchers() {
		newBuilder.withDirtyState.append('''
			def Prova testing javax.swing.JFrame {
			
				def newMatcher match <|> {
					true
				}
			}
		''').assertAtCursorAtLeast('javax.swing.JButton', 'javax.swing.JFrame', 'javax.swing.JDialog',
			'javax.swing.JLabel')
	}

	@Test
	def void testNoIncompatibleProposalCompletingTypeReferenceOfMatchers() {
		newBuilder.withDirtyState.append('''
			def Prova testing javax.swing.JFrame {
			
				match newMatcher : <|> {
					true
				}
			}
		''').assertNoProposalsAtCursor('java.lang.Double', 'java.lang.Object', 'java.lang.String')
	}

	def assertNoProposalsAtCursor(extension ContentAssistProcessorTestBuilder builder, String... unexpectedElements) {
		builder.computeProposalsAndTest('found unexpected proposals',
			unexpectedElements)[proposals, elem| proposals.contains(elem)]
	}

	def private assertAtCursorAtLeast(ContentAssistProcessorTestBuilder builder, String... expectedElements) {
		builder.computeProposalsAndTest('missing expected proposals',
			expectedElements)[proposals, elem| !proposals.contains(elem)]
	}

	def private computeProposalsAndTest(extension ContentAssistProcessorTestBuilder builder, String message,
		String[] elements, (List<String>, String)=>boolean test) {
		val proposals = builder.proposalsAtCursorIndicator.toString
		val tested = newLinkedList
		for (e : elements) {
			if (test.apply(proposals, e)) {
				tested += e
			}
		}
		if (tested.size > 0) {
			fail(message + ' <' + tested + '> in <' + proposals + '>')
		}
	}

	def private assertTextAtCursorIndicator(extension ContentAssistProcessorTestBuilder model,
		String... expectedElements) {
		val proposals = model.proposalsAtCursorIndicator.toString
		val expectedString = expectedElements.sort.join(', ')
		val proposedString = proposals.sort.join(', ')
		expectedString.assertEquals(proposedString)
	}
}
