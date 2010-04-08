require 'spec_helper'

describe Behave::Publishable do
  class Document
    include Behave
  end
  
  class PublishableDocument < Document
    publishable :before => :before_method, :after => :after_method
    
    def before_method
      true
    end
    
    def after_method
    end
  end
  
  class Publisher
    include Behave
  end
  
  def mock_publisher(stubs = {})
    @mock_publisher ||= mock(Publisher, stubs)
  end
  
  it "should be included with Behave mixin" do
    Document.respond_to?(:publishable?, true).should be true
  end

  it "should not include the publishable behavior" do
    Document.send(:publishable?).should be false
  end
  
  describe "#publishable" do
    it "should include the publishable behavior" do
      PublishableDocument.send(:publishable?).should be true
    end
    
    it "should define #published class method" do
      PublishableDocument.should respond_to :published
    end
    
    it "should define #published_by class method" do
      PublishableDocument.should respond_to :published_by
    end
    
    it "should define #published instance method" do
      PublishableDocument.new.should respond_to :published
      PublishableDocument.new.should respond_to :published=
    end

    it "should define #published_at instance method" do
      PublishableDocument.new.should respond_to :published_at
      PublishableDocument.new.should respond_to :published_at=
    end

    it "should define #published_by instance method" do
      PublishableDocument.new.should respond_to :published_by
      PublishableDocument.new.should respond_to :published_by=
    end
    
    it "should define #publish callbacks" do
      PublishableDocument.should respond_to :before_publish
      PublishableDocument.new.should respond_to :publish
      PublishableDocument.should respond_to :after_publish
    end
  end
  
  describe "#published" do
    it "should return a criteria for selecting published documents" do
      PublishableDocument.published.selector[:published].should be true
    end
  end

  describe "#published_by" do
    before :each do
      mock_publisher.stub(:class).and_return(Publisher)
      mock_publisher.stub(:id).and_return(42)
    end
    
    it "should return a criteria for selecting published documents published by a specific publisher" do
      selector = PublishableDocument.published_by(mock_publisher).selector
      
      selector[:published].should be true
      selector['published_by._type'].should == 'Publisher'
      selector['published_by._id'].should be 42 
    end
  end
  
  describe "publishing a document" do
    before :each do
      @document = PublishableDocument.create
      
      mock_publisher.stub(:class).and_return(Publisher)
      mock_publisher.stub(:id).and_return(42)
    end
    
    after :each do
      @document.destroy
    end
    
    it "should call the before_publish callbacks" do
      @document.should_receive(:before_method)
      @document.publish(mock_publisher)
    end
    
    it "should call the after_publish callbacks" do
      @document.should_receive(:after_method)
      @document.publish(mock_publisher)
    end
    
    it "should not call the after_publish callbacks if the callback chain is terminated" do
      @document.should_receive(:before_method).and_return(false)
      @document.should_not_receive(:after_method)
      @document.publish(mock_publisher)
    end
    
    it "should mark the document as published" do
      lambda do
        @document.publish(mock_publisher)
      end.should change(@document, :published).from(false).to(true)
    end
    
    it "should record the time at which the document was published" do
      time_now = Time.now
      
      Time.stub!(:now).and_return(time_now)
      
      @document.publish(mock_publisher)
      @document.published_at.to_s.should == time_now.utc.to_s
    end
    
    it "should record the publisher of the document" do
      Publisher.stub!(:find).with(42).and_return(mock_publisher)
      
      @document.publish(mock_publisher)
      @document.published_by.should be mock_publisher
    end
  end
end
