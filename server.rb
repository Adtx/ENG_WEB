require 'socket'
require 'sqlite3'


class ClientHandler < Thread

	def initialize(client_socket, database)
		super(client_socket, database) {|cs, db|
			client_info = client_socket.gets
			loop{
				puts cs.gets
			}
		}
	end
end


class AdminHandler < Thread

	def initialize(database)
		super(database) {|db|
			loop {
				# Mostrar menu e servir o pedido
			}		
		}
	end
end



server_socket = TCPServer.new 5555
db = SQLite3::Database.new 'iot.db'

AdminHandler.new db

loop{
	client_socket = server_socket.accept    # Wait for a client to connect
	puts "Client info: #{client_socket.gets}"
	ClientHandler.new(client_socket, db)
}