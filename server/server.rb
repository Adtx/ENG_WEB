require 'socket'
require 'sqlite3'
require_relative 'handlers'


server_socket = TCPServer.new 5555

db = SQLite3::Database.new 'iot.db'

Handlers::AdminHandler.new db

loop{
	client_socket = server_socket.accept    # Wait for a client to connect
	Handlers::ClientHandler.new client_socket, db
}