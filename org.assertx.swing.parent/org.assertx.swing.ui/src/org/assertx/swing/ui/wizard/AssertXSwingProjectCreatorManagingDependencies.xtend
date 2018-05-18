package org.assertx.swing.ui.wizard

class AssertXSwingProjectCreatorManagingDependencies extends AssertXSwingProjectCreator {

	public static val JUNIT_BUNDLE = 'org.junit'
	public static val ASSERTJ_SWING_BUNDLE = 'org.assertj.swing'

	override getRequiredBundles() {
		val bundles = super.requiredBundles
		bundles.add(JUNIT_BUNDLE)
		bundles.add(ASSERTJ_SWING_BUNDLE)
		return bundles
	}
}
