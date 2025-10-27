require 'prism'

require_relative 'sinatra_return_proxy'
require_relative '../interfaces/adapter_interface'
require_relative '../proxies/file_proxy'
require_relative '../error_types'

module LowType
  class Status < Integer; end
  class Headers < Hash; end

  # We don't use https://sinatrarb.com/extensions.html because we need to type check all Ruby methods (not just Sinatra) at a lower level.
  class SinatraAdapter < AdapterInterface
    def initialize(klass:, parser:, file_path:)
      @klass = klass
      @parser = parser
      @file_path = file_path
    end

    def redefine_methods
      method_calls = @parser.method_calls(method_names: [:get, :post, :patch, :put, :delete, :options, :query])

      # Type check return values.
      method_calls.each do |method_call|
        arguments_node = method_call.compact_child_nodes.first
        next unless arguments_node.is_a?(Prism::ArgumentsNode)

        pattern = arguments_node.arguments.first.content

        line = method_call.respond_to?(:start_line) ? method_call.start_line : nil
        file = FileProxy.new(path: @file_path, line:, scope: "#{@klass}##{method_call.name}")
        params = [ParamProxy.new(type_expression: nil, name: :route, type: :req, position: 0, file:)]
        return_proxy = return_proxy(method_node: method_call, pattern:, file:)
        next unless return_proxy

        route = "#{method_call.name.upcase} #{pattern}"
        @klass.low_methods[route] = MethodProxy.new(name: method_call.name, params:, return_proxy:)

        # We're in Sinatra now. Objects request/response are from Sinatra.
        @klass.after pattern do
          if (method_proxy = self.class.low_methods["#{request.request_method} #{pattern}"])
            proxy = method_proxy.return_proxy

            # Inclusive rather than exclusive validation. If one type/value is valid then there's no need to error.
            valid_type = proxy.type_expression.types.any? do |type|
              proxy.type_expression.validate(value: SinatraAdapter.reconstruct_return_value(type:, response:), proxy:)
            end

            # No valid types so let's return a server error to the client.
            unless valid_type
              proxy.type_expression.types.each do |type|
                value = SinatraAdapter.reconstruct_return_value(type:, response:)
                unless proxy.type_expression.validate(value:, proxy:)
                  status(500)
                  body(proxy.error_message(value: value.inspect))
                  break
                end
              end
            end
          end
        end
      end
    end

    # The route's String/Array/Enumerable return value populates a Rack::Response object.
    # This response also contains values added via Sinatra DSL's header()/body() methods.
    # So reconstruct the return value from the response object, based on the return type.
    def self.reconstruct_return_value(type:, response:)
      valid_types = {
        Integer => -> (response) { response.status },
        String => -> (response) { response.body.first },
        HTML => -> (response) { response.body.first },
        JSON => -> (response) { response.body.first },

        # TODO: Should these be Enumerable[T] instead? How would we match a Module of a class in a hash key?
        # NOTE: These keys represent types, not type expressions.
        #       A type lives inside a type expression and is actually an instance representing that type.
        [String] => -> (response) { response.body },
        [Integer, String] => -> (response) { [response.status, *response.body] },
        [Integer, Hash, String] => -> (response) { [response.status, response.headers, *response.body] },
      }

      raise AllowedTypeError, 'Did you mean "Response.finish"?' if type.to_s == 'Response'

      if (reconstructed_value = valid_types[type])
        return reconstructed_value.call(response)
      else
        raise AllowedTypeError, "Valid Sinatra return types: #{valid_types.keys.map(&:to_s).join(' | ')}"
      end
    end

    private

    def return_proxy(method_node:, pattern:, file:)
      return_type = Parser.return_type(method_node:)
      return nil if return_type.nil?

      expression = eval(return_type.slice).call
      expression = TypeExpression.new(type: expression) unless TypeExpression === expression

      SinatraReturnProxy.new(type_expression: expression, name: "#{method_node.name.upcase} #{pattern}", file:)
    end
  end
end
