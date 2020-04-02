# frozen_string_literal: true

require 'base64'
require 'kubectl_eyaml/error'
require 'open3'
require 'tmpdir'

module KubectlEyaml
  class Plugin
    PKCS7_REGEX = %r{^(?<head>.*)(?<crypt>ENC\[PKCS7,(?<blob>[\w+/]*)\])(?<tail>.*)$}.freeze

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

    def decrypt(blob)
      bin = Base64.decode64 blob
      shell_execute('openssl smime -decrypt -inform der -inkey keys/private_key.pkcs7.pem', stdin_data: bin, binmode: true)
    end

    def decrypt_file!(file)
      clear_lines = File.readlines(file).map do |line|
        match = PKCS7_REGEX.match(line)
        next line unless match

        "#{match[:head]}#{decrypt(match[:blob])}#{match[:tail]}"
      end

      File.write(file, clear_lines.join)
    end

    def shell_execute(cmd, opts = {})
      output, status = Open3.capture2e(cmd, opts)
      unless status.success?
        warn output
        raise ShellError, "Shell execution `#{cmd}` failed"
      end

      output
    end
  end
end
