require 'sinatra'

class SinatraApp < Sinatra::Base
  include LowType

  set :host_authorization, { permitted_hosts: [] }

  # Key:
  # @ = Only
  # ! = Invalid

  # Integer.

  get('/integer') do -> { Integer }
    200
  end

  # String.

  get('/string') do -> { String }
    'body'
  end

  get('/string-invalid') do -> { String }
    123
  end

  get('/string-in-array') do -> { String }
    [200, {}, 'body'] # Passes because Sinatra type checking is inclusive rather than exclusive.
  end

  # Integer, String.

  get('/integer-string') do -> { Array[Integer, String] }
    [200, 'body']
  end

  get('/integer-string-invalid') do -> { Array[Integer, String] }
    ['200', 123]
  end

  get('/@integer-string') do -> { Array[Integer, String] }
    200
  end

  get('/integer-@string') do -> { Array[Integer, String] }
    'body'
  end

  # Integer, Hash, String.

  get('/integer-hash-string') do -> { Array[Integer, Hash, String] }
    [200, {}, 'body']
  end

  get('/integer-hash-!string') do -> { Array[Integer, Hash, String] }
    [200, {}, 123]
  end

  get('/integer-!hash-string') do -> { Array[Integer, Hash, String] }
    [200, 'invalid hash', 'body']
  end

  get('/integer-!hash-!string') do -> { Array[Integer, Hash, String] }
    [200, 'invalid hash', {}]
  end

  get('/integer-hash-@string') do -> { Array[Integer, Hash, String] }
    'body'
  end

  get('/@integer-hash-string') do -> { Array[Integer, Hash, String] }
    201
  end

  # Status, HTML

  get('/string-!html') do -> { HTML }
    123
  end

  # Status, Headers, HTML

  get('/status-headers-html') do -> { Array[Status, Headers, HTML] }
    [200, {}, '<strong>Hello!</strong>']
  end

  get('/status-headers-!html') do -> { Array[Status, Headers, HTML] }
    [200, {}, 123]
  end
end
