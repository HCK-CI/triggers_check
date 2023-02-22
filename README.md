# TriggersCheck

The gem that provides the ability to check whether the testing process should be started

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'triggers_check'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install triggers_check

## Usage

### Initialization options

| Parameter | Descriptions |
| --------- | ------------ |
| :work_directory | The directory where the source code is located
| :test_objects | The list of objects that are expected to run tests
| :diff_file | The file with PR difference (default: #{work_directory}/diff.txt)
| :triggers_file | The file with the list of includes/excludes for each test object (default: #{work_directory}/triggers.yml)
| :logger | The ruby logger object for logging (default: disabled)

### Examples

See examples in corresponding directory

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/triggers_check.
