# frozen_string_literal: true

require 'spec_helper'

require 'yaml'

module KubectlEyaml
  describe Plugin do
    let(:plugin) { Plugin.new }
    let(:repeat) { 10 }

    it 'decrypts encrypted file' do
      Dir.chdir('test') do
        plugin.send(:decrypt_file!, 'secret.yaml')
        cleartext = YAML.load_file('secret.yaml')
        expect(cleartext['stringData']['test-secret']).to be == 's3cr3t'
      end
    end

    it 'decrypts fast' do
      Dir.chdir('test') do
        Dir.mktmpdir do |dir|
          FileUtils.cp_r('.', dir)
          repeat.times { |i| FileUtils.cp('secret.yaml', "secret_#{i}.yaml") }

          start_time = Time.now
          repeat.times { |i| plugin.send(:decrypt_file!, "secret_#{i}.yaml") }
          stop_time = Time.now
          expect(stop_time).to be_within(1).of(start_time), "expected to finish in one second, took #{stop_time - start_time} seconds"
        end
      end
    end
  end
end
