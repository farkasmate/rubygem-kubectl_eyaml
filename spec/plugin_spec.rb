# frozen_string_literal: true

require 'spec_helper'

require 'yaml'

module KubectlEyaml
  describe Plugin do
    let(:plugin) { Plugin.new }
    let(:repeat) { 50 }
    let(:blob) { 'MIIBeQYJKoZIhvcNAQcDoIIBajCCAWYCAQAxggEhMIIBHQIBADAFMAACAQEwDQYJKoZIhvcNAQEBBQAEggEAJMxNwCFrtE+v66iZuA3asAyPFw5edKNOnlNILnFPWvRE+0n1JEdztBW92flb2g6ajZzKgPu+tIJF80/LG5f78xkwzG8pJD0eO1swAXp0zaNiSN9m756v/vP3lrbB2WY4DhEnIxQS5DcvIRRQ3s3lmpR7dAaZW+4aBqg7Ixf6br27G4CEXjbL9vOGgSwzRaXxv8qcEgygZAVdna/HdPy8daJIpDLQcoUdiE3lAYlKK5b1cIDmhk8V25RRDisEu2XHXLLq2DQgT1nZ2el92bZ9EDUKxgd7myer4OKn9abhOyAAjDXMKRDkXdjOH5BzRjp+A97tdAu0ZUuq5FA+RnGamTA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBBi5q6m0KnWtFp81W/htI1JgBBwo5BQpffQRgBvKzxRlL4f' } # rubocop:disable Layout/LineLength

    context '#decrypt' do
      it 'decrypts encrypted string' do
        Dir.chdir('test') do
          expect(plugin.send(:decrypt, blob)).to be == 's3cr3t'
        end
      end

      it 'decrypts fast' do
        Dir.chdir('test') do
          start_time = Time.now
          repeat.times { plugin.send(:decrypt, blob) }
          stop_time = Time.now
          expect(stop_time).to be_within(1).of(start_time), "expected to finish in one second, took #{stop_time - start_time} seconds"
        end
      end
    end

    context '#decrypt_file!' do
      it 'decrypts encrypted file' do
        Dir.chdir('test') do
          Dir.mktmpdir do |dir|
            FileUtils.cp_r('.', dir)
            Dir.chdir(dir) do
              plugin.send(:decrypt_file!, 'secret.yaml')
              cleartext = YAML.load_file('secret.yaml')
              expect(cleartext['stringData']['test-secret']).to be == 's3cr3t'
            end
          end
        end
      end
    end
  end
end
