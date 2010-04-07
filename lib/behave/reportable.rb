require 'active_model'
require 'active_support'
require 'cached_document'
require 'mongoid'

module Behave
  module Behaviors
    extend ActiveSupport::Concern

    module ClassMethods
      def reportable(options = {})
        include Behave::Reportable unless reportable?

        if options.has_key? :before
          before_report options[:before]
        end
        
        if options.has_key? :after
          after_report options[:after]
        end
      end
    
      private
        def reportable?
          false
        end
    end
  end
  
  module Reportable
    extend ActiveSupport::Concern

    included do
      field :reported, :type => Boolean, :default => false
      field :reported_at, :type => Time
      field :reported_by, :type => CachedDocument
      
      define_model_callbacks :report
    end

    module ClassMethods
      def reported
        criteria.where :reported => true
      end

      def reported_by(reporter)
        reported.where 'reported_by._type' => reporter._type, 'reporter_by._id' => reporter._id
      end
      
      private
        def reportable?
          true
        end
    end

    module InstanceMethods
      def report(reporter)
        unless reported?
          _run_report_callbacks do
            update_attributes :reported => true, :reported_at => Time.now, :reported_by => reporter
          end
        end

        reported?
      end
    end
  end
end
