module Handlers

	require_relative 'menu'

	CONNECTED = 1
	DISCONNECTED = 0

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
					Menu.display
					input = Menu.get_input
					case input[0]
					when Menu::SHOW_CONNECTED
						puts 'procurar na tabela dos xdks'
					when Menu::SHOW_READINGS
						puts "procurar leituras do xdk #{input[1]} na tabela 'leituras'"
					end
					Menu.clear
				}		
			}
		end
	end
end