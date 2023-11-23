module Birdspotting::SchemaStatements

  def add_column(table_name, column_name, type, options = {})
    add_column_position_check(options)
    encoding_check(column_name, type, options)

    super(table_name, column_name, type, **options)
  end

  def rename_column(*args, **kwargs)
    rename_column_check(kwargs)

    super(*args)
  end

  def remove_column(table_name, column_name, type = nil, options = {})
    remove_column_check(column_name, table_name, options)

    super(table_name, column_name, type, **options)
  end

  private

  def rename_column_check(options)
    return if bypass_check?(options)
    return unless Birdspotting.configuration.rename_column_check?

    raise Birdspotting::RenameColumnForbiddenError, Birdspotting.configuration.rename_column_message
  end

  def add_column_position_check(options)
    return if bypass_check?(options)
    return unless Birdspotting.configuration.add_column_position_check?
    return unless options[:after].nil? && options[:first].nil?

    raise Birdspotting::ColumnPositionMissingError,
          "The :after or :first option is required when adding columns"
  end

  def encoding_check(column_name, type, options)
    return if bypass_check?(options)
    return unless Birdspotting.configuration.encoding_check?
    return unless %i[text string].include?(type)

    warn sprintf(
      Birdspotting.configuration.encoding_check_message,
      type: type,
      column_name: column_name
    )
  end

  def remove_column_check(column_name, table_name, options)
    return if bypass_check?(options)
    return unless Birdspotting.configuration.remove_column_check?

    model = model_for(table_name)

    unless model
      raise Birdspotting::ModelNotFoundError,
            "No model for `#{table_name}` table could be found. " \
            "Is the associated model preloaded?" \
            "Call the model at the beginning of the migration to ensure it is loaded." \
            "Or use the :bypass_schema_statements_check option " \
            "if you're sure of what you are doing."
    end

    if model.columns.map(&:name).include?(column_name.to_s) # rubocop:disable Style/GuardClause
      raise Birdspotting::RemoveColumnForbiddenError,
            "`#{column_name}` column should be added to ignored_columns in `#{model.name}` model" \
            " before being removed. Use #{Birdspotting.configuration.check_bypass_env_var}" \
            " env variable if you're sure of what you are doing."
    end
  end

  def model_for(table_name)
    model = ActiveRecord::Base.descendants.find { |t| t.table_name == table_name.to_s }
    model || begin
               table_name.to_s.classify.constantize
             rescue StandardError
               nil
             end
  end

  def bypass_check?(options = {})
    checkable_version? ||
      options.delete(:bypass_schema_statements_check) ||
      ENV.key?(Birdspotting.configuration.check_bypass_env_var)
  end

  def checkable_version?
    version &&
      Birdspotting.configuration.start_check_at_version &&
      version <= Birdspotting.configuration.start_check_at_version
  end

end
