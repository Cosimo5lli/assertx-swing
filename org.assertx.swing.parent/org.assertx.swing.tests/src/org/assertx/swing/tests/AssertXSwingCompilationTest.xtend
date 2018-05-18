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

@RunWith(XtextRunner)
@InjectWith(AssertXSwingInjectorProvider)
class AssertXSwingCompilationTest {

	@Inject extension CompilationTestHelper

	@Before
	def void setJavaVersion() {
		// otherwise it doesn't compile lambdas. Maybe default is JAVA7
		javaVersion = JavaVersion.JAVA8
	}

	@Test
	def void testEmptyTestCase() {
		'''
			testing «ExampleJFrame.canonicalName»
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
			public class MyFile {
			  private FrameFixture window;
			  
			  @BeforeClass
			  public static void _beforeClass() {
			    FailOnThreadViolationRepaintManager.install();
			  }
			  
			  @Before
			  public void _setup() {
			    ExampleJFrame frame = GuiActionRunner.execute(() -> new ExampleJFrame());
			    this.window = new FrameFixture(frame);
			  }
			  
			  @After
			  public void _cleanUp() {
			    this.window.cleanUp();
			  }
			}
			''')
	}
	
	
	@Test
	def void testSettingsSectionGeneration(){
		'''
		testing «ExampleJFrame.canonicalName»
		
		settings {
			delayBetweenEvents(200)
		}'''.assertCompilesTo('''
			import org.assertj.swing.core.BasicRobot;
			import org.assertj.swing.core.Robot;
			import org.assertj.swing.core.Settings;
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.assertx.swing.tests.ExampleJFrame;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			
			@SuppressWarnings("all")
			public class MyFile {
			  private FrameFixture window;
			  
			  @BeforeClass
			  public static void _beforeClass() {
			    FailOnThreadViolationRepaintManager.install();
			  }
			  
			  private void _customizeSettings(final Settings it) {
			    it.delayBetweenEvents(200);
			  }
			  
			  @Before
			  public void _setup() {
			    Robot robot = BasicRobot.robotWithCurrentAwtHierarchy();
			    this._customizeSettings(robot.settings());
			    ExampleJFrame frame = GuiActionRunner.execute(() -> new ExampleJFrame());
			    this.window = new FrameFixture(robot, frame);
			  }
			  
			  @After
			  public void _cleanUp() {
			    this.window.cleanUp();
			  }
			}
			''')
	}

	@Test
	def void testMethodNameTranslation() {
		'''
			testing «ExampleJFrame.canonicalName»
			
			test '1234' {}
			
			test 'should i even write this?' {}
			
			test "It works!?! Yes!"
			
			test 'MiX(i)ng uP'
			
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
	def void testNullMethodNameTranslation(){
		'''
		testing «ExampleJFrame.canonicalName»
		
		test {}
		'''.compile[
			1.assertEquals(errorsAndWarnings.size)
			'''
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.assertx.swing.tests.ExampleJFrame;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			
			@SuppressWarnings("all")
			public class MyFile {
			  private FrameFixture window;
			  
			  @BeforeClass
			  public static void _beforeClass() {
			    FailOnThreadViolationRepaintManager.install();
			  }
			  
			  @Before
			  public void _setup() {
			    ExampleJFrame frame = GuiActionRunner.execute(() -> new ExampleJFrame());
			    this.window = new FrameFixture(frame);
			  }
			  
			  @After
			  public void _cleanUp() {
			    this.window.cleanUp();
			  }
			}
			'''.toString.assertEquals(singleGeneratedCode)
		]
	}
	
	@Test
	def void testMethodNamesCollisions(){
		'''
		testing «ExampleJFrame.canonicalName»
		
		test 'first method' {}
		
		test 'first method' {}
		
		test 'First Method' {}
		
		test 'first Method' {}
		
		test 'firstMethod' {}
		
		test 'First è%#@ me]thod' {}
		'''.assertCompilesTo('''
		import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
		import org.assertj.swing.edt.GuiActionRunner;
		import org.assertj.swing.fixture.FrameFixture;
		import org.assertx.swing.tests.ExampleJFrame;
		import org.junit.After;
		import org.junit.Before;
		import org.junit.BeforeClass;
		import org.junit.Test;
		
		@SuppressWarnings("all")
		public class MyFile {
		  private FrameFixture window;
		  
		  @BeforeClass
		  public static void _beforeClass() {
		    FailOnThreadViolationRepaintManager.install();
		  }
		  
		  @Before
		  public void _setup() {
		    ExampleJFrame frame = GuiActionRunner.execute(() -> new ExampleJFrame());
		    this.window = new FrameFixture(frame);
		  }
		  
		  @After
		  public void _cleanUp() {
		    this.window.cleanUp();
		  }
		  
		  @Test
		  public void firstMethod() {
		  }
		  
		  @Test
		  public void firstMethod_1_() {
		  }
		  
		  @Test
		  public void firstMethod_2_() {
		  }
		  
		  @Test
		  public void firstMethod_3_() {
		  }
		  
		  @Test
		  public void firstMethod_4_() {
		  }
		  
		  @Test
		  public void firstMethod_5_() {
		  }
		}
		''')
	}
	
	@Test
	def void testCustomFieldName(){
		'''
		testing «ExampleJFrame.canonicalName» as field
		
		test 'method' {
			field.textBox('textToCopy').deleteText
		}
		'''.assertCompilesTo(
			'''
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.assertx.swing.tests.ExampleJFrame;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			import org.junit.Test;
			
			@SuppressWarnings("all")
			public class MyFile {
			  private FrameFixture field;
			  
			  @BeforeClass
			  public static void _beforeClass() {
			    FailOnThreadViolationRepaintManager.install();
			  }
			  
			  @Before
			  public void _setup() {
			    ExampleJFrame frame = GuiActionRunner.execute(() -> new ExampleJFrame());
			    this.field = new FrameFixture(frame);
			  }
			  
			  @After
			  public void _cleanUp() {
			    this.field.cleanUp();
			  }
			  
			  @Test
			  public void method() {
			    this.field.textBox("textToCopy").deleteText();
			  }
			}
			'''
		)
	}

//	@Test
	//doesn't work, i don't know why, it simply doesn't run the tests of the compiled class
	//NOTE: it was actually an error in the inferrer, the @BeforeClass was not set to be 
	//static, so tests wouldn't run
	//TODO: move this test somewhere else, since it cannot be run headlessly
	// and seems more like an heavy integration test
	def void testJUnitTestCaseInstantiation() {
		'''
			testing «ExampleJFrame.canonicalName»
			
			test 'First test' {
				window.textBox('textToCopy').deleteText
				window.textBox('textToCopy').enterText('Hello!')
				window.button('copyButton').click
				window.label('copiedText').requireText('Hello!')
			}
		'''.compile [
			val result = JUnitCore.runClasses(compiledClass)
			1.assertEquals(result.runCount)
			assertTrue(result.wasSuccessful)
		]
	}
}
