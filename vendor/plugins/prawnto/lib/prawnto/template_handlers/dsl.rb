module Prawnto
  module TemplateHandlers
    class Dsl < Base
      
      def compile(template)
        "_prawnto_compile_setup(true);" +
        "pdf = Prawn::Document.new(@prawnto_options[:prawn]);" + 
        "pdf.instance_eval do; #{template.source}\nend;" +
        "pdf.render;"
      end

    end
  end
end


