class XDK

	TEMPERATURE_RANGE = -20..80
	NOISE_RANGE = 10..80

    TEMPERATURE = 0
    NOISE = 1

	def initialize(socket)
		@socket = socket
		@temperature_thread = nil
		@noise_thread = nil
	end

	def start_sensor(sensor_type, sleep_time)
		case sensor_type
		when TEMPERATURE
			start(TEMPERATURE, TEMPERATURE_RANGE, sleep_time)
		when NOISE
			start(NOISE, NOISE_RANGE, sleep_time)
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
				@socket.puts(type.to_s + ': ' + value + '  (' + timestamp + ' | ' + POSITION + ')')
				sleep(sleep_time)
			}
		}
		type == NOISE ? @noise_thread = thread : @temperature_thread = thread
	end
end