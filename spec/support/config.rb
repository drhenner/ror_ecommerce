# start the Solr server and give it a few seconds to initialize
#Sunspot::Rails::Server.start
#sleep 5
Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)