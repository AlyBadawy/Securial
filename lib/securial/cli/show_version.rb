# rubocop:disable Rails/Output
def show_version
  begin
    require "securial/version"
    puts "Securial v#{Securial::VERSION}" 
  rescue LoadError
    puts "Securial version information not available."
  end
end
