require 'socket'

server_socket = TCPServer.new 5555

loop{
	client_socket = server_socket.accept    # Wait for a client to connect
	puts "Client info: #{client_socket.gets}"
}