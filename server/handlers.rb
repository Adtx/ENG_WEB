module Handlers

	require_relative 'menu'

	CONNECTED = 1
	DISCONNECTED = 0

	class ClientHandler < Thread

		def initialize(client_socket, database)
			super(client_socket, database) {|cs, db|
				
				client_id = (db.execute 'select count(*) from xdks')[0][0] # Atribui id ao cliente

				db.execute 'insert into xdks values(?,?,?);', client_id.to_s,'foobar',1

				client_socket.puts client_id.to_s # Envia ao cliente o id atribuido

				while line = cs.gets
					#puts cs.gets
					values = line.chomp!.split('#')

					db.execute 'insert into readings values(?,?,?,?);', values[0],values[1],values[2],client_id
				end

				cs.close

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
						puts 'ID 	LOCATION'
						db.execute "SELECT id,location FROM xdks where status==#{CONNECTED}" do |row|
	  						puts "- #{row[0]} 	#{row[1]}"
						end
					when Menu::SHOW_READINGS
						puts "procurar leituras do xdk #{input[1]} na tabela 'leituras'"
					end
					Menu.clear
				}		
			}
		end
	end
end