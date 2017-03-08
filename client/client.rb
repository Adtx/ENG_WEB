require 'socket'
require_relative 'xdk'

HOST = 'localhost'
PORT = 5555
TEMP_SENSOR_INTERVAL = 30
NOISE_SENSOR_INTERVAL = 1
POSITION = "41º32'46.90N8º25'31.93W"


socket = TCPSocket.open(HOST, PORT)

print 'XDK id: '
id = gets

socket.puts(id.chomp!+' '+POSITION) # Envia o id e a posiçao GPS do XDK ao servidor

xdk = XDK.new(socket)

threads = []
threads << xdk.start_sensor(XDK::TEMPERATURE,TEMP_SENSOR_INTERVAL)
sleep(1) # Impede que os 2 sensores escrevam no socket ao mesmo tempo
threads << xdk.start_sensor(XDK::NOISE,NOISE_SENSOR_INTERVAL)
threads.each {|t| t.join}

socket.close