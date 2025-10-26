require_relative 'sinatra_adapter'

module LowType
  class AdapterLoader
    class << self
      def load(klass:, parser:, file_path:)
        adaptor = nil

        ancestors = klass.ancestors.map(&:to_s)
        adaptor = SinatraAdapter.new(klass:, parser:, file_path:) if ancestors.include?('Sinatra::Base')

        return if adaptor.nil?

        adaptor
      end
    end
  end
end
