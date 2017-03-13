module Handlers

	require_relative 'menu'

	CONNECTED = 1
	DISCONNECTED = 0

	class ClientHandler < Thread

		def initialize(client_socket, database)
			super(client_socket, database) {|cs, db|
				
				client_id = (db.execute 'select count(*) from xdks')[0][0] # Atribui id ao cliente

				db.execute 'insert into xdks values(?,?,?);', client_id.to_s,'foobar',1

				print "\n\n[Client \##{client_id} is now connected!]\n\n"

				client_socket.puts client_id.to_s # Envia ao cliente o id atribuido

				readings = 0
				while line = cs.gets
					#puts cs.gets
					values = line.chomp!.split('#')
					readings += 1;
					db.execute 'insert into readings values(?,?,?,?);', values[0],values[1],values[2],client_id
				end

				cs.close

				db.execute "update xdks set status=#{DISCONNECTED} where id=\'#{client_id.to_s}\';"

				print "\n\n[Client \##{client_id} is now disconnected! (\# readings: #{readings})]\n\n"
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
						puts 'LOCATION 	  VALUE    TIMESTAMP'
						db.execute "SELECT location,value,timestamp FROM readings where xdk_id==#{input[1]}" do |row|
	  						puts "- #{row[0]} 	  #{row[1]} 	#{row[2]}"
						end
					end
					Menu.clear
				}		
			}
		end
	end
end