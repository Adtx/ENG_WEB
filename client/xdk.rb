class XDK

	TEMPERATURE_RANGE = -20..80
	NOISE_RANGE = 10..80
	DEGREES_RANGE = 0..90
	TIME_RANGE = 0..59

    TEMPERATURE = 0
    NOISE = 1

    def change_position()
    	rand = rand(2);
		dir1 = 'N'*rand + 'S'*(1-rand);
		rand = rand(2);
		dir2 = 'W'*rand + 'E'*(1-rand);
		new_position = "#{rand(DEGREES_RANGE)}º #{rand(TIME_RANGE).to_i}' #{rand(TIME_RANGE).to_i}'' #{dir1} |"
		new_position += " #{rand(DEGREES_RANGE)}º #{rand(TIME_RANGE).to_i}' #{rand(TIME_RANGE).to_i}'' #{dir2}"
		@position = new_position
    end

	def initialize(socket, id)
		@socket = socket
		@id = id
		@position = change_position()
		@temperature_thread = nil
		@noise_thread = nil
		@position_thread = Thread.new {
			loop {
				change_position()
				sleep(3)
			}
		}
	end

	def start_sensor(sensor_type, sleep_time)
		case sensor_type
		when TEMPERATURE
			start('TEMP ', TEMPERATURE_RANGE, sleep_time)
		when NOISE
			start('NOISE', NOISE_RANGE, sleep_time)
		end
	end

	def stop_sensor(sensor_type)
			sensor_type == NOISE ? @noise_thread.kill : @temperature_thread.kill
	end
		
	private
	def start(type, values_range, sleep_time)
		thread = Thread.new {
			loop {
				value = rand(values_range).to_s
				timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
				@socket.puts(@id + '#' + type + '#' + value + '#' + @position + '#' + timestamp)
				sleep(sleep_time)
			}
		}
		type == NOISE ? @noise_thread = thread : @temperature_thread = thread
	end
end