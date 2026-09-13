# frozen_string_literal: true

require_relative '../../lib/types/error_types'
require_relative '../fixtures/private_method'

RSpec.describe PrivateMethod do
  subject(:private_method) { described_class.new }

  describe '#private_typed_arg' do
    let(:error_message) { "private method 'private_typed_arg' called for an instance of PrivateMethod" }

    it 'raises no method error' do
      expect { private_method.private_typed_arg }.to raise_error(NoMethodError, error_message)
    end
  end
end
