class JqgridGenerator < Rails::Generator::NamedBase
  
  attr_reader :model_name
  attr_reader :columns  
 
  def initialize(runtime_args, runtime_options = {})
    super
    puts runtime_args.inspect
    @model_name = runtime_args.delete_at(0)
    @columns = runtime_args
  end
  
  def manifest
    record do |m|
        m.route_resources plural
        m.directory("app/views/#{plural}")
        m.template('controller.rb', "app/controllers/#{plural}_controller.rb")
        m.template('index.html.erb', "app/views/#{plural}/index.html.erb")
    end
  end
    
  def plural
    model_name.pluralize
  end
  
  def camel
    model_name.camelcase
  end
  
  def klass
    @klass ||= Kernel.const_get("#{camel}")
  end

end