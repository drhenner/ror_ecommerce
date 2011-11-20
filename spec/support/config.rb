# start the Solr server and give it a few seconds to initialize
#Sunspot::Rails::Server.start
#sleep 5
if defined?(Sunspot)#Product.solr_search)
  Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
end