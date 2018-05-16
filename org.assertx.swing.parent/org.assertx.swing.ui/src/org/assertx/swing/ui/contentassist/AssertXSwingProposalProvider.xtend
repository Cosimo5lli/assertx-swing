/*
 * generated by Xtext 2.13.0
 */
package org.assertx.swing.ui.contentassist

import com.google.inject.Inject
import javax.swing.JDialog
import javax.swing.JFrame
import org.assertx.swing.assertXSwing.AXSTestCase
import org.assertx.swing.assertXSwing.AssertXSwingPackage
import org.eclipse.emf.ecore.EObject
import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.common.types.JvmType
import org.eclipse.xtext.common.types.access.IJvmTypeProvider
import org.eclipse.xtext.common.types.xtext.ui.TypeMatchFilters
import org.eclipse.xtext.common.types.xtext.ui.TypeMatchFilters.AbstractFilter
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier

import static extension org.assertx.swing.AssertXSwingStaticExtensions.*

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class AssertXSwingProposalProvider extends AbstractAssertXSwingProposalProvider {
	
	@Inject IJvmTypeProvider.Factory typeProviderFactory
	
	override void completeJvmParameterizedTypeReference_Type(EObject model, Assignment assignment,
			ContentAssistContext context, ICompletionProposalAcceptor acceptor){
		
		if(EcoreUtil2.getContainerOfType(model, AXSTestCase) !== null){
			val typeProvider = typeProviderFactory.createTypeProvider(model.eResource.resourceSet)
			
			val jFrameType = typeProvider.findTypeByName(JFrame.name)
			createSubTypeProposal(jFrameType, context, acceptor)
			
			val jDialogType = typeProvider.findTypeByName(JDialog.name)
			createSubTypeProposal(jDialogType, context, acceptor)
		} else {
			super.completeJvmParameterizedTypeReference_Type(model, assignment, context, acceptor)
		}
	}
	
	override void completeXBlockExpression_Expressions(EObject model, Assignment assignment,
			ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		
		super.completeXBlockExpression_Expressions(model, assignment,context, new FeatureCallDelegate(acceptor))
	}
	
	override void completeXFeatureCall_Feature(EObject model, Assignment assignment, ContentAssistContext context,
			ICompletionProposalAcceptor acceptor){

		super.completeXFeatureCall_Feature(model, assignment, context, new FeatureCallDelegate(acceptor))
	}
	
	override void completeXMemberFeatureCall_Feature(EObject model, Assignment assignment, ContentAssistContext context,
			ICompletionProposalAcceptor acceptor){
		
		super.completeXMemberFeatureCall_Feature(model, assignment, context, new FeatureCallDelegate(acceptor))
	}
	
	private def void createSubTypeProposal(JvmType jvmType, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		// filter off some classes used internally by swing, like print dialog, and one used 
		// by AssertJ Swing to test applets in a JFrame
		val AbstractFilter filter = [
			// $1 is an array of char, representing the complete name of the package
			val packName = $1.join
			!packName.startsWith('sun.print') &&
			 !packName.startsWith('sun.awt.im') && 
			 !packName.startsWith('org.assertj.')
		]
		
		typesProposalProvider.createSubTypeProposals(
			jvmType,
			this,
			context,
			AssertXSwingPackage.eINSTANCE.AXSTestCase_TestedTypeRef,
			TypeMatchFilters.and(TypeMatchFilters.canInstantiate, 
				TypeMatchFilters.public, 
				TypeMatchFilters.acceptableByPreference,
				filter
			),
			acceptor
		)
	}
	
	static class FeatureCallDelegate extends ICompletionProposalAcceptor.Delegate {
				
		new(ICompletionProposalAcceptor delegate){
			super(delegate)
		}
		
		override accept(ICompletionProposal prop){
			
			if(prop === null) return
			
			var proposed = if(prop instanceof ConfigurableCompletionProposal){
				val textApplier = prop.textApplier
				if(textApplier instanceof ReplacementTextApplier){
					textApplier.getActualReplacementString(prop)
				} else {
					prop.replacementString
				}
			} else {
				prop.displayString
			}
			
			if(!proposed.autogeneratedMethodName){
				super.accept(prop)
			}
		}
	}
}
