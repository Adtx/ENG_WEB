require 'socket'
require_relative 'xdk'

HOST = 'localhost'
PORT = 5555
TEMP_SENSOR_INTERVAL = 30
NOISE_SENSOR_INTERVAL = 1
POSITION = "41º32'46.90N8º25'31.93W"

socket = TCPSocket.open(HOST, PORT)

File.exist?('cookie.txt') ? (f = File.open('cookie.txt','r'); id = f.gets; f.close) : (id = '')

socket.puts id # Diz ao servidor se ja tem ou nao id

if id == '' then id = socket.gets.chomp!; f = File.new('cookie.txt','w'); f.print id; f.close end # Se ainda nao tem id, recebe um do servidor e guarda-o num cookie

puts "ID: #{id}"

xdk = XDK.new(socket)

threads = []
threads << xdk.start_sensor(XDK::TEMPERATURE,TEMP_SENSOR_INTERVAL)
sleep(1) # Impede que os 2 sensores escrevam no socket ao mesmo tempo
threads << xdk.start_sensor(XDK::NOISE,NOISE_SENSOR_INTERVAL)

puts "\n(Any key) to exit"
gets

socket.close