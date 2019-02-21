# frozen_string_literal: true

require 'tty/which'

module StartupTime
  # StartupTime::Util - app-wide helper methods
  module Util
    # a wrapper around +TTY::Which.which+ which allows commands to be passed as
    # symbols as well as strings e.g.:
    #
    #   which("ruby") #=> "/usr/bin/ruby"
    #   which(:ruby)  #=> "/usr/bin/ruby"
    def which(command)
      TTY::Which.which(command.to_s)
    end
  end
end
