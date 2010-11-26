require 'rubygems'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'

require 'test/unit'
require File.dirname(__FILE__) + '/../lib/prawnto'


class ActionControllerTest < Test::Unit::TestCase
  class PrawntoController < ActionController::Base
    prawnto :inline=>true, :prawn=>{:page_orientation=>:landscape}

    def test
      prawnto :inline=>false, :prawn=>{:page_size=>'A4'}
    end
  end

  def test_inheritable_options
    assert_equal({:page_orientation=>:landscape}, PrawntoController.read_inheritable_attribute(:prawn))
    assert_equal({:inline=>true}, PrawntoController.read_inheritable_attribute(:prawnto))
  end

  def test_computed_options
    controller = PrawntoController.new
    test_process(controller)
    assert_equal({:inline=>false, :prawn=>{:page_orientation=>:landscape, :page_size=>'A4'}}, controller.send(:compute_prawnto_options))
  end

  # Controller with default false inline
  class PrawntoControllerWithFalseInline < ActionController::Base
    prawnto :inline=>false, :prawn=>{:page_orientation=>:landscape}

    def test
      prawnto :prawn=>{:page_size=>'A4'}
    end
  end

  def test_default_false_inline_should_not_be_overrided_automatically
    assert_equal({:inline=>false}, PrawntoControllerWithFalseInline.read_inheritable_attribute(:prawnto))

    controller = PrawntoControllerWithFalseInline.new
    test_process(controller)
    assert_equal({:inline=>false, :prawn=>{:page_orientation=>:landscape, :page_size=>'A4'}}, controller.send(:compute_prawnto_options))
  end

  # Controller without default inline
  class PrawntoControllerWithoutInline < ActionController::Base
    prawnto :prawn=>{:page_orientation=>:landscape}

    def test
      prawnto :prawn=>{:page_size=>'A4'}
    end
  end

  def test_inline_should_be_a_true_by_default
    assert_equal({:inline=>true}, PrawntoControllerWithoutInline.read_inheritable_attribute(:prawnto))

    controller = PrawntoControllerWithoutInline.new
    test_process(controller)
    assert_equal({:inline=>true, :prawn=>{:page_orientation=>:landscape, :page_size=>'A4'}}, controller.send(:compute_prawnto_options))
  end
  
protected
  def test_process(controller, action = "test")
    request = ActionController::TestRequest.new
    request.action = action
    controller.process(request, ActionController::TestResponse.new)
  end

end

