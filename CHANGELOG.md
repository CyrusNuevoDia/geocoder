[Unreleased]

[2.2.2] - 2025-07-18

### Changes

- Fix HTTPoison client to handle non-200 status codes

[2.2.1] - 2024-12-17

### Changes

- Fix Geocoder.Providers.Fake returns {:error, nil} when nothing is found on call_list/1 #131

[2.2.0] - 2024-12-16

### Changes

- Change minimum Elixir version to 1.14 as 1.13 is about to be no longer supported
- Package updates
- Support default worker configuration
- Fix some missing typespecs

[2.1.0] - 2024-12-16

### Changes

- Version was skipped accidentally. but same as 2.2.0

[2.0.1] - 2023-08-18

### Changes

- Updates Copyright

[2.0.0] - 2023-08-10

** BREAKING**

This version will break how the geocoder starts. While we have kept the API similar and proposed a forward change, you will still need to add geocoder to your application tree. See changes below on how to migrate.

### Changes

- Rearchitected per the the [Elixir recommendation](https://hexdocs.pm/elixir/library-guidelines.html#avoid-spawning-unsupervised-processes) as well as [Chris Keathley](https://keathley.io/blog/reusable-libraries.html). No more an application is started. Instead a `Geocoder.Supervisor` was created to supervise the necessary processes. Also all configurations are now removed from the :geocoder application. Instead it is all specified in the supervisor allowing for more flexibility and to even start multiple pools
- Added support for configurable http client. Currently implemented out of the box HTTPoison and Hackney. Defaults to HTTPoison.
- Added support for configurable JSON codec. Currently implemented out of the box Json and JSX. Defaults to Jason.
- Support multiple parallel supervisor (so you can potentially use multiple provider, each with their own pool)
- Consolidated configuration to not use Application.get_env
- Improved documentation in general
- Cleanup code and configured Credo to improve maintenance

### Migrating from 1.x versions

1. add to your supervising tree the geocoder supervisor
2. Convert your configuration to the new format (the one you had under `config :geocoder, ...`)
3. Remove all the `config :geocoder, ...` from your config/*

that's it! should just work out of the box as we will default the processes name for you to be compatible.

[1.1.6] - 2023-07-23

### Changes

- Update package dependencies (Towel)
- Add partial_match on Geocoder Response by @dev-cruz in #93

[1.1.5] - 2022-08-24

### Changes

- Misc doc changes by @kianmeng in #67
- Fix store child spec to accept config by @ckhrysze in #73
- Increase precision default by @sfusato in #91

[1.1.4] - 2021-09-15

### Changes

- Fix store child spec to accept config by @ckhrysze in #73

[1.1.3] - 2021-09-03

### Changes

- Add elixir 1.12 to test suite by in #72
- Add support for suburbs to OpenSteetMaps by @iloveitaly and @ancyturtle in #71

[1.1.2] - 2021-05-17

### Changes

- Elixir 1.11 support

For any  prior versions, see github commit directly
