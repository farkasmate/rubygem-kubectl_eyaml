# frozen_string_literal: true

require 'open3'

module KubectlEyaml
  class Plugin
    def self.run
      cmd = "kubectl #{ARGV.join(' ')}"
      puts cmd

      output, exit_code = Open3.popen2e(cmd) { |_stdin, stdout_and_stderr, wait_thread| [stdout_and_stderr.reduce('', &:+), wait_thread.value.exitstatus] }

      puts output
      exit exit_code
    end
  end
end
