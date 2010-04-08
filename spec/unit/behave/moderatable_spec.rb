require 'spec_helper'

describe Behave::Moderatable do
  class Document
    include Behave
  end
  
  class ModeratableDocument < Document
    moderatable :before => :before_method, :after => :after_method
    
    def before_method
      true
    end
    
    def after_method
    end
  end
  
  class Moderator
    include Behave
  end
  
  def mock_moderator(stubs = {})
    @mock_moderator ||= mock(Moderator, stubs)
  end
  
  it "should be included with Behave mixin" do
    Document.respond_to?(:moderatable?, true).should be true
  end

  it "should not include the moderatable behavior" do
    Document.send(:moderatable?).should be false
  end
  
  describe "#moderatable" do
    it "should include the moderatable behavior" do
      ModeratableDocument.send(:moderatable?).should be true
    end
    
    it "should define #moderated class method" do
      ModeratableDocument.should respond_to :moderated
    end
    
    it "should define #moderated_by class method" do
      ModeratableDocument.should respond_to :moderated_by
    end
    
    it "should define #moderated instance method" do
      ModeratableDocument.new.should respond_to :moderated
      ModeratableDocument.new.should respond_to :moderated=
    end

    it "should define #moderated_at instance method" do
      ModeratableDocument.new.should respond_to :moderated_at
      ModeratableDocument.new.should respond_to :moderated_at=
    end

    it "should define #moderated_by instance method" do
      ModeratableDocument.new.should respond_to :moderated_by
      ModeratableDocument.new.should respond_to :moderated_by=
    end
    
    it "should define #moderate callbacks" do
      ModeratableDocument.should respond_to :before_moderate
      ModeratableDocument.new.should respond_to :moderate
      ModeratableDocument.should respond_to :after_moderate
    end
  end
  
  describe "#moderated" do
    it "should return a criteria for selecting moderated documents" do
      ModeratableDocument.moderated.selector[:moderated].should be true
    end
  end

  describe "#moderated_by" do
    before :each do
      mock_moderator.stub(:class).and_return(Moderator)
      mock_moderator.stub(:id).and_return(42)
    end
    
    it "should return a criteria for selecting moderated documents moderated by a specific moderator" do
      selector = ModeratableDocument.moderated_by(mock_moderator).selector
      
      selector[:moderated].should be true
      selector['moderated_by._type'].should == 'Moderator'
      selector['moderated_by._id'].should be 42 
    end
  end
  
  describe "moderateing a document" do
    before :each do
      @document = ModeratableDocument.create
      
      mock_moderator.stub(:class).and_return(Moderator)
      mock_moderator.stub(:id).and_return(42)
    end
    
    after :each do
      @document.destroy
    end
    
    it "should call the before_moderate callbacks" do
      @document.should_receive(:before_method)
      @document.moderate(mock_moderator)
    end
    
    it "should call the after_moderate callbacks" do
      @document.should_receive(:after_method)
      @document.moderate(mock_moderator)
    end
    
    it "should not call the after_moderate callbacks if the callback chain is terminated" do
      @document.should_receive(:before_method).and_return(false)
      @document.should_not_receive(:after_method)
      @document.moderate(mock_moderator)
    end
    
    it "should mark the document as moderated" do
      lambda do
        @document.moderate(mock_moderator)
      end.should change(@document, :moderated).from(false).to(true)
    end
    
    it "should record the time at which the document was moderated" do
      time_now = Time.now
      
      Time.stub!(:now).and_return(time_now)
      
      @document.moderate(mock_moderator)
      @document.moderated_at.to_s.should == time_now.utc.to_s
    end
    
    it "should record the moderator of the document" do
      Moderator.stub!(:find).with(42).and_return(mock_moderator)
      
      @document.moderate(mock_moderator)
      @document.moderated_by.should be mock_moderator
    end
  end
end
