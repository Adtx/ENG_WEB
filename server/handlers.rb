module Handlers
	require_relative 'menu'

	CONNECTED = 1
	DISCONNECTED = 0

	class ClientHandler < Thread

		attr_writer :notify_admin, :admin_notifications, :admin_notification_thread

		def initialize(client_socket, database, client_handlers, mutex)
			@notify_admin = false;
			super(client_socket, database, client_handlers, mutex) {|cs, db, ch, mutex|
				
				client_id = cs.gets.chomp!

				if client_id == '' # Se for a primeira vez que o cliente se liga
					client_id = (db.execute 'select count(*) from xdks;')[0][0] # Atribui id ao cliente
					db.execute 'insert into xdks values(?,NULL,?);', client_id.to_i, CONNECTED # Adiciona cliente a base de dados
					cs.puts client_id # Envia ao cliente o id atribuido
				else	
					# Atualiza o estado do cliente na BD para CONNECTED
					db.execute "update xdks set status=#{CONNECTED} where id=#{client_id.to_i};"
				end

				ch[client_id.to_i] = self

				print "\n\n[Client \##{client_id} is now connected!]\n\n"
	
				readings = 0
				while line = cs.gets
					values = line.chomp!.split('#')
					readings += 1;

					if @notify_admin then mutex.synchronize{@admin_notifications << values.join('    ')}; @admin_notification_thread.wakeup; end

					db.execute 'insert into readings values(?,?,?,?,?);', client_id.to_i, values[1], values[2], values[3], values[4]
					db.execute "update xdks set location=? where id=?;", values[3], client_id.to_i
					#puts "ATUALIZEI XDK POSITION = #{values[3]}"
				end
				cs.close

				# Atualiza o estado do cliente na BD para DISCONNECTED
				db.execute "update xdks set status=#{DISCONNECTED} where id=#{client_id.to_i};"

				print "\n\n[Client \##{client_id} is now disconnected! (\# readings: #{readings})]\n\n"
			}
		end
	end

	class AdminHandler < Thread
		def initialize(database, client_handlers, mutex)
			super(database, client_handlers, mutex) {|db, ch, mutex|

				loop do
					Menu.display
					input = Menu.get_input
					case input[0]
					when Menu::SHOW_CONNECTED
						puts "ID\tLOCATION\t\t\tSTATUS"
						db.execute "SELECT id,location,status FROM xdks where status==#{CONNECTED}" do |row|
							status = ''+('DIS'*(1-row[2]))+'CONNECTED'
	  						puts "#{row[0]}\t#{row[1]}\t#{status}"
						end
					when Menu::SHOW_READINGS
						puts "ID   TYPE   VALUE          LOCATION                TIMESTAMP"
						db.execute "SELECT xdk_id,type,value,location,timestamp FROM readings where xdk_id==#{input[1].to_i}"  do |row|
	  						puts "#{row[0]}    #{row[1]}    #{row[2]}    #{row[3]}    #{row[4]}"
						end
					when Menu::SHOW_REAL_TIME
						readings = []
						t = Thread.new {
							puts 'ID   TYPE    VALUE          LOCATION               TIMESTAMP'
							loop { while readings.empty? do Thread.stop end; readings.each {|r| puts r}; mutex.synchronize{readings.clear}}
						}
						if ch.empty? then puts 'No clients connected'
						else
							ch[input[1].to_i].admin_notifications = readings; ch[input[1].to_i].admin_notification_thread = t
							ch[input[1].to_i].notify_admin = true; gets; t.kill; ch[input[1].to_i].notify_admin = false
						end
					end
					Menu.clear
				end	
			}
		end
	end
end