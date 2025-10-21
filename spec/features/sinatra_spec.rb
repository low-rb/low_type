# frozen_string_literal: true

require_relative '../../lib/low_type.rb'
require_relative '../fixtures/sinatra_app.rb'

RSpec.describe SinatraApp do
  subject(:app) { described_class }

  # Status.

  context 'with status response' do
    it 'type checks response' do
      app.simulate_request(:get, '/status')
    end

    context 'when invalid type' do
      it 'raises invalid return type error' do
        expect { app.simulate_request(:get, '/status-invalid') }.to raise_error(LowType::ReturnTypeError)
      end
    end
  end

  # Body.

  context 'with body response' do
    it 'type checks response' do
      app.simulate_request(:get, '/body')
    end

    context 'when invalid type' do
      it 'raises invalid return type error' do
        expect { app.simulate_request(:get, '/body-invalid') }.to raise_error(LowType::ReturnTypeError)
      end
    end

    context 'when from array' do
      it 'validates body from response' do
        app.simulate_request(:get, '/body-in-array')
        expect(app.response.body).to eq('body')
      end
    end
  end

  # Status, Body.

  context 'with status/body response' do
    it 'type checks response' do
      app.simulate_request(:get, '/status-body')
    end

    context 'when invalid type' do
      it 'raises invalid return type error' do
        expect { app.simulate_request(:get, '/status-body-invalid') }.to raise_error(LowType::ReturnTypeError)
      end
    end

    context 'when body from single value' do
      it 'validates body from response' do
        app.simulate_request(:get, '/status-body-single-value')
        expect(app.response.body).to eq('body')
      end
    end
  end

  # Status, Hash, Body.

  context 'with status/hash/body response' do
    it 'type checks response' do
      app.simulate_request(:get, '/status-hash-body')
    end

    context 'when invalid type' do
      it 'raises invalid return type error' do
        expect { app.simulate_request(:get, '/status-hash-body-invalid') }.to raise_error(LowType::ReturnTypeError)
      end
    end

    context 'when body from single value' do
      it 'validates body from response' do
        app.simulate_request(:get, '/status-hash-body-single-value')
        expect(app.response.body).to eq('body')
      end
    end
  end
end
