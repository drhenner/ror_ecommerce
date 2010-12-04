require 'rubygems'
require File.dirname(__FILE__) + '/../lib/prawnto'

module TemplateHandlerTestMocks

  class Template
    attr_reader :source, :locals, :filename

    def initialize(source, locals={})
      @source = source
      @locals = locals
      @filename = "blah.pdf"
    end
  end


  class Response
    def initialize
      @headers = {}
    end

    def headers
      @headers
    end

    def content_type=(value)
    end
  end

  class Request
    def env
      {}
    end
  end

  class ActionController

    include Prawnto::ActionController

    def response
      @response ||= Response.new
    end

    def request
      @request ||= Request.new
    end

    def headers
      response.headers
    end
  end
    
  class ActionView
    def controller
      @controller ||= ActionController.new
    end

    def response
      controller.response
    end

    def request
      controller.request
    end

    def headers
      controller.headers
    end

    def prawnto_options
      controller.get_instance_variable(:@prawnto_options)
    end
  end


end

