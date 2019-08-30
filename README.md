# Camunda Workflow

## An opinionated interface to Camunda for Ruby/Rails apps

We use [Her](https://github.com/remiprev/her) to communicate with the [Camunda REST API](https://docs.camunda.org/manual/latest/reference/rest/). We use the process definition key as the topic name. Tasks are pulled and fetched and locked and then run. We expect classes (ActiveJob) to implement each external task.
    
We will have scripts to run unit tests on the BPMN definitions. This expects Java and Maven.

We also have rspec helpers which will validate your application to make sure it has a class for every External task in a given BPMN file.

## Integration with your worker classes

We have a module `ExternalTaskJob` which you need to include in your classes. We want your classes to inherit from `ActiveJob::Base` or use `Sidekiq::Worker` or not use either.

But right now we are using `perform_later` on worker classes. If we want to make this more flexible we need to make the method used to queue jobs configurable. `perform_later` for ActiveJob, `perform_async` for Sidekiq or `perform` if no background task system is used.

 
