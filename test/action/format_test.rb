require 'test_helper'
require 'json'

describe Hanami::Action do
  class FormatController
    class Lookup
      include Hanami::Action
      configuration.handle_exceptions = false

      def call(params)
      end
    end

    class JsonLookup
      include Hanami::Action
      configuration.handle_exceptions = false
      configuration.default_request_format :html
      accept :json

      def call(params)
      end
    end

    class Custom
      include Hanami::Action
      configuration.handle_exceptions = false

      def call(params)
        self.format = params[:format]
      end
    end

    class Configuration
      include Hanami::Action

      configuration.default_request_format :jpg

      def call(params)
        self.body = format
      end
    end
  end

  describe '#format' do
    before do
      @action = FormatController::Lookup.new
    end

    it 'lookup to #content_type if was not explicitly set (default: application/octet-stream)' do
      status, headers, _ = @action.call({})

      @action.format.must_equal   :all
      headers['Content-Type'].must_equal 'application/octet-stream; charset=utf-8'
      status.must_equal                  200
    end

    it "accepts 'text/html' and returns :html" do
      status, headers, _ = @action.call({ 'HTTP_ACCEPT' => 'text/html' })

      @action.format.must_equal    :html
      headers['Content-Type'].must_equal 'text/html; charset=utf-8'
      status.must_equal                   200
    end

    it "accepts unknown mime type and returns :all" do
      status, headers, _ = @action.call({ 'HTTP_ACCEPT' => 'application/unknown' })

      @action.format.must_equal    :all
      headers['Content-Type'].must_equal 'application/octet-stream; charset=utf-8'
      status.must_equal                   200
    end

    # Bug
    # See https://github.com/hanami/controller/issues/104
    it "accepts 'text/html, application/xhtml+xml, image/jxr, */*' and returns :html" do
      status, headers, _ = @action.call({ 'HTTP_ACCEPT' => 'text/html, application/xhtml+xml, image/jxr, */*' })

      @action.format.must_equal    :html
      headers['Content-Type'].must_equal 'text/html; charset=utf-8'
      status.must_equal                   200
    end

    it "accepts default IE8 header accept value and returns :html" do
      ie8_accept = 'image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/x-shockwave-flash, application/msword, */*'
      status, headers, _ = @action.call({
        'HTTP_ACCEPT' => ie8_accept,
        'HTTP_USER_AGENT' => 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)'
      })

      @action.format.must_equal    :html
      headers['Content-Type'].must_equal 'text/html; charset=utf-8'
      status.must_equal                   200
    end

    it "accepts 'application/json, text/plain, */*' and returns :json" do
      @action = FormatController::JsonLookup.new

      status, headers, _ = @action.call({ 'HTTP_ACCEPT' => 'application/json, text/plain, */*' })

      @action.format.must_equal    :json
      headers['Content-Type'].must_equal 'application/json; charset=utf-8'
      status.must_equal                   200
    end

    # Bug
    # See https://github.com/hanami/controller/issues/167
    it "accepts '*/*' and returns configured default format" do
      action = FormatController::Configuration.new
      status, headers, _ = action.call({ 'HTTP_ACCEPT' => '*/*' })

      action.format.must_equal    :jpg
      headers['Content-Type'].must_equal 'image/jpeg; charset=utf-8'
      status.must_equal                   200
    end

    Hanami::Action::Mime::MIME_TYPES.each do |format, mime_type|
      it "accepts '#{ mime_type }' and returns :#{ format }" do
        status, headers, _ = @action.call({ 'HTTP_ACCEPT' => mime_type })

        @action.format.must_equal   format
        headers['Content-Type'].must_equal "#{mime_type}; charset=utf-8"
        status.must_equal                  200
      end
    end
  end

  describe '#format=' do
    before do
      @action = FormatController::Custom.new
    end

    it "sets :all and returns 'application/octet-stream'" do
      status, headers, _ = @action.call({ format: 'all' })

      @action.format.must_equal   :all
      headers['Content-Type'].must_equal 'application/octet-stream; charset=utf-8'
      status.must_equal                  200
    end

    it "sets nil and raises an error" do
      -> { @action.call({ format: nil }) }.must_raise TypeError
    end

    it "sets '' and raises an error" do
      -> { @action.call({ format: '' }) }.must_raise TypeError
    end

    it "sets an unknown format and raises an error" do
      begin
        @action.call({ format: :unknown })
      rescue => e
        e.must_be_kind_of(Hanami::Controller::UnknownFormatError)
        e.message.must_equal "Cannot find a corresponding Mime type for 'unknown'. Please configure it with Hanami::Controller::Configuration#format."
      end
    end

    Hanami::Action::Mime::MIME_TYPES.each do |format, mime_type|
      it "sets #{ format } and returns '#{ mime_type }'" do
        _, headers, _ = @action.call({ format: format })

        @action.format.must_equal   format
        headers['Content-Type'].must_equal "#{mime_type}; charset=utf-8"
      end
    end
  end
end
