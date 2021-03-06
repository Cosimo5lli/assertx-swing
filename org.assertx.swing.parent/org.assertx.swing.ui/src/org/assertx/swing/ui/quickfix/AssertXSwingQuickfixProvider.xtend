/*
 * generated by Xtext 2.13.0
 */
package org.assertx.swing.ui.quickfix

import org.assertx.swing.assertXSwing.AXSSettings
import org.assertx.swing.assertXSwing.AXSTestCase
import org.assertx.swing.assertXSwing.AXSTestMethod
import org.assertx.swing.validation.AssertXSwingValidator
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.xbase.ui.quickfix.XbaseQuickfixProvider

import static extension org.assertx.swing.util.AssertXSwingStaticExtensions.*

/**
 * Custom quickfixes.
 * 
 * See https://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#quick-fixes
 */
class AssertXSwingQuickfixProvider extends XbaseQuickfixProvider {

	@Fix(AssertXSwingValidator.EMPTY_SETTINGS_SECTION)
	def void removeEmptySettingsSection(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(
			issue,
			'Remove settings section',
			'Remove the empty settings section from this test case',
			''
		) [ element, context |
			(element.eContainer as AXSTestCase).removeSettings
		]
	}

	@Fix(AssertXSwingValidator.AUTOGENERATED_METHOD_ACCESSED)
	def void removeReferenceToMethod(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(
			issue,
			'Remove reference to this method',
			'Remove the reference to this method',
			''
		) [ context |
			val document = context.xtextDocument
			document.replace(issue.offset, issue.length, '')
		]
	}

	@Fix(AssertXSwingValidator.NULL_METHOD_NAME)
	@Fix(AssertXSwingValidator.EMPTY_METHOD_NAME)
	def void createDummyName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(
			issue,
			'Give this test a name',
			'''
				...
				test 'my test' {
					...
				}
				...
			''',
			''
		) [ element, context |
			EcoreUtil2.getContainerOfType(element, AXSTestMethod).name = 'my test'
		]
	}

	@Fix(AssertXSwingValidator.TOO_MANY_SETTINGS)
	def void removeOtherSettingsDefinitions(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(
			issue,
			'Remove other settings definitions',
			'Keep only this as settings definition and remove other ones from this test case',
			''
		) [ element, context |
			(element as AXSSettings).removeOtherSettingsAndKeepThisOne
		]
	}
}
