# frozen_string_literal: true

require 'rack/test'
require_relative '../../lib/low_type.rb'
require_relative '../fixtures/sinatra_app.rb'

ENV['APP_ENV'] = 'test'

RSpec.describe SinatraApp do
  include Rack::Test::Methods

  subject(:app) { described_class.new }

  # Key:
  # @ = Only
  # ! = Invalid

  # Integer.

  context 'with status response' do
    it 'type checks response' do
      get '/integer'
    end
  end

  # String.

  context 'with body response' do
    it 'type checks response' do
      get '/string'
    end

    context 'when invalid string type' do
      it 'raises invalid return type error' do
        get '/string-invalid'
        expect(last_response.status).to eq(500)
        expect(last_response.body).to eq("Invalid return value 'nil' for method 'GET /string-invalid'. Valid types: 'String'")
      end
    end

    context 'when from array' do
      it 'validates body from response' do
        get '/string-in-array'
        expect(last_response.body).to eq('body')
      end
    end
  end

  # Integer, String.

  context 'with status/body response' do
    it 'type checks response' do
      get '/integer-string'
    end

    context 'when invalid type' do
      it 'raises invalid return type error' do
        get '/integer-string-invalid'
        expect(last_response.status).to eq(500)
      end
    end

    context 'when only status' do
      it 'responds with invalid value because body is empty' do
        get '/@integer-string'
        expect(last_response.status).to eq(500)
        expect(last_response.body.force_encoding('utf-8')).to eq(
          "Invalid return value '[200, nil]' for method 'GET /@integer-string'. Valid types: '[Integer, String]'"
        )
      end
    end

    context 'when only body' do
      it 'validates body from response' do
        get '/integer-@string'
        expect(last_response.body).to eq('body')
      end
    end
  end

  # Integer, Hash, String.

  context 'with integer/hash/string response' do
    it 'type checks response' do
      get '/integer-hash-string'
    end

    context 'when invalid body type' do
      it 'raises invalid return type error' do
        get '/integer-hash-!string'
        expect(last_response.status).to eq(500)
      end
    end

    context 'when invalid headers type' do
      it 'raises invalid return type error' do
        get '/integer-!hash-string'
        expect(last_response.status).to eq(500)
      end
    end

    context 'when invalid headers and body types' do
      it 'raises invalid return type error' do
        get '/integer-!hash-!string'
        expect(last_response.status).to eq(500)
        expect(last_response.body.force_encoding('utf-8')).to eq(
          "Invalid return value '[500, {}, nil]' for method 'GET /integer-!hash-!string'. Valid types: '[Integer, Hash, String]'"
        )
      end
    end

    context 'when only body returned' do
      it 'validates body from response' do
        get '/integer-hash-@string'
        expect(last_response.body).to eq('body')
      end
    end

    context 'when only status returned' do
      it 'responds with invalid value because body is empty' do
        get '/@integer-hash-string'
        expect(last_response.status).to eq(500)
        expect(last_response.body.force_encoding('utf-8')).to eq(
          "Invalid return value '[201, {}, nil]' for method 'GET /@integer-hash-string'. Valid types: '[Integer, Hash, String]'"
        )
      end
    end
  end

  # Status, HTML

  context 'when invalid HTML type' do
    it 'raises invalid return type error' do
      get '/string-!html'
      expect(last_response.status).to eq(500)
      expect(last_response.body).to eq("Invalid return value 'nil' for method 'GET /string-!html'. Valid types: 'LowType::HTML'")
    end
  end

  # Status, Headers, HTML.

  context 'with status/headers/html response' do
    it 'type checks response' do
      get '/status-headers-html'
    end

    context 'when invalid html type' do
      it 'raises invalid return type error' do
        get '/status-headers-!html'
        expect(last_response.status).to eq(500)
      end
    end
  end
end
