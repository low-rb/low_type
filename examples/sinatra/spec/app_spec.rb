# frozen_string_literal: true

require_relative 'sinatra'

RSpec.describe App do
  subject(:app) { described_class }
  
  describe 'setup' do
    it 'calls get' do
      let(:pattern) { '/' }
      let(:block) { -> { 'returned string' } }

      expect { |block| App.get(pattern, &block) }.to yield_with_no_args
    end
  end
end
