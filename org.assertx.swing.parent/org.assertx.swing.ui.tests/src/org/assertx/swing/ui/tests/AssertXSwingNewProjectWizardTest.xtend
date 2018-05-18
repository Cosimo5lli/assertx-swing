package org.assertx.swing.ui.tests

import com.google.inject.Inject
import com.google.inject.Provider
import org.assertx.swing.ui.wizard.AssertXSwingTestableNewProjectWizard
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.jface.wizard.Wizard
import org.eclipse.jface.wizard.WizardDialog
import org.eclipse.ui.PlatformUI
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.ui.testing.AbstractWorkbenchTest
import org.example.testutils.PDETargetPlatformUtils
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith

import static org.assertx.swing.ui.tests.AssertXSwingUiTestUtils.*
import static org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil.*

@RunWith(XtextRunner)
@InjectWith(AssertXSwingUiInjectorProvider)
class AssertXSwingNewProjectWizardTest extends AbstractWorkbenchTest {

	@Inject Provider<AssertXSwingTestableNewProjectWizard> projectWizardProvider

	@BeforeClass
	def static void setTargetPlatform() {
		PDETargetPlatformUtils.setTargetPlatform
	}

	def protected int createAndFinishWizardDialog(Wizard wizard) {
		val dialog = new WizardDialog(wizard.shell, wizard) {
			override open() {
				val thread = new Thread("Press Finish") {
					override run() {
						// wait for the shell to become active
						while (getShell() === null) {
							Thread.sleep(1000)
						}
						getShell().getDisplay().asyncExec [
							finishPressed();
						]
					}
				};
				thread.start();
				return super.open();
			}
		};
		return dialog.open();
	}

	@Test
	def void testAssertXSwingNewProjectWizard() {
		createProjectWithNewProjectWizard
		assertNoErrors
	}

	def private createProjectWithNewProjectWizard() {
		val wizard = projectWizardProvider.get
		wizard.init(PlatformUI.getWorkbench(), new StructuredSelection());
		createAndFinishWizardDialog(wizard)
		val project = root.getProject(AssertXSwingTestableNewProjectWizard.PROJECT_NAME)
		assertTrue(project.exists())
		cleanBuild
		waitForBuild
		return project
	}
}
