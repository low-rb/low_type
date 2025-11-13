# frozen_string_literal: true

require_relative '../lib/proxies/param_proxy'
require_relative '../lib/types/error_types'
require_relative '../lib/type_expression'

RSpec.describe LowType::TypeExpression do
  subject(:type_expression) { described_class.new(default_value: nil) }

  # TODO: Use FactoryBot.
  let(:proxy) { LowType::ParamProxy.new(type_expression:, name: 'greetings', type: :req, file:) }
  let(:file) { LowType::FileProxy.new(path: '/Users/name/dev/app/lib/my_class', line: 123, scope: 'MyClass#my_method') }

  describe '#initialize' do
    it 'instantiates a class' do
      expect { type_expression }.not_to raise_error
    end
  end

  describe '#backtrace_with_proxy' do
    let(:hidden_paths) do
      [
        '/Users/name/dev/app/vendor/bundle/ruby/3.4.0/gems/low_type/lib/redefiner.rb',
        '/Users/name/dev/app/vendor/bundle/ruby/3.4.0/gems/low_type/lib/type_expression.rb'
      ]
    end
    let(:backtrace) do
      [
        "    from /Users/name/dev/app/vendor/bundle/ruby/3.4.0/gems/low_type/lib/redefiner.rb:29:in 'block (4 levels) in redefine'",
        "    from /Users/name/dev/app/vendor/bundle/ruby/3.4.0/gems/low_type/lib/redefiner.rb:24:in 'Array#each'",
        "    from /Users/name/dev/app/vendor/bundle/ruby/3.4.0/gems/low_type/lib/redefiner.rb:24:in 'block (3 levels) in redefine'",
        "    from /Users/name/dev/app/lib/models/time_tree/trunk_cone.rb:45:in 'TrunkCone#grow'",
        "    from /Users/name/dev/app/vendor/bundle/ruby/3.4.0/gems/low_type/lib/redefiner.rb:42:in 'block (3 levels) in redefine'",
        "    from /Users/name/dev/app/lib/models/time_tree/time_tree.rb:38:in 'TimeTree#grow'",
        "    from /Users/name/dev/app/lib/models/time_tree/time_tree.rb:50:in 'TimeTree#grow'",
        "    from /Users/name/dev/app/lib/layers/space_grid.rb:34:in 'block in SpaceGrid#plant'",
        "    from /Users/name/dev/app/queries/low_spec.rb:21:in 'block in LowSpec.measure'",
        "    from /Users/name/dev/app/vendor/bundle/ruby/3.4.0/gems/benchmark-0.4.1/lib/benchmark.rb:305:in 'Benchmark.measure'",
        "    from /Users/name/dev/app/queries/low_spec.rb:20:in 'LowSpec.measure'",
        "    from /Users/name/dev/app/lib/layers/space_grid.rb:32:in 'SpaceGrid#plant'",
        "    from /Users/name/dev/app/lib/layers/space_grid.rb:17:in 'SpaceGrid#run'",
        "    from /Users/name/dev/app/lib/game.rb:41:in 'Game#run'",
        "    from sudoku.rb:27:in 'block in Sudoku.run'",
        "    from sudoku.rb:24:in 'Array#each'",
        "    from sudoku.rb:24:in 'Sudoku.run'",
        "    from sudoku.rb:98:in '<main>'"
      ]
    end

    it 'returns filtered backtrace with proxy' do
      stub_const('LowType::HIDDEN_PATHS', hidden_paths)
      expect(type_expression.send(:backtrace_with_proxy, backtrace:, proxy:)).to eq(
        [
          "    from /Users/name/dev/app/lib/my_class:123:in 'MyClass#my_method'",
          "    from /Users/name/dev/app/lib/models/time_tree/trunk_cone.rb:45:in 'TrunkCone#grow'",
          "    from /Users/name/dev/app/lib/models/time_tree/time_tree.rb:38:in 'TimeTree#grow'",
          "    from /Users/name/dev/app/lib/models/time_tree/time_tree.rb:50:in 'TimeTree#grow'",
          "    from /Users/name/dev/app/lib/layers/space_grid.rb:34:in 'block in SpaceGrid#plant'",
          "    from /Users/name/dev/app/queries/low_spec.rb:21:in 'block in LowSpec.measure'",
          "    from /Users/name/dev/app/vendor/bundle/ruby/3.4.0/gems/benchmark-0.4.1/lib/benchmark.rb:305:in 'Benchmark.measure'",
          "    from /Users/name/dev/app/queries/low_spec.rb:20:in 'LowSpec.measure'",
          "    from /Users/name/dev/app/lib/layers/space_grid.rb:32:in 'SpaceGrid#plant'",
          "    from /Users/name/dev/app/lib/layers/space_grid.rb:17:in 'SpaceGrid#run'",
          "    from /Users/name/dev/app/lib/game.rb:41:in 'Game#run'",
          "    from sudoku.rb:27:in 'block in Sudoku.run'",
          "    from sudoku.rb:24:in 'Array#each'",
          "    from sudoku.rb:24:in 'Sudoku.run'",
          "    from sudoku.rb:98:in '<main>'"
        ]
      )
    end
  end
end
