package example;

import org.apache.ibatis.logging.LogFactory;
import org.camunda.bpm.engine.ProcessEngine;
import org.camunda.bpm.engine.test.Deployment;
import org.camunda.bpm.engine.test.ProcessEngineRule;
import org.camunda.bpm.scenario.ProcessScenario;
import org.camunda.bpm.spring.boot.starter.test.helper.StandaloneInMemoryTestConfiguration;
import org.junit.Before;
import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.test.context.junit4.SpringRunner;
import org.camunda.bpm.extension.process_test_coverage.junit.rules.TestCoverageProcessEngineRuleBuilder;

import javax.annotation.PostConstruct;

import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;

import static org.junit.Assert.*;
import static org.assertj.core.api.Assertions.*;
import static org.camunda.bpm.engine.test.assertions.ProcessEngineTests.*;

/**
 * Test case starting an in-memory database-backed Process Engine.
 */
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = WebEnvironment.NONE)
public class ProcessScenarioTest {

    private static final String PROCESS_DEFINITION_KEY = "timer";

    static {
        LogFactory.useSlf4jLogging(); // MyBatis
    }

    @Autowired
    ProcessEngine processEngine;

    @Rule
    @ClassRule
    public static ProcessEngineRule rule;

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
    }

    @Mock
    private ProcessScenario process;

    @PostConstruct
    void initRule() {
        rule = TestCoverageProcessEngineRuleBuilder.create(processEngine).build();
    }

    @Test
    public void testHappyPath() {
        // Define scenarios by using camunda-bpm-assert-scenario:

        //ExecutableRunner starter = Scenario.run(myProcess) //
        //    .startByKey(PROCESS_DEFINITION_KEY);

        // when(myProcess.waitsAtReceiveTask(anyString())).thenReturn((messageSubscription) -> {
        //  messageSubscription.receive();
        // });
        // when(myProcess.waitsAtUserTask(anyString())).thenReturn((task) -> {
        //  task.complete();
        // });

        // OK - everything prepared - let's go and execute the scenario
        //Scenario scenario = starter.execute();

        // now you can do some assertions
        //verify(myProcess).hasFinished("EndEvent");
    }

}
