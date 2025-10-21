require_relative 'sinatra_mock.rb'

class SinatraApp < Sinatra::Base
  include LowType

  # Status.

  get('/status') do -> { Integer }
    200
  end

  get('/status-invalid') do -> { String }
    200
  end

  # Body.

  get('/body') do -> { String }
    'body'
  end

  get('/body-invalid') do -> { String }
    123
  end

  get('/body-in-array') do -> { String }
    [200, {}, 'body'] # Passes because Sinatra type checking is inclusive rather than exclusive.
  end

  # Status, Body.

  get('/status-body') do -> { Array[Integer, String] }
    [200, 'body']
  end

  get('/status-body-invalid') do -> { Array[Integer, String] }
    ['200', 123]
  end

  get('/status-body-single-value') do -> { Array[Integer, String] }
    'body'
  end

  # Status, Hash, Body.

  get('/status-hash-body') do -> { Array[Integer, Hash, String] }
    [200, {}, 'body']
  end

  get('/status-hash-body-invalid') do -> { Array[Integer, Hash, String] }
    ['200', {}, 123]
  end

  get('/status-hash-body-single-value') do -> { Array[Integer, Hash, String] }
    'body'
  end
end
