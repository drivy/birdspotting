module Birdspotting::ReorderColumns

  def reorder_columns_for(table_name, ordered_columns)
    check_if_supported
    check_all_columns_present(ordered_columns, table_name)

    column_types = column_types(table_name)

    count = 0
    ordered_columns.zip(ordered_columns.rotate)[0...-1].each do |column, column_after|
      sql_type = column_types[column_after.to_s]
      sql = <<~SQL
        ALTER TABLE #{table_name} MODIFY COLUMN #{column_after} #{sql_type} AFTER #{column}, ALGORITHM=INPLACE, LOCK=NONE
      SQL

      message = "Moving #{column_after} after #{column} (#{count += 1} of #{ordered_columns.count})"
      say_with_time message do
        ActiveRecord::Base.connection.execute sql
      end
    end
  end

  private

  def check_all_columns_present(ordered_columns, table_name)
    columns = ActiveRecord::Base.connection.columns(table_name)
    return if Set.new(ordered_columns.map(&:to_s)) == Set.new(columns.map(&:name))

    raise Birdspotting::MismatchedColumnsError,
          "All columns must be present on the #{table_name} table"
  end

  def column_types(table_name)
    table_definition = ActiveRecord::Base
                       .connection
                       .execute("SHOW CREATE TABLE `#{table_name}`")
                       .to_h[table_name.to_s]
    column_definitions = table_definition.lines.map(&:strip).select { |l| l.starts_with?("`") }

    Hash[column_definitions.map { |d| d.match(/`(.*)`\s*(.+?)(,|)\z/)[1, 2] }]
  end

  def check_if_supported
    return if ActiveRecord::Base.connection_config[:adapter] == "mysql2"

    raise Birdspotting::UnsupportedAdapterError,
          "reorder_columns_for only supported with mysql2 adapter"
  end

end
