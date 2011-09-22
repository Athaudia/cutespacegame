require 'eventmachine'
require 'json'
require 'digest/sha2'

def read game
	fname = "scores/#{game.gsub(/[^a-zA-Z0-9_-]/, '_')}.txt"
	begin
		JSON::load File::read(fname)
	rescue
		[]
	end
end

def save game, data
	fname = "scores/#{game.gsub(/[^a-zA-Z0-9_-]/, '_')}.txt"
	File::open(fname, 'w') do |file|
		file.write JSON::dump(data)
	end
end

module Server
	include EM::P::ObjectProtocol
	def receive_object(data)
		puts data.inspect
		case data['cmd']
		when 'get_top10'
			begin
				send_object({scores: read(data['game'])[0,10]})
			rescue => e
				send_object(error: "#{e.message}\n#{e.backtrace.join("\n")}")
			end
		when 'send_score'
			begin
				game = data['game']
				scores = read(game)
				data.delete 'cmd'
				data.delete 'game'
				scores << data
				scores.sort! do |a,b|
					b['score'] <=> a['score']
				end
				bb = []
				scores.select!{|a| if bb.include?(a['name']) then false else bb+=[a['name']]; true end}
				save game, scores
				send_object({})
			rescue => e
				send_object(error: "#{e.message}\n#{e.backtrace.join("\n")}")
			end
		when 'admin_get'
			begin
				game = data['game']
				tok = File.read 'admintoken.pub'
				if tok != Digest::SHA256.new.update(data['token']).hexdigest
					send_object(error: "wrong admin password")
				else
					send_object(data: read(game))
				end
			rescue => e
				send_object(error: "#{e.message}\n#{e.backtrace.join("\n")}")
			end
		when 'admin_set'
			begin
				game = data['game']
				tok = File.read 'admintoken.pub'
				if tok != Digest::SHA256.new.update(data['token']).hexdigest
					send_object(error: "wrong admin password")
				else
					save game, data['data']
					send_object({})
				end
			rescue => e
				send_object(error: "#{e.message}\n#{e.backtrace.join("\n")}")
			end
		when nil
			puts 'malformed request'
		end
	end

	def serializer; JSON; end
end

EM.run do
	EM.start_server '127.0.0.1', 4345, Server
end
