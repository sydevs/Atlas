module Searchable

  extend ActiveSupport::Concern

  module ActiveRecord

    def searchable_columns columns
      class << self
        attr_reader :search_columns_count
        attr_reader :search_query

        def searchable
          true
        end
      end

      @search_columns_count = columns.length
      @search_query = columns.map { |c| "(#{c}::text ILIKE ?)" }.join(' OR ')
    end

  end

  module ClassMethods

    def search query
      if query.present? && search_query.present?
        where(search_query, *Array.new(search_columns_count, "%#{query}%"))
      else
        where(nil)
      end
    end

  end

end

ActiveRecord::Base.extend(Searchable::ActiveRecord)
