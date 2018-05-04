package org.assertx.swing.ui.tests

import org.eclipse.core.resources.IProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.ui.XtextProjectHelper
import com.google.inject.Inject
import org.eclipse.xtext.ui.util.PluginProjectFactory
import org.eclipse.core.runtime.NullProgressMonitor

class AssertXSwingUiTestUtils {
	
	@Inject PluginProjectFactory projectFactory
		
	def IProject createPluginProject(String name) {
		projectFactory.breeToUse = 'JavaSE-1.8'
		projectFactory.withPluginXml = false
		projectFactory.projectName = name
		projectFactory.addFolders(#["src"]);
		
		projectFactory.addBuilderIds(JavaCore.BUILDER_ID,
			"org.eclipse.pde.ManifestBuilder",
			"org.eclipse.pde.SchemaBuilder",
			XtextProjectHelper.BUILDER_ID
		)
		projectFactory.addProjectNatures(
			JavaCore.NATURE_ID,
			"org.eclipse.pde.PluginNature",
			XtextProjectHelper.NATURE_ID
		)
		projectFactory.addRequiredBundles(#['org.junit', 'org.assertj.swing', 'org.eclipse.xtext.xbase.lib'])
		
		return projectFactory.createProject(new NullProgressMonitor(),	null)
	}
}