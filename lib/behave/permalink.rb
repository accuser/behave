require 'active_support'
require 'mongoid'

module Behave
  module Behaviors
    extend ActiveSupport::Concern
  
    module ClassMethods
      def permalink(options = {})
        options.symbolize_keys!
        options.reverse_merge! :param => true

        class_inheritable_hash :permalink_options
        
        self.permalink_options = options

        include Permalink unless permalink?

        before_save :set_permalink, :if => :set_permalink?
      end
  
      private
        def permalink?
          false
        end
    end
  end
  
  module Permalink
    extend ActiveSupport::Concern

    included do
      field :permalink
      
      index :permalink
    end
    
    module ClassMethods
      private
        def permalink?
          true
        end
    end

    module InstanceMethods
      # Return a String representation of the resource that will be used in
      # contstructing the URI for the resource. 
      def to_param_with_permalink
        if self.permalink_options[:param]
          self.permalink
        else
          to_param_without_permalink
        end
      end
      
      alias_method_chain :to_param, :permalink
      
      private
        def escape_permalink(s)
          returning(s = s.to_s.dup.mb_chars.normalize(:kd)) do
            s.gsub!(/[^\w -]+/n, '')
            s.strip!
            s.downcase!
            s.gsub!(/[ -]+/, '-')
          end
        end

        def get_permalink
          case self.permalink_options[:with]
          when Symbol
            self.permalink = send(self.permalink_options[:with])
          when Proc
            self.permalink = self.permalink_options[:with].call(self)
          when Array
            get_permalink_for self.permalink_options[:with]
          else
            self.id.to_s
          end
        end
        
        def get_permalink_for(attr_names)
          escape_permalink attr_names.collect { |attr_name| send(attr_name).to_s }.join(' ')
        end
        
        # Set the +permalink+.
        def set_permalink
          self.permalink = get_permalink
        end

        # Returns +true+ if the +permalink+ should be set.
        def set_permalink?
          new_record? || self.permalink_options[:update]
        end
    end
  end
end
