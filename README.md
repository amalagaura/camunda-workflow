[![Build Status](https://travis-ci.com/amalagaura/camunda-workflow.svg?branch=master)](https://travis-ci.com/amalagaura/camunda-workflow)
[![Gem Version](https://badge.fury.io/rb/camunda-workflow.svg)](https://badge.fury.io/rb/camunda-workflow)
[![Inline docs](http://inch-ci.org/github/amalagaura/camunda-workflow.svg?branch=master)](http://inch-ci.org/github/amalagaura/camunda-workflow)
# Camunda Workflow

## An opinionated interface to Camunda for Ruby/Rails apps

Camunda Workflow uses [Spyke](https://github.com/balvig/spyke) to communicate with the [Camunda REST API](https://docs.camunda.org/manual/latest/reference/rest/). It executes [External Service Tasks](https://docs.camunda.org/manual/latest/user-guide/process-engine/external-tasks/) using a Ruby class corresponding to each Camunda external task.


## Camunda Integration with Ruby

The Camunda model process definition key is the module name of your implementation classes.

  ![image](https://user-images.githubusercontent.com/498234/71268690-82934480-231b-11ea-9c58-0500b7ace028.png)

An external task is created with a Ruby class name for the id. And the process definition key should be set as the topic name.

![image](https://user-images.githubusercontent.com/498234/71268753-af475c00-231b-11ea-8b39-89d2f306539b.png)

Tasks are fetched, locked and then queued. We expect classes (ActiveJob) to implement each external task. So, according to the above screenshots, the poller and queuer will expect a class called `SomeProcess::SomeTask` to be implemented in your app.

### Integration with your worker classes

Worker classes should inherit from `CamundaJob`. It is generated with `rails g camunda:install`.

`perform` is implemented on  `Camunda::ExternalTaskJob`. It calls `bpmn_perform` with variables from Camunda and returns the results back to Camunda.
```
class CamundaJob < ApplicationJob
  # If using Sidekiq, change to include Sidekiq::Worker instead of inheriting from ApplicationJob
  include Camunda::ExternalTaskJob
end

class SomeProcess::SomeTask < CamundaJob
  def bpmn_perform(variables)
    do_something(variables[:foo])

    # A hash returned will become variables in the Camunda BPMN process instance
    { foo: 'bar', foo2: { json: "str" }, array_var: ["str"] }
  end
end
```

### Exceptions create Camunda incidents
If your implementation throws an exception, it is caught and then sent to Camunda with a stack trace.
![image](https://user-images.githubusercontent.com/498234/71266361-35f93a80-2316-11ea-96ed-6501ef68f849.png)

![image](https://user-images.githubusercontent.com/498234/71269561-a22b6c80-231d-11ea-80af-b748ba7eb09a.png)
### Supporting bpmn exceptions

Camunda supports throwing bpmn exceptions on a service task to communicate logic errors and not underlying code errors. These expected errors are thrown with
```ruby
class SomeProcess::SomeTask < CamundaJob
  def bpmn_perform(variables)
    result = do_something(variables[:foo])

    if result == :expected
      { foo: 'bar', foo2: { json: "str" }, array_var: ["str"] }
    else
      raise Camunda::BpmnError.new error_code: 'bpmn-error', message: "Special BPMN error", variables: { bpmn: 'error' }
    end
  end
end
```

## Generators

### Java Spring Boot App install
```bash
rails generate camunda:spring_boot
```
Creates a skeleton Java Spring Boot app, which also contains the minimal files to run unit tests on a BPMN file. The Spring boot app can be used to
start a Camunda instance with a REST api and also be deployed to PCF by generating a Spring Boot jar and pushing it.

 ### BPMN ActiveJob install
```bash
rails generate camunda:install
```
Creates `app/jobs/camunda_job.rb`. A class that inherits from ApplicationJob and includes `ExternalTaskJob`. It can be changed to include  `Sidekiq::Worker` instead.

All of the BPMN worker classes will inherit from this class

### BPMN Classes
```bash
rails generate camunda:bpmn_classes
```
Parses the BPMN file and creates task classes according to the ID of the process file and the ID of each task. It checks each task and only creates it if the topic name is the same as the process ID. This allows one to have some tasks be handled outside the Rails app. It confirms that the ID's are valid Ruby constant names.

#### Starting the Camunda server for development

[Java 7](https://www.java.com/en/) and [Apache Maven](https://maven.apache.org/install.html) are requirements to run the Camunda server. We are using the [Spring](https://docs.spring.io/spring-boot/docs/1.5.21.RELEASE/reference/html/getting-started-system-requirements.html) distribution.  The Camunda application has a `pom.xml`, which Maven uses to install the required dependencies.

Start the application:
```bash
cd bpmn/java_app
mvn spring-boot:run

# Or use the included rake task:
# Start the Camunda spring boot app with `mvn spring-boot:run`
rake camunda:run
```

If you create Java based unit tests for your bpmn file they can be run with an included rake task as well.


#### Running java unit tests
```bash
cd bpmn/java_app
mvn clean test

# Or use the included rake task:
# Runs spring boot test suite with `mvn clean test`
rake camunda:test
```

Camunda-workflow defaults to an in-memory, h2 database engine. If you rather use a Postgres database engine, comment out the h2 database engine settings in the `pom.xml` file located in `bpmn/java_app`. Default settings for using Postgres are available in the `pom.xml` file.
You will need to create a Postgres database on localhost called `camunda`.

### Configuration
#### Engine Route Prefix of the Java Spring Boot app
The default engine route prefix for the provided Java Spring Boot app is `rest`. If you choose to download and use the Camunda distribution, the engine prefix is `rest-engine`. Camunda-workflow is configured to use `rest` by default.

To override the default engine route prefix, you need to add an initializer file in your rails app.

```ruby
# filename initializers/camunda.rb
Camunda::Workflow.configure do |config|
  config.engine_route_prefix = 'rest-engine'
end
```
#### Enable HTTP Basic Auth for Java Spring Boot app

Authentication can be enabled in the Camunda Java Spring Boot app by setting an environment variable `CAMUNDA_AUTH` to `true` or `false` or by setting the `camunda.authentication` variable  located in the  `application.properties` (bpmn/java_app/src/main/resources) file to `true`.

When HTTP Basic Auth is enabled, it's required that a user with the appropriate permissions is setup in Camunda.  Otherwise, the request will return as `401 unauthorized`. Users are set up within the admin dashboard of Camunda and used to authenticate by passing an Authorization header during requests to the REST API. Below is how to configure the `camunda_user` and `camunda_password` to be used in the header request to authenticate using HTTP Basic Auth.

```ruby
# filename initializers/camunda.rb
Camunda::Workflow.configure do |config|
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

## Usage

### Add to your Gemfile
```ruby
  gem 'camunda-workflow'
```

### Deploying a model
Uses a default name, etc. Below outlines how to deploy a process using the included sample.bpmn file created by the generator. Alternatively you can deploy using Camunda Modeler

```ruby
 Camunda::Deployment.create file_names: ['bpmn/diagrams/sample.bpmn']
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

The poller runs an infinite loop with long polling to fetch tasks, queue, and run them. The topic is the process definition key, as shown in the screenshot example from the Camunda Modeler.

Below will run the poller to fetch, lock, and run a task for the example process definition located in the `starting a process` detailed above.

Poller will need to run in a separate process or thread and needs to be running constantly in order to poll Camunda and queue jobs.

```ruby
 Camunda::Poller.fetch_and_queue %w[CamundaWorkflow]
 ```

#### Running the poller in a separate thread
We have had success with running a long running thread in a Rails app using [Rufus Scheduler](https://github.com/jmettraux/rufus-scheduler). Something like:

```
rufus_scheduler.in('10.seconds') do
  Camunda::Poller.fetch_and_queue %w[Topics]
end
```


#### Fetch tasks For testing from the console

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
 # Or you can query Camunda::Task with other parameters like assignee task.complete!(var1: 'value')
Camunda::Task.find_by_business_key_and_task_definition_key!(instance_business_key, task_key).complete!
```

### Rspec Helpers
RSpec helpers validate your application to make sure it has a class for every External task in a given BPMN file.
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

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
