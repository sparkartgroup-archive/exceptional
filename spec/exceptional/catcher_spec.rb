require File.dirname(__FILE__) + '/spec_helper'

describe Exceptional::Catcher do
  describe "when Exceptional reporting is on" do
    before do
      Exceptional::Config.stub(:should_send_to_api?).and_return(true)
    end
    it "handle_with_controller should create exception_data object and send json to the api" do
      exception = mock('exception')
      controller = mock('controller')
      request = mock('request')
      Exceptional::ControllerExceptionData.should_receive(:new).with(exception,controller,request).and_return(data = mock('exception_data'))
      Exceptional::Sender.should_receive(:error).with(data)
      Exceptional::Catcher.handle_with_controller(exception,controller,request)
    end

    describe "#ignore?" do
      before do
        @exception = mock('exception')
        @controller = mock('controller')
        @request = mock('request')
      end

      it "should check for ignored classes and agents" do
        Exceptional::Catcher.should_receive(:ignore_class?).with(@exception)
        Exceptional::Catcher.should_receive(:ignore_user_agent?).with(@request)
        Exceptional::ControllerExceptionData.should_receive(:new).with(@exception,@controller,@request).and_return(data = mock('exception_data'))
        Exceptional::Sender.should_receive(:error).with(data)
        Exceptional::Catcher.handle_with_controller(@exception, @controller, @request)
      end
      it "should ignore exceptions by class name" do
        request = mock("request")
        exception = mock("exception")
        exception.stub(:class).and_return("ignore_me")
        exception.should_receive(:class)
        Exceptional::Config.ignore_exceptions = ["ignore_me",/funky/]
        Exceptional::Catcher.ignore_class?(exception).should be_true
        funky_exception = mock("exception")
        funky_exception.stub(:class).and_return("really_funky_exception")
        funky_exception.should_receive(:class)
        Exceptional::Catcher.ignore_class?(funky_exception).should be_true
      end
      it "should ignore exceptions by user agent" do
        request = mock("request")
        request.stub(:user_agent).and_return("botmeister")
        request.should_receive(:user_agent)
        Exceptional::Config.ignore_user_agents = [/bot/]
        Exceptional::Catcher.ignore_user_agent?(request).should be_true
      end
    end
    # it "handle_with_rack should create exception_data object and send json to the api"
    # it "handle should create exception_data object and send json to the api"
  end

  describe "when Exceptional reporting is off" do
    before do
      Exceptional::Config.stub(:should_send_to_api?).and_return(false)
    end
    it "handle_with_controller should reraise the exception and not report it" do
      exception = mock('exception')
      controller = mock('controller')
      request = mock('request')
      Exceptional::ControllerExceptionData.should_not_receive(:new)
      Exceptional::Sender.should_not_receive(:error)
      expect{
        Exceptional::Catcher.handle_with_controller(exception,controller,request)
      }.to raise_error
    end
    # it "handle_with_rack should reraise the exception and not report it"
    # it "handle should reraise the exception and not report it"
  end
end
