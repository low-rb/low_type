# frozen_string_literal: true

require 'rack/test'
require_relative '../../lib/low_type.rb'
require_relative '../fixtures/sinatra_app.rb'

ENV['APP_ENV'] = 'test'

RSpec.describe SinatraApp do
  include Rack::Test::Methods

  subject(:app) { described_class.new }

  # Status.

  context 'with status response' do
    it 'type checks response' do
      get '/status'
    end
  end

  # Body.

  context 'with body response' do
    it 'type checks response' do
      get '/body'
    end

    context 'when invalid string type' do
      it 'raises invalid return type error' do
        get '/body-invalid'
        expect(last_response.status).to eq(500)
        expect(last_response.body).to eq("Invalid return value 'nil' for method 'GET /body-invalid'. Valid types: 'String'")
      end
    end

    context 'when invalid HTML type' do
      it 'raises invalid return type error' do
        get '/body-invalid-html'
        expect(last_response.status).to eq(500)
        expect(last_response.body).to eq("Invalid return value 'nil' for method 'GET /body-invalid-html'. Valid types: 'LowType::HTML'")
      end
    end

    context 'when from array' do
      it 'validates body from response' do
        get '/body-in-array'
        expect(last_response.body).to eq('body')
      end
    end
  end

  # Status, Body.

  context 'with status/body response' do
    it 'type checks response' do
      get '/status-body'
    end

    context 'when invalid type' do
      it 'raises invalid return type error' do
        get '/status-body-invalid'
        expect(last_response.status).to eq(500)
      end
    end

    context 'when only status' do
      it 'responds with invalid value because body is empty' do
        get '/only-status-body'
        expect(last_response.status).to eq(500)
        expect(last_response.body.force_encoding('utf-8')).to eq(
          "Invalid return value '[200]' for method 'GET /only-status-body'. Valid types: '[Integer, String]'"
        )
      end
    end

    context 'when only body' do
      it 'validates body from response' do
        get '/status-only-body'
        expect(last_response.body).to eq('body')
      end
    end
  end

  # Status, Hash, Body.

  context 'with status/hash/body response' do
    it 'type checks response' do
      get '/status-hash-body'
    end

    context 'when invalid body type' do
      it 'raises invalid return type error' do
        get '/status-hash-invalid-body'
        expect(last_response.status).to eq(500)
      end
    end

    context 'when invalid hash type' do
      it 'raises invalid return type error' do
        get '/status-invalid-hash-body'
        expect(last_response.status).to eq(500)
      end
    end

    context 'when only body returned' do
      it 'validates body from response' do
        get '/status-hash-only-body'
        expect(last_response.body).to eq('body')
      end
    end

    context 'when only status returned' do
      it 'responds with invalid value because body is empty' do
        get '/only-status-hash-body'
        expect(last_response.status).to eq(500)
        expect(last_response.body.force_encoding('utf-8')).to eq(
          "Invalid return value '[201, {}]' for method 'GET /only-status-hash-body'. Valid types: '[Integer, Hash, String]'"
        )
      end
    end
  end
end
