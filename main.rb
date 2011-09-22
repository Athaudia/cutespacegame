$startuptime = Time.now
puts "Preparing game, please wait..."
$config = {:stars => :cached, :control => :mouse}

require 'chingu'
require 'texplay'
require 'require_all'
include Gosu

Image.autoload_dirs = ["data/gfx"]

require_all 'src'

Dir.chdir File.dirname($0) #for ocra
VERSION = begin open("version.txt", "r") {|f| f.read} rescue "-unknown-" end
MainWindow.new.show