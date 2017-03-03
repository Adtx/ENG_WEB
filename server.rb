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

class Menu

    SHOW_CONNECTED = '1'
    SHOW_READINGS = '2'

	MENU = "\n\nChoose an option (1 or 2)\n\n1: Show connected XDKs\n2: Show readings\n\n";
	
	def self.display
		print MENU
	end

	def self.get_input
		user_input = []
		input = gets.chomp!

		user_input << input

		if input == SHOW_READINGS
			print 'XDK id: '
			input = gets.chomp!
			user_input << input
		end

		return user_input
	end
end

class AdminHandler < Thread

	def initialize(database)
		super(database) {|db|
			loop {
				Menu.display
				input = Menu.get_input
				case input[0]
				when Menu::SHOW_CONNECTED
					puts 'procurar na tabela dos xdks'
				when Menu::SHOW_READINGS
					puts "procurar leituras do xdk #{input[1]} na tabela 'leituras'"
				end
				# Limpar ecran
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