package org.assertx.swing.tests

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.util.JavaVersion
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.junit.Before
import org.junit.Test
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
			def Prova testing «ExampleJFrame.canonicalName»
		'''.assertCompilesTo(
			'''
			package MyFile;
			
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.assertx.swing.tests.ExampleJFrame;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			
			@SuppressWarnings("all")
			public class Prova {
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
	def void testSettingsSectionGeneration() {
		'''
		def Prova testing «ExampleJFrame.canonicalName» {
		
		settings {
			delayBetweenEvents(200)
		}
		}'''.assertCompilesTo('''
			package MyFile;
			
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
			public class Prova {
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
			def Prova testing «ExampleJFrame.canonicalName» {
			
			test '1234' {}
			
			test 'should i even write this?' {}
			
			test "It works!?! Yes!" {}
			
			test 'MiX(i)ng uP'{}
			
			test ',.-@##+'{}
			}
		'''.compile [
			val methods = compiledClass.methods.filter [
				if(annotations.empty) false else Test.equals(annotations.head.annotationType)
			].sortBy[name]
			5.assertEquals(methods.length)
			'_1234'.assertEquals(methods.get(0).name)
			'__'.assertEquals(methods.get(1).name)
			'itWorksYes'.assertEquals(methods.get(2).name)
			'miXingUP'.assertEquals(methods.get(3).name)
			'shouldIEvenWriteThis'.assertEquals(methods.get(4).name)
		]
	}

	@Test
	def void testNullMethodNameTranslation() {
		'''
			def Prova testing «ExampleJFrame.canonicalName» {
			
			test {}
			}
		'''.compile [
			1.assertEquals(errorsAndWarnings.size)
			'''
				package MyFile;
				
				import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
				import org.assertj.swing.edt.GuiActionRunner;
				import org.assertj.swing.fixture.FrameFixture;
				import org.assertx.swing.tests.ExampleJFrame;
				import org.junit.After;
				import org.junit.Before;
				import org.junit.BeforeClass;
				
				@SuppressWarnings("all")
				public class Prova {
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
	def void testMethodNamesCollisions() {
		'''
			def Prova testing «ExampleJFrame.canonicalName» {
			
			test 'first method' {}
			
			test 'first method' {}
			
			test 'First Method' {}
			
			test 'first Method' {}
			
			test 'firstMethod' {}
			
			test 'First è%#@ me]thod' {}
			}
		'''.assertCompilesTo('''
			package MyFile;
			
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.assertx.swing.tests.ExampleJFrame;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			import org.junit.Test;
			
			@SuppressWarnings("all")
			public class Prova {
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
	def void testCustomFieldName() {
		'''
			def Prova testing «ExampleJFrame.canonicalName» as field {
			
			test 'method' {
				field.textBox('textToCopy').deleteText
			}
			}
		'''.assertCompilesTo(
			'''
				package MyFile;
				
				import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
				import org.assertj.swing.edt.GuiActionRunner;
				import org.assertj.swing.fixture.FrameFixture;
				import org.assertx.swing.tests.ExampleJFrame;
				import org.junit.After;
				import org.junit.Before;
				import org.junit.BeforeClass;
				import org.junit.Test;
				
				@SuppressWarnings("all")
				public class Prova {
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

	@Test
	def void testGeneratedClassNameAlwaysStartsWithUpperCase() {
		val resourceset = resourceSet('lowerCaseFile.assertxs' -> '''
			def Prova testing javax.swing.JFrame
		''')

		resourceset.compile [
			val className = compiledClass.simpleName
			val fullClassName = compiledClass.canonicalName
			assertTrue(
				"name of generated class '" + fullClassName + "' doesn't start with uppercase letter",
				Character::isUpperCase(className.charAt(0))
			)
		]
	}

	@Test
	def void testMatcherCompilesToInnerClass() {
		'''
			def Prova testing javax.swing.JFrame {
			
			def isEmptyLabel match javax.swing.JLabel {
				it.getText.length == 0
			}
			}
		'''.assertCompilesTo('''
			package MyFile;
			
			import javax.swing.JFrame;
			import javax.swing.JLabel;
			import org.assertj.swing.core.GenericTypeMatcher;
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			
			@SuppressWarnings("all")
			public class Prova {
			  private FrameFixture window;
			  
			  @BeforeClass
			  public static void _beforeClass() {
			    FailOnThreadViolationRepaintManager.install();
			  }
			  
			  @Before
			  public void _setup() {
			    JFrame frame = GuiActionRunner.execute(() -> new JFrame());
			    this.window = new FrameFixture(frame);
			  }
			  
			  @After
			  public void _cleanUp() {
			    this.window.cleanUp();
			  }
			  
			  private class IsEmptyLabel extends GenericTypeMatcher<JLabel> {
			    public IsEmptyLabel() {
			      super(JLabel.class);
			    }
			    
			    @Override
			    public boolean isMatching(final JLabel it) {
			      int _length = it.getText().length();
			      return (_length == 0);
			    }
			  }
			}
		''')
	}

	@Test
	def void testMatcherUsage() {
		'''
			def Prova testing javax.swing.JFrame {
			
			test 'm' {
				window.button(?isMatch?)
				window.textBox(?noLabel?)
			}
			
			def isMatch match javax.swing.JButton {
				true
			}
			
			def noLabel match javax.swing.JLabel {
				false
			}
			}
		'''.assertCompilesTo('''
			package MyFile;
			
			import javax.swing.JButton;
			import javax.swing.JFrame;
			import javax.swing.JLabel;
			import org.assertj.swing.core.GenericTypeMatcher;
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			import org.junit.Test;
			
			@SuppressWarnings("all")
			public class Prova {
			  private FrameFixture window;
			  
			  @BeforeClass
			  public static void _beforeClass() {
			    FailOnThreadViolationRepaintManager.install();
			  }
			  
			  @Before
			  public void _setup() {
			    JFrame frame = GuiActionRunner.execute(() -> new JFrame());
			    this.window = new FrameFixture(frame);
			  }
			  
			  @After
			  public void _cleanUp() {
			    this.window.cleanUp();
			  }
			  
			  private class IsMatch extends GenericTypeMatcher<JButton> {
			    public IsMatch() {
			      super(JButton.class);
			    }
			    
			    @Override
			    public boolean isMatching(final JButton it) {
			      return true;
			    }
			  }
			  
			  private class NoLabel extends GenericTypeMatcher<JLabel> {
			    public NoLabel() {
			      super(JLabel.class);
			    }
			    
			    @Override
			    public boolean isMatching(final JLabel it) {
			      return false;
			    }
			  }
			  
			  @Test
			  public void m() {
			    IsMatch _isMatch = new IsMatch();
			    this.window.button(_isMatch);
			    NoLabel _noLabel = new NoLabel();
			    this.window.textBox(_noLabel);
			  }
			}
		''')
	}

	@Test
	def void testMatcherRefReuseExistingVariable() {
		'''
			def Prova testing javax.swing.JFrame {
			
			def aMatch match javax.swing.JLabel {
				false
			}
			
			test 'm' {
				window.label(?aMatch?)
				window.label(?aMatch?)
			}
			}
		'''.assertCompilesTo('''
			package MyFile;
			
			import javax.swing.JFrame;
			import javax.swing.JLabel;
			import org.assertj.swing.core.GenericTypeMatcher;
			import org.assertj.swing.edt.FailOnThreadViolationRepaintManager;
			import org.assertj.swing.edt.GuiActionRunner;
			import org.assertj.swing.fixture.FrameFixture;
			import org.junit.After;
			import org.junit.Before;
			import org.junit.BeforeClass;
			import org.junit.Test;
			
			@SuppressWarnings("all")
			public class Prova {
			  private FrameFixture window;
			  
			  @BeforeClass
			  public static void _beforeClass() {
			    FailOnThreadViolationRepaintManager.install();
			  }
			  
			  @Before
			  public void _setup() {
			    JFrame frame = GuiActionRunner.execute(() -> new JFrame());
			    this.window = new FrameFixture(frame);
			  }
			  
			  @After
			  public void _cleanUp() {
			    this.window.cleanUp();
			  }
			  
			  private class AMatch extends GenericTypeMatcher<JLabel> {
			    public AMatch() {
			      super(JLabel.class);
			    }
			    
			    @Override
			    public boolean isMatching(final JLabel it) {
			      return false;
			    }
			  }
			  
			  @Test
			  public void m() {
			    AMatch _aMatch = new AMatch();
			    this.window.label(_aMatch);
			    this.window.label(_aMatch);
			  }
			}
		''')
	}

		'''
			
			}
			}
	}
}
