module Securial
  module Logger
    COLORS = {
      "DEBUG" => "\e[36m",   # cyan
      "INFO" => "\e[32m",    # green
      "WARN" => "\e[33m",    # yellow
      "ERROR" => "\e[31m",   # red
      "FATAL" => "\e[35m",   # magenta
      "UNKNOWN" => "\e[37m", # white
    }.freeze
    CLEAR = "\e[0m"
    SEVERITY_WIDTH = 5
  end
end
