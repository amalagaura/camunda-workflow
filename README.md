[![Build Status](https://travis-ci.com/amalagaura/camunda-workflow.svg?branch=master)](https://travis-ci.com/amalagaura/camunda-workflow) 
[![Gem Version](https://badge.fury.io/rb/camunda-workflow.svg)](https://badge.fury.io/rb/camunda-workflow)
[![Inline docs](http://inch-ci.org/github/amalagaura/camunda-workflow.svg?branch=master)](http://inch-ci.org/github/amalagaura/camunda-workflow)
# Camunda Workflow

## An opinionated interface to Camunda for Ruby/Rails apps

[Her](https://github.com/remiprev/her) is used to communicate with the [Camunda REST API](https://docs.camunda.org/manual/latest/reference/rest/). 

### Add to your Gemfile
```ruby
  gem 'camunda-workflow'
```

## Camunda Integration with Ruby
The process definitions key becomes the module name of your implementation classes and must be set to the name of a ruby style constant. 
    
![image](https://user-images.githubusercontent.com/498234/70742441-899ecf00-1ceb-11ea-9eb8-42dbb08dbd2d.png)


An external task is created with a Ruby class name for the id. And the process definition key should be set as the topic name. 

![image](https://user-images.githubusercontent.com/498234/70742635-fd40dc00-1ceb-11ea-8518-0fa5f6ea8028.png)

Tasks are pulled and fetched and locked and then run. We expect classes (ActiveJob) to implement each external task.

### Integration with your worker classes

The module `ExternalTaskJob` should be included in your job implementation classes. The job implementation classes can inherit from `ActiveJob::Base`, or use `Sidekiq::Worker` or use some other system for job queuing.

Currently we call `perform_later` on job implementation classes. If we want to make this more flexible, we need to make the method used to queue jobs configurable. `perform_later` for ActiveJob, `perform_async` for Sidekiq, or `perform` if no background task system is used.

### Implementing `bpmn_perform`

`bpmn_perform` is your implementation of the service task.

### Supporting bpmn exceptions

Camunda supports throwing bpmn exceptions on a service task to communicate logic errors and not underlying code errors. These expected errors are thrown with 
```ruby
raise Camunda::BpmnError.new error_code: 'bpmn-error', message: "Special BPMN error", variables: { bpmn: 'error' }
```

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
Creates a skeleton Java Spring Boot app, which also contains the minimal files to run unit tests on a BPMN file. This can be used to
start a Camunda instance with a REST api. This can also be deployed to PCF by generating a Spring Boot jar and pushing it.

### BPMN Classes
```bash
rails generate camunda:bpmn_classes
```

Parses the BPMN file and creates task classes according to the ID of the process file and the ID of 
each task. It checks each task and only creates it if the topic name is the same as the process ID. This 
allows one to have some tasks be handled outside the Rails app. It confirms that the ID's are valid Ruby constant names. 

#### Starting the Camunda server for development

[Java 7](https://www.java.com/en/) and [Apache Maven](https://maven.apache.org/install.html) are requirements to run 
[Spring](https://docs.spring.io/spring-boot/docs/1.5.21.RELEASE/reference/html/getting-started-system-requirements.html). 
Make sure all requirements for Spring are satisfied before starting Camunda engine via spring boot.

Start the application: 
```bash
 cd bpmn/java_app
```
```bash 
mvn spring-boot:run
```
The following Rake commands are available to maintain the spring boot server. 

```Bash
# Install the spring-boot app dependencies. 
rake camunda:install
```
We suggest (not required) running the install command before running the spring boot server for the first time or if the pom.xml file is updated. The 
install cleans up artifacts created by prior builds and installs the package dependencies into the local repository.

```bash
# Start the Camunda spring boot app
rake camunda:run
```

```bash
# Runs spring boot test suite
rake camunda:test
```
 

Camunda-workflow defaults to an in-memory, h2 database engine. If you rather use a Postgres database engine, comment out the 
h2 database engine settings in the `pom.xml` file located in `bpmn/java_app`. Default settings for using Postgres are available in the `pom.xml` file. 
You will need to create a Postgres database on localhost called `camunda`. 

#### Engine Route Prefix using the Java Spring Boot app
The default engine route prefix for the provided Java Spring Boot app is `rest`. If you choose to download and use the Camunda distribution,
the engine prefix is `rest-engine`. Camunda-workflow is configured to use `rest-engine`.

To override the default engine route prefix to allow your rails application to use the route prefix of `rest`, you need to add an initializer file
in your rails app with the below code. 


```ruby
# filename initializers/camunda.rb
Camunda::Workflow.configure do |config|
  config.engine_route_prefix = 'rest'
end
```
#### Enable HTTP Basic Auth for Java Spring Boot app
To add authentication to Camunda's REST API within the Java Spring Boot app change the `camunda.authentication` variable located in the
`application.properties` (bpmn/java_app/src/main/resources) file to `true`. Creating an environment variable `ENV['CAMUNDA_AUTH']` and setting a value of `true` or `false` will 
set the value as well. When HTTP Basic Auth is enabled, it's required that a user with the appropriate permissions is setup in Camunda. 
Otherwise, the request will return as `401 unauthorized`. Users are set up within the admin dashboard of Camunda and used to authenticate by passing an Authorization header during requests to the REST API. Below is how to configure 
the `camunda_user` and `camunda_password` to be used in the header request to authenticate using HTTP Basic Auth. 

```ruby
# filename initializers/camunda.rb
Camunda::Workflow.configure do |config|
  config.engine_route_prefix = 'rest'
  config.camunda_user = ENV['CAMUNDA_USER']
  config.camunda_password = ENV['CAMUNDA_PASSWORD']
end
```
#### Generating a jar for deployment
`mvn package spring-boot:repackage`

The jar is in `target/camunda-bpm-springboot.jar`

#### Deploying to PCF
`cf push app_name -p target/camunda-bpm-springboot.jar`

It will fail to start. Create a postgres database as a service in PCF and bind it to the application. The Springboot application is configured for Postgres and will then be able to start.

#### Running java unit tests
```bash
# Run in bpmn/java_app directory
mvn clean test
```

## Usage
### Deploying a model
Uses a default name, etc. Below outlines how to deploy a process using the included sample.bpmn
file created by the generator. Alternatively you can deploy using Camunda Modeler

```ruby
  Camunda::Deployment.create file_name: 'bpmn/diagrams/sample.bpmn'
```
### Processes

#### Starting a process

```ruby
  start_response = Camunda::ProcessDefinition.start_by_key'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
```
**Camunda cannot handle snake case variables, all snake_case variables are serialized to camelCase before a request is sent to the REST api. Variables returned back from the Camunda API will be deserialized back to snake_case.**

`{ my_variable: "xyz" }`

will be converted to:

`{ myVariable: "xyz" }`

#### Destroy a process
```ruby
  Camunda::ProcessInstance.destroy_existing start_response.id
```

### Tasks

#### Fetch tasks and queue with ActiveJob

The poller will run as an infinite loop with long polling to fetch tasks, queue, and run them. Topic is the process definition key, 
as show in the screenshot example from the Camunda Modeler.

Below will run the poller to fetch, lock, and run a task for the example process definition located in 
the `starting a process` detailed above.

```ruby
  Camunda::Poller.fetch_and_execute %w[CamundaWorkflow]
```

#### Fetch tasks 
For testing from the console

```ruby
  tasks = Camunda::ExternalTask.fetch_and_lock %w[CamundaWorkflow]
``` 

#### Run a task

```ruby
  tasks.each(&:run_now)
```


### User Tasks
#### Mark a user task complete
```ruby
  task = Camunda::Task.find_by_business_key_and_task_definition_key!(instance_business_key, task_key)
  # Or you can query Camunda::Task with other parameters like assignee 
  task.complete!(var1: 'value')
```

### Rspec Helpers
RSpec helpers can will validate your application to make sure it has a class for every External task in a given BPMN file.
```ruby
require 'camunda/matchers'

RSpec.describe "BPMN Diagrams" do
  describe Camunda::BpmnXML.new(File.open("bpmn/diagrams/YourFile.bpmn")) do
    it { is_expected.to have_module('YourModule') }
    it { is_expected.to have_topics(%w[YourModule]) }
    it { is_expected.to have_defined_classes }
  end
end
```
#### Note: 

If you get an error
  
        ** ERROR: directory is already being watched! **
         
        Directory: bpmn/java_app/src/main/resources
        is already being watched through: bpmn/diagrams
             
        MORE INFO: https://github.com/guard/listen/wiki/Duplicate-directory-errors
        
It is because ActionMailer preview causes test/mailers/previews to get added to the Rails EventedFileChecker
by default. RSpec is supposed to override it, but it is not
appropriately overridden for EventedFileChecker and/or you don't have spec/mailers/preview existing. If that 
directory does not exist, it goes to the first common directory that exists, which is your Rails root folder. 
So EventedFileChecker is listening to your entire Rails folder. Not a big problem, but it causes a problem 
for our created symlink.

So add: 
      
        config.action_mailer.show_previews = false
              
to your `development.rb` file to solve listen errors about a symlink. Unless you are using ActionMailer 
previews, in which case you should have the directory created already.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
