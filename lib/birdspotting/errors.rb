module Birdspotting

  class Error < StandardError
  end

  class ColumnPositionMissingError < Error
  end

  class RemoveColumnForbiddenError < Error
  end

  class ModelNotFoundError < Error
  end

  class RenameColumnForbiddenError < Error
  end

  class UnsupportedAdapterError < Error
  end

  class MismatchedColumnsError < Error
  end

end
