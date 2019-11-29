module Searchable

  extend ActiveSupport::Concern

  module ActiveRecord

    def searchable_columns columns
      class << self; attr_reader :search_columns_count; end
      class << self; attr_reader :search_query; end

      @search_columns_count = columns.length
      @search_query = columns.map { |c| "(#{c} ILIKE ?)" }.join(' OR ')
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
