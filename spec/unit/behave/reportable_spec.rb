require 'spec_helper'

describe Behave::Reportable do
  class Document
    include Behave
  end
  
  class ReportableDocument < Document
    reportable :before => :before_method, :after => :after_method
    
    def before_method
      true
    end
    
    def after_method
    end
  end
  
  class Reporter
    include Behave
  end
  
  def mock_reporter(stubs = {})
    @mock_reporter ||= mock(Reporter, stubs)
  end
  
  it "should be included with Behave mixin" do
    Document.respond_to?(:reportable?, true).should be true
  end

  it "should not include the reportable behavior" do
    Document.send(:reportable?).should be false
  end
  
  describe "#reportable" do
    it "should include the reportable behavior" do
      ReportableDocument.send(:reportable?).should be true
    end
    
    it "should define #reported class method" do
      ReportableDocument.should respond_to :reported
    end
    
    it "should define #reported_by class method" do
      ReportableDocument.should respond_to :reported_by
    end
    
    it "should define #reported instance method" do
      ReportableDocument.new.should respond_to :reported
      ReportableDocument.new.should respond_to :reported=
    end

    it "should define #reported_at instance method" do
      ReportableDocument.new.should respond_to :reported_at
      ReportableDocument.new.should respond_to :reported_at=
    end

    it "should define #reported_by instance method" do
      ReportableDocument.new.should respond_to :reported_by
      ReportableDocument.new.should respond_to :reported_by=
    end
    
    it "should define #report callbacks" do
      ReportableDocument.should respond_to :before_report
      ReportableDocument.new.should respond_to :report
      ReportableDocument.should respond_to :after_report
    end
  end
  
  describe "#reported" do
    it "should return a criteria for selecting reported documents" do
      ReportableDocument.reported.selector[:reported].should be true
    end
  end

  describe "#reported_by" do
    before :each do
      mock_reporter.stub(:class).and_return(Reporter)
      mock_reporter.stub(:id).and_return(42)
    end
    
    it "should return a criteria for selecting reported documents reported by a specific reporter" do
      selector = ReportableDocument.reported_by(mock_reporter).selector
      
      selector[:reported].should be true
      selector['reported_by._type'].should == 'Reporter'
      selector['reported_by._id'].should be 42 
    end
  end
  
  describe "reporting a document" do
    before :each do
      @document = ReportableDocument.create
      
      mock_reporter.stub(:class).and_return(Reporter)
      mock_reporter.stub(:id).and_return(42)
    end
    
    after :each do
      @document.destroy
    end
    
    it "should call the before_report callbacks" do
      @document.should_receive(:before_method)
      @document.report(mock_reporter)
    end
    
    it "should call the after_report callbacks" do
      @document.should_receive(:after_method)
      @document.report(mock_reporter)
    end
    
    it "should not call the after_report callbacks if the callback chain is terminated" do
      @document.should_receive(:before_method).and_return(false)
      @document.should_not_receive(:after_method)
      @document.report(mock_reporter)
    end
    
    it "should mark the document as reported" do
      lambda do
        @document.report(mock_reporter)
      end.should change(@document, :reported).from(false).to(true)
    end
    
    it "should record the time at which the document was reported" do
      time_now = Time.now
      
      Time.stub!(:now).and_return(time_now)
      
      @document.report(mock_reporter)
      @document.reported_at.to_s.should == time_now.utc.to_s
    end
    
    it "should record the reporter of the document" do
      Reporter.stub!(:find).with(42).and_return(mock_reporter)
      
      @document.report(mock_reporter)
      @document.reported_by.should be mock_reporter
    end
  end
end
