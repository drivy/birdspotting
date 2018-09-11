class Birdspotting::Configuration
  attr_accessor :start_check_at,
                :check_bypass_env_var,
                :add_column_position_check,
                :encoding_check,
                :encoding_check_message,
                :rename_column_check,
                :rename_column_message,
                :remove_column_check

  def self.default
    new.tap do |config|
      config.start_check_at = nil
      config.check_bypass_env_var = "BYPASS_SCHEMA_STATEMENTS_CHECK"
      config.add_column_position_check = true
      config.encoding_check = true
      config.encoding_check_message = "\n/!\\ You are dealing with a %<type>s field" \
        "(%<column_name>s): did you think about emojis and used the appropriate encoding? /!\\ \n\n"
      config.rename_column_check = true
      config.rename_column_message = "Don't use rename_column! https://stackoverflow.com/a/18542147"
      config.remove_column_check = true
    end
  end

  %w[
    add_column_position_check
    encoding_check
    rename_column_check
    remove_column_check
  ].each do |name|
    define_method "#{name}?" do
      public_send(name)
    end
  end
end
