# Changelog

## [Unreleased](https://github.com/amalagaura/camunda-workflow/tree/HEAD)

[Full Changelog](https://github.com/amalagaura/camunda-workflow/compare/v0.2.0...HEAD)

**Closed issues:**

- Remove check for what bpmn\_perform returns. Ignore if not a hash. [\#27](https://github.com/amalagaura/camunda-workflow/issues/27)

## [v0.2.0](https://github.com/amalagaura/camunda-workflow/tree/v0.2.0) (2019-12-20)

[Full Changelog](https://github.com/amalagaura/camunda-workflow/compare/v0.1.5...v0.2.0)

**Closed issues:**

- Change the diagrams symlink to resources and change the symlink structure  [\#25](https://github.com/amalagaura/camunda-workflow/issues/25)
- remove listen note since it seems to have gone away [\#23](https://github.com/amalagaura/camunda-workflow/issues/23)
- Rename fetch\_and\_execute to fetch\_and\_queue [\#22](https://github.com/amalagaura/camunda-workflow/issues/22)
- Add a backtrace silencer to remove extra backtrace information from exceptions reported to Camunda [\#18](https://github.com/amalagaura/camunda-workflow/issues/18)

**Merged pull requests:**

- Ignore if a Hash is not returned from bpmn\_perform [\#28](https://github.com/amalagaura/camunda-workflow/pull/28) ([amalagaura](https://github.com/amalagaura))
- Change symlink structure and change bpmn/diagrams to bpmn/resources [\#26](https://github.com/amalagaura/camunda-workflow/pull/26) ([amalagaura](https://github.com/amalagaura))
- Change fetch\_and\_execute to fetch\_and\_queue [\#24](https://github.com/amalagaura/camunda-workflow/pull/24) ([amalagaura](https://github.com/amalagaura))
- Add backtrace cleaner to only relevant lines for error incidents [\#21](https://github.com/amalagaura/camunda-workflow/pull/21) ([amalagaura](https://github.com/amalagaura))

## [v0.1.5](https://github.com/amalagaura/camunda-workflow/tree/v0.1.5) (2019-12-19)

[Full Changelog](https://github.com/amalagaura/camunda-workflow/compare/v0.1.4...v0.1.5)

**Closed issues:**

- Add some more screenshots [\#16](https://github.com/amalagaura/camunda-workflow/issues/16)

**Merged pull requests:**

- Upgrading gems and changing bpmn error message [\#20](https://github.com/amalagaura/camunda-workflow/pull/20) ([amalagaura](https://github.com/amalagaura))
- Rake feature [\#19](https://github.com/amalagaura/camunda-workflow/pull/19) ([curatingbits](https://github.com/curatingbits))
- Update readme with screenshots [\#17](https://github.com/amalagaura/camunda-workflow/pull/17) ([amalagaura](https://github.com/amalagaura))
- Add assert scenario test for sample.bpmn [\#15](https://github.com/amalagaura/camunda-workflow/pull/15) ([curatingbits](https://github.com/curatingbits))

## [v0.1.4](https://github.com/amalagaura/camunda-workflow/tree/v0.1.4) (2019-12-11)

[Full Changelog](https://github.com/amalagaura/camunda-workflow/compare/v0.1.3...v0.1.4)

**Closed issues:**

- add find\_by! [\#13](https://github.com/amalagaura/camunda-workflow/issues/13)

**Merged pull requests:**

- Add find\_by! to all Camunda Her models [\#14](https://github.com/amalagaura/camunda-workflow/pull/14) ([amalagaura](https://github.com/amalagaura))
- Yarddoc documentation [\#12](https://github.com/amalagaura/camunda-workflow/pull/12) ([curatingbits](https://github.com/curatingbits))

## [v0.1.3](https://github.com/amalagaura/camunda-workflow/tree/v0.1.3) (2019-12-06)

[Full Changelog](https://github.com/amalagaura/camunda-workflow/compare/v0.1.2...v0.1.3)

**Closed issues:**

- When there is a logic error in submitting a user task we are getting a MissingTask error instead [\#9](https://github.com/amalagaura/camunda-workflow/issues/9)
- If a class does not exist, the Poller loop crashes [\#7](https://github.com/amalagaura/camunda-workflow/issues/7)

**Merged pull requests:**

- Raise Submission errors if Camunda does not accept completion [\#11](https://github.com/amalagaura/camunda-workflow/pull/11) ([amalagaura](https://github.com/amalagaura))
- Allow Poller to not exit its loop when there is a missing class and report error [\#8](https://github.com/amalagaura/camunda-workflow/pull/8) ([amalagaura](https://github.com/amalagaura))
- Add rubocop rspec [\#6](https://github.com/amalagaura/camunda-workflow/pull/6) ([amalagaura](https://github.com/amalagaura))

## [v0.1.2](https://github.com/amalagaura/camunda-workflow/tree/v0.1.2) (2019-11-27)

[Full Changelog](https://github.com/amalagaura/camunda-workflow/compare/fc9ab266909628118a892082abdff953f3bc7eca...v0.1.2)

**Merged pull requests:**

- Correct find\_by\_business\_key\_and\_task\_definition\_key! [\#5](https://github.com/amalagaura/camunda-workflow/pull/5) ([amalagaura](https://github.com/amalagaura))
- added authentication via templates for spring\\_boot generator and Her [\#4](https://github.com/amalagaura/camunda-workflow/pull/4) ([curatingbits](https://github.com/curatingbits))
- Refactor to return proper Her models after responses [\#3](https://github.com/amalagaura/camunda-workflow/pull/3) ([amalagaura](https://github.com/amalagaura))
- Added tests for Camunda workflow [\#2](https://github.com/amalagaura/camunda-workflow/pull/2) ([curatingbits](https://github.com/curatingbits))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
