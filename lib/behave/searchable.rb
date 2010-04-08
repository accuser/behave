require 'active_support'
require 'sunspot'

module Behave
  module Behaviors
    extend ActiveSupport::Concern
  
    module ClassMethods
      def searchable(options = {}, &block)
        options.symbolize_keys!
        options.reverse_merge :delay => true
        
        class_inheritable_hash :searchable_options
        
        self.searchable_options = options
        
        Sunspot.setup(self, &block)
      
        include Behave::Searchable unless searchable?
      end

      private
        def searchable?
          false
        end
    end
  end
  
  module Searchable
    extend ActiveSupport::Concern
    
    included do
      Sunspot::Adapters::DataAccessor.register(DataAccessor, self)
      Sunspot::Adapters::InstanceAdapter.register(InstanceAdapter, self)

      after_save :index
      after_destroy :remove_from_index
    end

    module ClassMethods
      def search(&block)
        Sunspot.new_search(self, &block).execute
      end
      
      def search_ids(&block)
        search(&block).raw_results.map { |raw_result| raw_result.id.to_s }
      end
      
      private
        def searchable?
          true
        end
    end
    
    module InstanceMethods
      # Update the search index with the searchable item.
      def index
        if searchable_options[:delay]
          Delayed::Job.enqueue Behave::Searcahble::IndexJob.new(self)
        else
          Sunspot.index(self)
        end
      end

      # Remove the searchable item from the search index.
      def remove_from_index
        if searchable_options[:delay]
          Delayed::Job.enqueue Behave::Searcahble::RemoveFromIndexJob.new(self)
        else
          Sunspot.remove(self)
        end
      end
      
      private
        def searchable_options
          self.class.searchable_options
        end
    end
  
    class DataAccessor < Sunspot::Adapters::DataAccessor
      def load(id)
        @clazz.find(id)
      end
  
      def load_all(ids)
        @clazz.criteria.where(:_id.in => ids)
      end
    end

    class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
      def id
        @instance.id
      end
    end
    
    class IndexJob < Struct(:searchable)
      def perform
        Sunspot.index! self.searchable
      end
    end
    
    class RemoveFromIndexJob < Struct(:searchable)
      def perform
        Sunspot.remove! self.searchable
      end
    end
  end
end
