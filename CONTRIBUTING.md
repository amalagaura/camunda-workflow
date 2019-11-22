## Contributing

### Instructions
Please create an issue to track what you are working on and ensure it is relevant.

Make sure whatever you are adding has specs. We should be able to maintain 100% coverage.

### Camunda interactions

We are using VCR to record interactions with a local Camunda engine. If you wish to try this run a camunda engine listening on `/rest`. `/rest` is the default of the spring boot application that we generate with this gem. This is different from the default `/rest-engine` of the default downloadable distribution.

You can for instance upgrade the Camunda version, delete the `spec/vcr` folder and then re-run the specs with `bundle exec rspec`

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.