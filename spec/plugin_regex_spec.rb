# frozen_string_literal: true

require 'spec_helper'

module KubectlEyaml
  describe 'Plugin::PKCS7_REGEX' do
    let(:regex) { Plugin::PKCS7_REGEX }

    context '#match' do
      it 'matches "ENC[PKCS7,test]"' do
        expect(regex.match('ENC[PKCS7,test]')[:blob]).to be == 'test'
      end

      it 'matches "password: ENC[PKCS7,test]"' do
        expect(regex.match('password: ENC[PKCS7,test]')[:blob]).to be == 'test'
      end

      it 'matches "password: ENC[PKCS7,test] # comment"' do
        expect(regex.match('password: ENC[PKCS7,test] # comment')[:blob]).to be == 'test'
      end

      it 'matches "password: ENC[PKCS7,test] # [tricky comment]"' do
        expect(regex.match('password: ENC[PKCS7,test] # [tricky comment]')[:blob]).to be == 'test'
      end

      it 'matches "    indented_password: ENC[PKCS7,test]"' do
        expect(regex.match('    indented_password: ENC[PKCS7,test]')[:blob]).to be == 'test'
      end
    end
  end
end
