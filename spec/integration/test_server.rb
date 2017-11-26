# frozen_string_literal: true

require 'shellwords'
require 'English'

module TestServer
  module_function

  PORT = 15_432

  def start
    Dir.chdir(__dir__) do
      command = Shellwords.join ['bundle', 'exec', 'rackup', '--port', PORT]
      env = {
        'RACK_ENV' => 'production',
        'DOG'      => 'GOOD'
      }

      Bundler.with_clean_env do
        @pid = Process.spawn env, command
      end

      raise 'unable to start server' unless $CHILD_STATUS.success?

      wait_for_it
    end
  end

  def stop
    Process.kill('KILL', @pid)
    @pid = nil
  end

  def wait_for_it
    Timeout.timeout(10) do
      loop do
        begin
          TCPSocket.new('localhost', PORT).close
          break true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::EADDRNOTAVAIL
          sleep(0.1)
        end
      end
    end
  rescue Timeout::Error
    false
  end
end
