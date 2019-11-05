# Camunda Workflow

## An opinionated interface to Camunda for Ruby/Rails apps

[Her](https://github.com/remiprev/her) is used to communicate with the [Camunda REST API](https://docs.camunda.org/manual/latest/reference/rest/). Topic names are defined by the process definition key. Tasks are pulled and fetched and locked and then run. We expect classes (ActiveJob) to implement each external task.
    
![Screenshot] (http://imagur.com/3ALVUMh)

We will have scripts to run unit tests on the BPMN definitions. This expects Java and Maven.

We also have rspec helpers which will validate your application to make sure it has a class for every External task in a given BPMN file.

## Integration with your worker classes

We have a module `ExternalTaskJob` which you need to include in your classes. We want your classes to inherit from `ActiveJob::Base` or use `Sidekiq::Worker` or not use either.

But right now we are using `perform_later` on worker classes. If we want to make this more flexible we need to make the method used to queue jobs configurable. `perform_later` for ActiveJob, `perform_async` for Sidekiq or `perform` if no background task system is used.

## Generators

### BPMN ActiveJob install
```bash
rails generate camunda:install
```

Creates `app/jobs/camunda_job.rb`. A class which inherits from ApplicationJob and includes `ExternalTaskJob`. It can be changed to include
 Sidekiq::Worker instead.  

All of the BPMN worker classes will inherit from this class

### Java Spring Boot App install
```bash
rails generate camunda:spring_boot
```
Generates a skeleton Java Spring Boot app which also contains the minimal files to run unit tests on a BPMN file. This can be used to
start a Camunda instance with a REST api. This can also be deployed to PCF by generating a Spring Boot jar and pushing it.

### BPMN Classes
```bash
rails generate camunda:bpmn_classes
```

Parses the BPMN file and creates task classes according to the ID of the process file and the ID of 
each task. It checks each task and only creates it if the topic name is the same as the process ID. This 
allows one to have some tasks be handled outside the Rails app. It confirms that the ID's are valid Ruby constant names. 

#### Starting the Camunda server for development

Start the application: `mvn spring-boot:run`

Camunda-workflow defaults to an in-memory, h2 database engine. Data is not persisted. If you would rather use postgres database engine, comment out the 
h2 database engine settings in the  `pom.xml` file located in `bpmn/java_app`. Default settings for using Postgres are available in the `pom.xml` file. 
You will need to create a postgres database on localhost called `camunda`. 

#### Generating a jar for deployment
`mvn package spring-boot:repackage`

The jar is in `target/camunda-bpm-springboot.jar`

#### Deploying to PCF
`cf push app_name -p target/camunda-bpm-springboot.jar`

It will fail to start. Create a postgres database  as a service in PCF and bind it to the application. The Springboot application is configured for Postgres and will then be able to start.

#### Running java unit tests
`mvn clean test`

### Methods
#### Processes
Deploying a model. Uses a default name, tenant id, etc. Below outlines how to deploy a process using the included sample.bpmn
file created by the generator.

```ruby
  Camunda::Deployment.create file_name: 'bpmn/diagrams/sample.bpmn'
```

Starting a process
```ruby
  start_response = Camunda::ProcessDefinition.start id: 'CamundaWorkflow'
```
or
```ruby
  start_response = Camunda::ProcessDefinition.start_with_variables id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
```

Destroy a process
```ruby
  Camunda::ProcessInstance.destroy_existing start_response.id
```

#### Tasks
Fetch tasks and queue with ActiveJob

This runs as an infinite loop with long polling to fetch tasks, queue, and run them. Topic is the process definition key 
as show in the screenshot example from the Camunda Modeler.
```ruby
  Camunda::Poller.fetch_and_execute %w[Topic]
```
Below will run the poller to fetch, lock and run a task for the example process definition located in 
the `starting a process` documentation.

```ruby
  Camunda::Poller.fetch_and_execute %w[CamundaWorkflow]
```

Fetch tasks (one time for testing from the console)

```ruby
  tasks = Camunda::ExternalTask.fetch_and_lock %w[topic]
``` 
Example to fetch and lock using `sample.bpmn` example.

```ruby
 tasks = Camunda::ExternalTask.fetch_and_lock %w[CamundaWorkflow]
```
Run a task

```ruby
  tasks.each(&:run_now)
```

#### User Tasks
Mark a user task complete
```ruby
  Camunda::Task.mark_task_completed!(business_key, task_key, {})
```

#### Note: 

If you get an error
  
        ** ERROR: directory is already being watched! **
         
        Directory: bpmn/java_app/src/main/resources
        is already being watched through: bpmn/diagrams
             
        MORE INFO: https://github.com/guard/listen/wiki/Duplicate-directory-errors
        
It is because ActionMailer preview causes test/mailers/previews to get added to the Rails EventedFileChecker
by default. RSpec is supposed to override it, but it is not
overridden properly for EventedFileChecker and/or you don't have spec/mailers/preview existing. If that 
directory does not exist it goes to the first common directory that exists which is your Rails root folder. 
So EventedFileChecker is listening to your entire Rails folder. Not a big problem, but it causes a problem 
for our created symlink.

So add: 
      
        config.action_mailer.show_previews = false
              
to your `development.rb` file to solve Listen errors about a symlink. Unless you are using ActionMailer 
previews in which case you should have the directory created already.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
