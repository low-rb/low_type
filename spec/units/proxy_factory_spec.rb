# frozen_string_literal: true

require 'prism'
require_relative '../../lib/factories/proxy_factory'
require_relative '../../lib/proxies/file_proxy'
require_relative '../../lib/queries/file_parser'

RSpec.describe LowType::ProxyFactory do
  describe '.return_proxy' do
    let(:file) do
      LowType::FileProxy.new(
        path: '/path/to/test_class.rb',
        start_line: 10,
        end_line: 20,
        scope: 'TestClass#test_method'
      )
    end

    context 'with a valid return type' do
      let(:method_code) do
        <<~RUBY
          def test_method() -> { String }
            "hello"
          end
        RUBY
      end

      it 'creates a return proxy successfully' do
        parsed = Prism.parse(method_code)
        method_node = parsed.value.statements.body.first

        expect { described_class.return_proxy(method_node:, file:) }.not_to raise_error
      end

      it 'returns a ReturnProxy instance' do
        parsed = Prism.parse(method_code)
        method_node = parsed.value.statements.body.first

        result = described_class.return_proxy(method_node:, file:)

        expect(result).to be_a(LowType::ReturnProxy)
      end
    end

    context 'with an unknown return type' do
      let(:method_code) do
        <<~RUBY
          def test_method() -> { UnknownType }
            "hello"
          end
        RUBY
      end

      it 'raises NameError with improved error message' do
        parsed = Prism.parse(method_code)
        method_node = parsed.value.statements.body.first

        expect { described_class.return_proxy(method_node:, file:) }
          .to raise_error(NameError, "Unknown return type '-> { UnknownType }' for TestClass#test_method at /path/to/test_class.rb:10")
      end
    end

    context 'with no return type' do
      let(:method_code) do
        <<~RUBY
          def test_method
            "hello"
          end
        RUBY
      end

      it 'returns nil' do
        parsed = Prism.parse(method_code)
        method_node = parsed.value.statements.body.first

        result = described_class.return_proxy(method_node:, file:)

        expect(result).to be_nil
      end
    end
  end

  describe '.file_proxy' do
    let(:node) do
      double('node', start_line: 5, end_line: 15)
    end

    it 'creates a file proxy with correct attributes' do
      result = described_class.file_proxy(
        node:,
        path: '/path/to/file.rb',
        scope: 'MyClass#my_method'
      )

      expect(result).to be_a(LowType::FileProxy)
      expect(result.path).to eq('/path/to/file.rb')
      expect(result.start_line).to eq(5)
      expect(result.end_line).to eq(15)
      expect(result.scope).to eq('MyClass#my_method')
    end
  end
end
