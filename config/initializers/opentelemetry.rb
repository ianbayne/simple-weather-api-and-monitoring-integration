# REF: https://opentelemetry.io/docs/languages/ruby/getting-started/

require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'tablecheck-customer-reliability-take-home'
  c.use_all() # enables all instrumentation!
end