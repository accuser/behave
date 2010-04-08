require 'spec_helper'

describe Behave::Containable do
  class Document
    include Behave
    
    field :title
    field :body
  end
  
  class ContainableDocument < Document
    containable
  end
  
  it "should be included with Behave mixin" do
    Document.respond_to?(:containable?, true).should be true
  end

  it "should not include the containable behavior" do
    Document.send(:containable?).should be false
  end
  
  describe "#containable" do
    it "should include the containable behavior" do
      ContainableDocument.send(:containable?).should be true
    end
    
    it "should define #container field" do
      ContainableDocument.new.should respond_to :container
      ContainableDocument.new.should respond_to :container=
    end
  end
end
