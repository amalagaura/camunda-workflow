# Camunda Workflow

## An opinionated interface to Camunda for Ruby/Rails apps

We use [Her](https://github.com/remiprev/her) to communicate with the [Camunda REST API](https://docs.camunda.org/manual/latest/reference/rest/). We use the process definition key as the topic name. Tasks are pulled and fetched and locked and then run. We expect ActiveJob classes to implement each external task.
    
We have scripts to run unit tests on the BPMN definitions. This expects Java and Maven.

We also have rspec helpers which will validate your application to make sure it has a class for every External task in a given BPMN file.