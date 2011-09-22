require 'eventmachine'
require 'json'

module Server
	include EM::P::ObjectProtocol
	def receive_object(data)
		puts data.inspect
		case data['cmd']
		when 'get_top10'
			scores = [{name: 'Athaudia', score: 100000}, {name: 'Athea', score: 14564}]
			send_object({scores: scores})
		when nil
			puts 'malformed request'
		end
	end

	def serializer; JSON; end
end

EM.run do
	EM.start_server '127.0.0.1', 4345, Server
end
