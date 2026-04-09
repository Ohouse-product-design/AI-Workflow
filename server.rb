require 'webrick'
server = WEBrick::HTTPServer.new(
  Port: 8080,
  DocumentRoot: '/Users/yohan.lee/Desktop/Claude_Study/design-workflow'
)
trap('INT') { server.shutdown }
server.start
