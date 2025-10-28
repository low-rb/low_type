require 'sinatra'

class SinatraApp < Sinatra::Base
  include LowType

  set :host_authorization, { permitted_hosts: [] }

  # Status.

  get('/status') do -> { Integer }
    200
  end

  # Body.

  get('/body') do -> { String }
    'body'
  end

  get('/body-invalid') do -> { String }
    123
  end

  get('/body-invalid-html') do -> { HTML }
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

  get('/only-status-body') do -> { Array[Integer, String] }
    200
  end

  get('/status-only-body') do -> { Array[Integer, String] }
    'body'
  end

  # Status, Hash, Body.

  get('/status-hash-body') do -> { Array[Integer, Hash, String] }
    [200, {}, 'body']
  end

  get('/status-hash-invalid-body') do -> { Array[Integer, Hash, String] }
    [200, {}, 123]
  end

  get('/status-invalid-hash-body') do -> { Array[Integer, Hash, String] }
    [200, 'invalid hash', 'body']
  end

  get('/status-hash-only-body') do -> { Array[Integer, Hash, String] }
    'body'
  end

  get('/only-status-hash-body') do -> { Array[Integer, Hash, String] }
    201
  end

  get('/status-headers-html') do -> { Array[Status, Headers, HTML] }
    [200, {}, '<strong>Hello!</strong>']
  end
end
