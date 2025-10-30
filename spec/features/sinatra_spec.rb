# frozen_string_literal: true

require 'cgi'
require 'rack/test'
require_relative '../../lib/adapters/sinatra_adapter'
require_relative '../../lib/low_type'
require_relative '../../lib/basic_types'
require_relative '../fixtures/sinatra_app'

ENV['APP_ENV'] = 'test'

RSpec.describe SinatraApp do
  include Rack::Test::Methods

  subject(:app) { described_class.new }

  let(:error_message) do
    # We must be careful that we're picking up the error message from the exception itself and not from our spec's backtrace.
    interpolated_message = "Invalid return type '#{type}' for method '#{route}'. Valid types: '#{valid_types}'"
    escaped_message = CGI.escapeHTML(interpolated_message)
    "<h2>#{escaped_message}</h2>"
  end
  let(:type) { 'body' }
  let(:route) { "#{verb} #{path}" }
  let(:verb) { 'GET' }

  # Key:
  # @ = Only
  # ! = Invalid

  # Integer.

  context 'with status response' do
    it 'type checks and resturns response' do
      get '/integer'
      expect(last_response.status).to eq(201)
    end
  end

  # String.

  context 'with body response' do
    let(:valid_types) { String }

    it 'type checks and resturns response' do
      get '/string'
      expect(last_response.body).to eq('body')
    end

    context 'when invalid string type' do
      let(:path) { '/!string' }
      let(:type) { Integer }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end
  end

  # Integer, String.

  context 'with status/body response' do
    let(:path) { '/integer-string' }
    let(:valid_types) { [Integer, String] }

    it 'type checks and returns response' do
      get path
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq('body')
    end

    context 'when invalid types' do
      let(:path) { '/!integer-!string' }
      let(:type) { Array }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end

    context 'when only status' do
      let(:path) { '/@integer-string' }
      let(:type) { Integer }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end

    context 'when only body' do
      let(:path) { '/integer-@string' }
      let(:type) { String }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end
  end

  # Integer, Hash, String.

  context 'with integer/hash/string response' do
    let(:valid_types) { [Integer, Hash, String] }

    it 'type checks and returns response' do
      get '/integer-hash-string'
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq('body')
    end

    context 'when invalid body type' do
      let(:path) { '/integer-hash-!string' }
      let(:type) { Array }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end

    context 'when invalid headers type' do
      let(:path) { '/integer-!hash-string' }
      let(:type) { Array }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end

    context 'when invalid headers/body types' do
      let(:path) { '/integer-!hash-!string' }
      let(:type) { Array }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end

    context 'when only body returned' do
      let(:path) { '/integer-hash-@string' }
      let(:type) { String }

      it 'validates body from response' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end

    context 'when only status returned' do
      let(:path) { '/@integer-hash-string' }
      let(:type) { Integer }

      it 'validates body from response' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end
  end

  # Status, HTML

  context 'with status/html response' do
    let(:valid_types) { [LowType::Status, LowType::HTML] }

    it 'type checks and returns response' do
      get '/status-html'
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq('body')
    end

    context 'when invalid body type' do
      let(:path) { '/status-!html' }
      let(:type) { Array }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end
  end

  # Status, Headers, HTML.

  context 'with status/headers/html response' do
    let(:valid_types) { [LowType::Status, LowType::Headers, LowType::HTML] }

    it 'type checks and returns response' do
      get '/status-headers-html'
      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq('<em>Hello</em>')
    end

    context 'when invalid body type' do
      let(:path) { '/status-headers-!html' }
      let(:type) { Array }

      it 'raises return type error' do
        get path
        expect(last_response.body).to include(error_message)
      end
    end
  end
end
