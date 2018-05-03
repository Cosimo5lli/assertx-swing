package org.assertx.swing.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.util.JavaVersion
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.junit.Before
import org.junit.Test
import org.junit.runner.JUnitCore
import org.junit.runner.RunWith

import static extension org.junit.Assert.*
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.junit.runners.JUnit4
import org.junit.runner.notification.RunNotifier

@RunWith(XtextRunner)
@InjectWith(AssertXSwingInjectorProvider)
class AssertXSwingCompilationTest {
	
	static val WINDOW_FULLY_QUALIFIED_NAME = 'org.assertx.swing.tests.ExampleJFrame'

	@Inject extension CompilationTestHelper
	
	@Inject ReflectExtensions rex

	@Before
	def void setJavaVersion() {
		// otherwise it doesn't compile lambdas. Maybe default is JAVA7
		javaVersion = JavaVersion.JAVA8
	}

	@Test
	def void testEmptyTestCase() {
		'''
			testing «WINDOW_FULLY_QUALIFIED_NAME»
		'''.assertCompilesTo(
			'''
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.assertx.swing.tests.ExampleJFrame;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			
			@SuppressWarnings("all")
			public class ExampleJFrameTest {
			  private FrameFixture window;
			  
			  @BeforeClass
			  public void beforeClass() {
			    FailOnThreadViolationRepaintManager.install();
			  }
			  
			  @Before
			  public void setup() {
			    ExampleJFrame frame = GuiActionRunner.execute(() -> new ExampleJFrame());
			    this.window = new FrameFixture(frame);
			  }
			  
			  @After
			  public void cleanUp() {
			    this.window.cleanUp();
			  }
			}
			''')
	}

	@Test
	def void testMethodNameTranslation() {
		'''
			testing «WINDOW_FULLY_QUALIFIED_NAME»
			
			test '1234' {}
			
			test 'should i even write this?' {}
			
			test "It works!?! Yes!"
			
			test 'MiXing uP'
			
			test ',.-@##+'
		'''.compile [
			val methods = compiledClass.methods.filter [
				if(annotations.empty) false else Test.equals(annotations.head.annotationType)
			].sortBy[name]
			5.assertEquals(methods.length)
			'_'.assertEquals(methods.get(0).name)
			'_1234'.assertEquals(methods.get(1).name)
			'itWorksYes'.assertEquals(methods.get(2).name)
			'miXingUP'.assertEquals(methods.get(3).name)
			'shouldIEvenWriteThis'.assertEquals(methods.get(4).name)
		]
	}

	@Test
	def void testJUnitTestCaseInstantiation() {
		'''
			testing «WINDOW_FULLY_QUALIFIED_NAME»
			
			test 'First test' {
				window.textBox('textToCopy').deleteText
				window.textBox('textToCopy').enterText('Ciao!')
				window.button('copyButton').click
				window.label('copiedText').requireText('Ciao!')
			}
			
			test 'Oh my' {
				window.textBox('textToCopy').deleteText
				window.textBox('textToCopy').enterText('Addio!')
				window.button('copyButton').click
				window.label('copiedText').requireText('Addio!')
			}
		'''.compile [
//			val rn = new RunNotifier()
//			new JUnit4(compiledClass).run(rn)
			val junitcore = new JUnitCore()
			val result = junitcore.run(compiledClass)
//			val result = JUnitCore.runClasses(compiledClass)
//			val testCase = compiledClass.newInstance
//			rex.invoke(testCase,'beforeClass')
//			rex.invoke(testCase,'setup')
//			rex.invoke(testCase,'firstTest')
//			rex.invoke(testCase,'ohMy')
			println(singleGeneratedCode)
			println('N: '+result.runCount)
			println('S: '+result.wasSuccessful)
		]
	}
}
