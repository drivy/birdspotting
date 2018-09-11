require "active_record"

require "birdspotting/version"
require "birdspotting/errors"
require "birdspotting/configuration"
require "birdspotting/schema_statements"
require "birdspotting/reorder_columns"

module Birdspotting
  def self.configuration
    @configuration || configure
  end

  def self.configure(&block)
    @configuration = Configuration.default.tap do |config|
      block&.call(config)
    end
  end
end

ActiveRecord::Migration.prepend Birdspotting::SchemaStatements
