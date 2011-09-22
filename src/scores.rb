require 'socket'
require 'json'

module Scores
	def self.get
		begin
			r = send_cmd(cmd: :get_top10, game: :csg_0_3)
			if r['error']
				puts 'score server error:'
				puts r['error']
				[]
			else
				r['scores']
			end
		rescue
			[]
		end
	end

	def self.send data
		data[:cmd] = :send_score
		begin
			r = self.send_cmd(data)
			if r['error']
				puts 'score server error:'
				puts r['error']
			end
		rescue
			nil
		end
	end

	def self.send_cmd cmd
		str = JSON::dump(cmd)
		TCPSocket.open('lmao.rotfl.at', 4345) do |sock|
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

#puts Scores::send(name: 'Wheee!!!', score: 1000000, time: 650.2, wave: 1, game: :csg_0_3)
#puts Scores::get.inspect