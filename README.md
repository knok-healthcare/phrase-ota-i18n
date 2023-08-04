# phrase-ota-i18n

Backend for the [I18n](https://github.com/ruby-i18n/i18n) gem to update translations over-the-air from [Phrase Strings](https://phrase.com)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'phrase-ota-i18n'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install phrase-ota-i18n

## Usage

Generate config:

    bundle exec rails generate phrase_ota_rails:install --distribution-id <DISTRIBUTION_ID> --secret-token <SECRET>


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

This project relies on [conventional commits](https://www.conventionalcommits.org) used by [release-please](https://github.com/googleapis/release-please) to generate proper changelogs and increment versions of the generated client libraries affected by the PR. Please use [appropriate prefixes](https://kapeli.com/cheat_sheets/Conventional_Commits.docset/Contents/Resources/Documents/index) when giving titles to your PRs as they decide whether there will be a version bump and changelog entry.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
