package org.assertx.swing.ui.wizard;

import org.assertx.swing.ui.wizard.AssertXSwingNewProjectWizard;
import org.eclipse.xtext.ui.wizard.IExtendedProjectInfo;
import org.eclipse.xtext.ui.wizard.IProjectCreator;

import com.google.inject.Inject;

public class AssertXSwingTestableNewProjectWizard extends AssertXSwingNewProjectWizard {

	public static final String PROJECT_NAME = "TestProject";
	
	@Inject
	public AssertXSwingTestableNewProjectWizard(IProjectCreator projectCreator) {
		super(projectCreator);
	}
	
	@Override
	public IExtendedProjectInfo getProjectInfo() {
		IExtendedProjectInfo info = super.getProjectInfo();
		info.setProjectName(PROJECT_NAME);
		return info;
	}

}
