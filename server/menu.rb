module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end
end


class Menu

    SHOW_CONNECTED = '1'
    SHOW_READINGS = '2'
    SHOW_REAL_TIME = '3'

	MENU = "\n\nChoose an option (1..3)\n\n1: Show connected XDKs\n2: Show readings\n3: Show readings in real time\n\n";
	
	def self.display
		print MENU
	end

	def self.clear
		puts "\n(Any key) to continue"
		gets
		OS.windows? ? system('cls') : system('clear')
	end

	def self.get_input
		user_input = []
		input = gets.chomp!

		user_input << input

		if input == SHOW_READINGS || input == SHOW_REAL_TIME
			print 'XDK id: '
			input = gets.chomp!
			user_input << input
		end

		return user_input
	end
end