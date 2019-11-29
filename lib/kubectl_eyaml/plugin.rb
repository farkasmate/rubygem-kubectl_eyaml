# frozen_string_literal: true

require 'kubectl_eyaml/error'
require 'open3'
require 'tmpdir'

module KubectlEyaml
  class Plugin
    def run(cmd)
      failed = false

      Dir.mktmpdir do |dir|
        FileUtils.cp_r('.', dir)
        Dir[File.join(dir, '**', '*.yaml'), File.join(dir, '**', '*.yml')].each { |file| decrypt_file!(file) }

        begin
          puts shell_execute(cmd, chdir: dir)
        rescue ShellError
          failed = true
        end
      end

      failed ? 1 : 0
    end

    private

    def decrypt_file!(file)
      cleartext = shell_execute("eyaml decrypt --file #{file}")
      File.write(file, cleartext)
    end

    def shell_execute(cmd, opts = {})
      output, success = Open3.popen2e(cmd, opts) { |_, outs, thread| [outs.reduce('', &:+), thread.value.success?] }
      unless success
        warn output
        raise ShellError, "Shell execution `#{cmd}` failed"
      end

      output
    end
  end
end
