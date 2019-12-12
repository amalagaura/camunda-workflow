/*
* Process Scenario Test is a working example on how test bpmn files using
* camunda-bpm-assert-scenario. It uses the sample.bpmn file supplied with
* the generator and test the processes.
*/

package camunda;

import org.camunda.bpm.engine.test.Deployment;
import org.camunda.bpm.engine.test.ProcessEngineRule;
import org.camunda.bpm.engine.variable.Variables;
import org.camunda.bpm.extension.process_test_coverage.junit.rules.TestCoverageProcessEngineRuleBuilder;
import org.camunda.bpm.scenario.ProcessScenario;
import org.camunda.bpm.scenario.Scenario;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.junit4.SpringRunner;
import org.junit.Before;
import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Map;

import static org.camunda.bpm.engine.test.assertions.ProcessEngineTests.*;
import static org.mockito.Mockito.*;

@Deployment(resources = {
  "sample.bpmn"
})
// Disabled SpringRunner for test until a graceful delayed solution for shutting down h2:mem database is in place.
// Test are run in multi processes so using DB_CLOSE_DELAY=-1 doesn't work.
//@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = WebEnvironment.NONE)
public class ProcessScenarioTest {
  @Rule
  @ClassRule
  public static ProcessEngineRule rule =
      TestCoverageProcessEngineRuleBuilder.create()
        .withDetailedCoverageLogging().build();

  // Mock all waitstates in main process and call activity with a scenario
  @Mock private ProcessScenario camundaWorkflow;
  private Map<String, Object> variables;


  @Before
    public void setupDefaultScenario() {
      // Define scenarios by using camunda-bpm-assert-scenario:
      MockitoAnnotations.initMocks(this);

      when(camundaWorkflow.waitsAtUserTask("UserTask")).thenReturn((task) -> {
        task.complete(withVariables("foo", "bar"));
      });

      when(camundaWorkflow.waitsAtServiceTask("DoSomething")).thenReturn((task) -> {
        task.complete(withVariables("approve", true));
      });
    }

    @Test
      public void testHappyPath(){
        //ExecutableRunner starter = Scenario.run(myProcess)
        // OK - everything prepared - let's go and execute the scenario
        Scenario.run(camundaWorkflow).startByKey("CamundaWorkflow").execute();
        verify(camundaWorkflow).hasFinished("EndEventProcessEnded");
      }
}