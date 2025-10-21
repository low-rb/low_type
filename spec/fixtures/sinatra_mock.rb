module Sinatra
  class Base
    class << self
      # Routing.

      def routes
        @routes ||= {}
      end

      [:get, :put, :post, :delete, :patch].each do |verb|
        define_method(verb) do |path, &block|
          key = "#{__method__} #{path}"
          routes[key] = block
        end
      end

      def simulate_request(verb, path)
        key = "#{verb} #{path}"

        result = routes[key].call
        save_response(result)
        afters[key].call
      end

      # Response object.

      def response_struct
        Struct.new(:status, :headers, :body)
      end

      def response
        @response ||= nil
      end

      def save_response(route_response)
        case route_response
        when Integer
          @response = response_struct.new(route_response, {}, nil)
        when String
          @response = response_struct.new(200, {}, route_response)
        when Array
          if route_response.count == 2
            status, body = route_response
            @response = response_struct.new(status, {}, body)
          elsif route_response.count == 3
            status, headers, body = route_response
            @response = response_struct.new(status, headers, body)
          end
        when -> (route_response) { route_response.is_a?(Enumerable) }
          binding.pry
        end
      end

      # After filter.

      def afters
        @afters ||= {}
      end

      def after(path, verb, &block)
        key = "#{verb} #{path}"
        afters[key] = block
      end
    end
  end
end
