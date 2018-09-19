
# Birdspotting

Some add-ons on `ActiveRecord::Migration` to make migration safer in the context of zero downtime deployment.

[![Gem Version](https://badge.fury.io/rb/birdspotting.svg)](https://badge.fury.io/rb/birdspotting)
[![Maintainability](https://api.codeclimate.com/v1/badges/4a272a3f849869a200df/maintainability)](https://codeclimate.com/github/drivy/birdspotting/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/4a272a3f849869a200df/test_coverage)](https://codeclimate.com/github/drivy/birdspotting/test_coverage)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'birdspotting'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install birdspotting

## Usage

### Configuration

You can configure the gem (for instance by creating a `config/initializers/birdspotting.rb`) with the following options (here with the default values):

```ruby
Birdspotting.configure do |config|
    config.start_check_at            = nil
    config.check_bypass_env_var      = "BYPASS_SCHEMA_STATEMENTS_CHECK"

    config.add_column_position_check = true

    config.encoding_check            = true
    config.encoding_check_message    = "\n/!\\ You are dealing with a %<type>s field" \
    "(%<column_name>s): did you think about emojis and used the appropriate encoding? /!\\ \n\n"

    config.rename_column_check       = true
    config.rename_column_message     = "Don't use rename_column! https://stackoverflow.com/a/18542147"

    config.remove_column_check        = true
end
```

#### Common configuration

`start_check_at` allows to start the checks after some migration version only. Set it to a migration 
timestamp like 20151209000000 for instance. When nil, all migrations will be checked.

`check_bypass_env_var` specify the ENV var allowing to bypass the checks. Use it to bypass temporarily all the checks so you do it intentionally. You can set it to any value, it's just testing it's set.

For instance if check_bypass_env_var is set to BYPASS_SCHEMA_STATEMENTS_CHECK (the default) you can do:

```
BYPASS_SCHEMA_STATEMENTS_CHECK=true rails db:migrate:up VERSION=20180806142044
```

### add_column request position

We like to keep or columns organised for the case where we don't use the ORM but some other client.

This will raise a `Birdspotting::ColumnPositionMissingError` error if neither `:first` or `:after`
is in the add_columns option.

You can skip this validation by setting `add_column_position_check` to `false`. 

### add_column encoding warning

This will add a warning when adding a string (or text) column to warn us to think about encoding 
issues. Like do we want to support emojis, or unusual characters?

You can skip this validation by setting `encoding_check` to `false`. 
You can customise the warning message by using the `encoding_check_message` setting.

### rename_column

By default, we don't want to use the rename column possibility as it will break any live application.
And we want to be able to release and run migration without downtime.
Though when a rename_column is used, it will raise a `Birdspotting::RenameColumnForbiddenError`.

You can skip this validation by setting `rename_column_check` to `false`. 
You can customise the warning message by using the `rename_column_message` setting. 
You might like to customize the warning message to be a link to an internal set of instructions for the correct way to do this.

### remove_column

By default, we don't want to be able to remove a columns which is still in use by a the application.

Thus we check if the column is still present in the columns list.

- If we are not able to find the model, we issue a `Birdspotting::ModelNotFoundError`.
- If the column is still present in the model, we issue a `Birdspotting::RemoveColumnForbiddenError`.

We advise to set the column in the `ignored_columns` of the model. (See [this blog article](https://blog.bigbinary.com/2016/05/24/rails-5-adds-active-record-ignored-columns.html))

You can skip this validation by setting `remove_column_check` to `false`. 

### reorder_columns [mySql only]

As said above, we like to keep or columns organised for the case where 
we don't use the ORM but some other client.

This helper allow to reorder all the columns of a table.

Usage:

````ruby
class ReorderPostsColumns < ActiveRecord::Migration[5.2]
  include Birdspotting::ReorderColumns

  def change
    reorder_columns_for :posts, %i{
      id
      author
      body
      subject
      posted_at
      created_at
      updated_at
    }
  end
end
````

**CAVEAT:**

* All columns must be passed in parameters (or it will raise a `Birdspotting::MismatchedColumnsError`).
* For now, it only works on mysql (or it will raise a `Birdspotting::UnsupportedAdapterError`).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/drivy/birdspotting. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Birdspotting project’s codebases and issue trackers is expected to follow the [code of conduct](https://github.com/drivy/birdspotting/blob/master/CODE_OF_CONDUCT.md).
