package org.assertx.swing.ui.tests

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.core.resources.IMarker
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.ui.XtextProjectHelper
import org.eclipse.xtext.ui.util.PluginProjectFactory

import static org.eclipse.xtext.ui.testing.util.IResourcesSetupUtil.*
import static org.junit.Assert.*

class AssertXSwingUiTestUtils {

	@Inject Provider<PluginProjectFactory> projectFactoryProvider

	def IProject createPluginProject(String name) {
		val projectFactory = projectFactoryProvider.get
		projectFactory.breeToUse = 'JavaSE-1.8'
		projectFactory.withPluginXml = false
		projectFactory.projectName = name
		projectFactory.addFolders(#["src", "src-gen"]);

		projectFactory.addBuilderIds(
			JavaCore.BUILDER_ID,
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

		return projectFactory.createProject(monitor, null)
	}

	def static assertNoErrors() {
		val markers = getErrorMarkers()
		assertEquals(
			"unexpected errors:\n" + markers.map[getAttribute(IMarker.MESSAGE)].join('''

			'''),
			0,
			markers.size
		)
	}

	def static getErrorMarkers() {
		root.findMarkers(IMarker.PROBLEM, true, IResource.DEPTH_INFINITE).filter [
			getAttribute(IMarker.SEVERITY, IMarker.SEVERITY_INFO) == IMarker.SEVERITY_ERROR
		]
	}
}
