require 'socket'
require 'json'
#require 'eventmachine'

module Scores
	def self.get
		send_cmd(cmd: :get_top10, game: :csg_0_3)['scores']
	end

	def self.send_cmd cmd
		str = JSON::dump(cmd)
		TCPSocket.open('127.0.0.1', 4345) do |sock|
			sock.puts([str.size, str].pack('Na*'))
			len = sock.read(4)
			if not len or len.size != 4 then return nil end
			len = len.unpack('N')[0]
			data = sock.read(len)
			if not data or data.size != len then return nil end
			return JSON::load(data)
		end
	end
end

puts Scores::get.inspect