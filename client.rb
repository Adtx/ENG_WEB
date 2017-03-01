require 'socket'

HOST = 'localhost'
PORT = 5555

POSITION = "41º32'46.90N8º25'31.93W"


socket = TCPSocket.open(HOST, PORT)

print 'XDK id: '
id = gets

socket.puts(id.chomp!+' '+POSITION) # Envia o id e a posiçao GPS do XDK ao servidor

socket.close