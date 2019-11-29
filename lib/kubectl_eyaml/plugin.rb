# frozen_string_literal: true

require 'open3'
require 'tmpdir'

module KubectlEyaml
  class Plugin
    def run(cmd)
      Dir.mktmpdir do |dir|
        FileUtils.cp_r('.', dir)
        Dir[File.join(dir, '**', '*.yaml'), File.join(dir, '**', '*.yml')].each { |file| decrypt_file!(file) }

        puts shell_execute(cmd, chdir: dir)
      end
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
        raise "Shell execution `#{cmd}` failed"
      end

      output
    end
  end
end
