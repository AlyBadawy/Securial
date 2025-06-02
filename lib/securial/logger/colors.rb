module Securial
  module Logger
    module Colors
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

      class Formatter
        def call(severity, timestamp, progname, msg)
          color = COLORS[severity] || RESET
          padded_severity = severity.ljust(SEVERITY_WIDTH)
          formatted = "[#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}] #{padded_severity} -- : #{msg}\n"

          "#{color}#{formatted}#{CLEAR}"
        end
      end
    end
  end
end
