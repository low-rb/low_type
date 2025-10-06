# frozen_string_literal: true

module LowType
  class << self
    def required_args(proxy_method)
      required_args = []
      required_kwargs = {}

      proxy_method.parameters.each do |param|
        optreq_key, name = param

        case optreq_key
        when :req
          required_args << nil
        when :keyreq
          required_kwargs[name] = nil
        end
      end

      [required_args, required_kwargs]
    end

    def default_args(proxy_method, args, required_args, required_kwargs)
      typed_method = eval(
        <<~RUBY
          -> (#{args.join(' ')}) {
            expressions = []

            proxy_method.parameters.each do |param|
              optreq_key, name = param
              expression = #{name}

              if expression == expression.class
                expressions << TypeExpression.new(name:, arg_type: optreq_key)
              end
            end
          }
        RUBY
      )

      # Call method with only required args to execute type expressions (which are stored as default values).
      type_expressions = typed_method.call(*required_args, **required_kwargs)
    end

    # We do as much as possible at the class load stage to avoid any possible multithreading issues on instance run.
    def prepended(base)
      file_path = caller.find { |callee| callee.end_with?("<class:LowHello>'") }.split(':').first

      File.readlines(file_path).each do |file_line|
        method_line = file_line.strip
        next unless method_line.start_with?('def ') && method_line.include?('(')

        _def, method_name, *args = method_line.split(/[( )]/)
        proxy_method = eval("-> (#{args.join(' ')}) {}")
        
        required_args, required_kwargs = LowType.required_args(proxy_method)

        LowType.default_args(proxy_method, args, required_args, required_kwargs)
      end


      send(:define_method, :initialize) do |*args, **kwargs|
        binding.pry

        # self.method(:initialize).super_method.source_location

        # method_object = self.class.method_objects[:initialize]
        proxy_method = LowType.required_args(method_line(method_object.source_location))

        super(*args, **kwargs)
      end
    end
  end
end

class Object
  # "|" is not defined on Object and this is the most compute-efficient way to achieve our goal (world peace).
  def |(default_value)
    default_value
  end
end
