require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.format                      = :json
  config.curl_host                   = 'http://localhost'
  # config.request_body_formatter      = :json
  config.curl_headers_to_filter      = ['Host', 'Cookie']
  config.request_headers_to_include  = ['Content-Type', 'Accept', 'Authorization']
  config.response_headers_to_include = ['Content-Type']
end
