require 'action_controller'
require 'action_view'

require 'prawn'
#begin 
  #require "prawn/layout" # give people what they probably want
#rescue LoadError
#end

require 'prawnto/action_controller'
require 'prawnto/action_view'

require 'prawnto/template_handler/compile_support'

require 'prawnto/template_handlers/base'
#require 'prawnto/template_handlers/raw'

# for now applying to all Controllers
# however, could reduce footprint by letting user mixin (i.e. include) only into controllers that need it
# but does it really matter performance wise to include in a controller that doesn't need it?  doubtful-- depends how much of a hit the before_filter is i guess.. 
#

class ActionController::Base
  include Prawnto::ActionController
end

class ActionView::Base
  include Prawnto::ActionView
end



