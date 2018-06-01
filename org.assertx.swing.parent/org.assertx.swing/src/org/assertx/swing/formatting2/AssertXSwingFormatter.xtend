/*
 * generated by Xtext 2.13.0
 */
package org.assertx.swing.formatting2

import org.assertx.swing.assertXSwing.AXSMatcher
import org.assertx.swing.assertXSwing.AXSSettings
import org.assertx.swing.assertXSwing.AXSTestCase
import org.assertx.swing.assertXSwing.AXSTestMethod
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.xbase.formatting2.XbaseFormatter

import static org.assertx.swing.assertXSwing.AssertXSwingPackage.Literals.*

class AssertXSwingFormatter extends XbaseFormatter {

	def dispatch void format(AXSTestCase testCase, extension IFormattableDocument document) {
		testCase.regionFor.keyword('testing').prepend[noSpace].append[oneSpace]
		testCase.testedTypeRef.format;
		testCase.testedTypeRef.append[newLines = 2]
		testCase.imports.format
		testCase.imports.append[newLines = 2]
		val members = testCase.members
		val last = members.last
		for (member : members) {
			member.format;
			if (member === last) {
				member.append[newLine]
			} else {
				member.append[newLines = 2]
			}
		}
	}

	def dispatch void format(AXSTestMethod testMethod, extension IFormattableDocument document) {
		testMethod.regionFor.keyword('test').prepend[noSpace].append[oneSpace]
		testMethod.regionFor.feature(AXS_TEST_METHOD__NAME).surround[oneSpace]
		testMethod.block.format;
	}

	def dispatch void format(AXSSettings settings, extension IFormattableDocument document) {
		settings.regionFor.keyword('settings').prepend[noSpace].append[oneSpace]
		settings.block.format
	}

	def dispatch void format(AXSMatcher matcher, extension IFormattableDocument document) {
		matcher.regionFor.keyword('match').prepend[noSpace].append[oneSpace]
		matcher.regionFor.feature(AXS_MATCHER__NAME).surround[oneSpace]
		matcher.regionFor.keyword(':').surround[oneSpace]
		matcher.type.format
		matcher.type.surround[oneSpace]
		matcher.matchingExpression.format
	}
}
