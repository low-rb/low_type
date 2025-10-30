# frozen_string_literal: true

require 'sinatra'

class SinatraApp < Sinatra::Base
  include LowType

  set :host_authorization, { permitted_hosts: [] }

  # Key:
  # @ = Only
  # ! = Invalid

  # Integer.

  get('/integer') do -> { Integer }
    201
  end

  # String.

  get('/string') do -> { String }
    'body'
  end

  get('/!string') do -> { String }
    123
  end

  # Integer, String.

  get('/integer-string') do -> { Array[Integer, String] }
    [201, 'body']
  end

  get('/!integer-!string') do -> { Array[Integer, String] }
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
    [201, {}, 'body']
  end

  get('/integer-hash-!string') do -> { Array[Integer, Hash, String] }
    [200, {}, 123]
  end

  get('/integer-!hash-string') do -> { Array[Integer, Hash, String] }
    [200, '!headers', 'body']
  end

  get('/integer-!hash-!string') do -> { Array[Integer, Hash, String] }
    [200, '!headers', {}]
  end

  get('/integer-hash-@string') do -> { Array[Integer, Hash, String] }
    'body'
  end

  get('/@integer-hash-string') do -> { Array[Integer, Hash, String] }
    201
  end

  # Status, HTML

  get('/status-html') do -> { Array[Status, HTML] }
    [201, 'body']
  end

  get('/status-!html') do -> { Array[Status, HTML] }
    [201, 123]
  end

  # Status, Headers, HTML

  get('/status-headers-html') do -> { Array[Status, Headers, HTML] }
    [201, {}, '<em>Hello</em>']
  end

  get('/status-headers-!html') do -> { Array[Status, Headers, HTML] }
    [201, {}, 123]
  end
end
