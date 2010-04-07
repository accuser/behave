class CachedDocument
  def initialize(attributes)
    @cached_attributes = attributes
  end
  
  class << self
    def set(value)
      if value.methods.respond_to? :cachable_attributes
        value.cachable_attributes
      else
        { '_type' => value.class.to_s, '_id' => value._id }
      end
    end
    
    def get(value)
      self.new(value)
    end
  end
  
  def ==(value)
    _document == value
  end
  
  alias_method :eql?, :==
  alias_method :equal?, :==
  
  def method_missing(name, *args, &block)
    if @document
      _document.send name, *args, &block
    elsif @cached_attributes.has_key? name.to_s
      @cached_attributes[name.to_s]
    else
      Rails.logger.debug("#{@cached_attributes['_type']}[:#{name}] is not cached (called from #{caller(1).first})")
      _document.send name, *args, &block
    end
  end

  private
    def _document
      @document ||= @cached_attributes['_type'].constantize.find(@cached_attributes['_id'])
    end
end
