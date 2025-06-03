module Securial
  module Logger
    module Formatter
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

      class ColorfulFormatter
        def call(severity, timestamp, progname, msg)
          color = COLORS[severity] || CLEAR
          padded_severity = severity.ljust(SEVERITY_WIDTH)
          formatted = "[#{progname}][#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}] #{padded_severity} -- #{msg}\n"

          "#{color}#{formatted}#{CLEAR}"
        end
      end

      class PlainFormatter
        def call(severity, timestamp, progname, msg)
          padded_severity = severity.ljust(SEVERITY_WIDTH)
          formatted = "[#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}] #{padded_severity} -- #{msg}\n"

          formatted
        end
      end
    end
  end
end
