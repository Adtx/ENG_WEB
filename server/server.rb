require 'socket'
require 'sqlite3'
require_relative 'handlers'

server_socket = TCPServer.new 5555
db = SQLite3::Database.new 'iot.db'

AdminHandler.new db

loop{
	client_socket = server_socket.accept    # Wait for a client to connect
	puts "Client info: #{client_socket.gets}"
	ClientHandler.new(client_socket, db)
}