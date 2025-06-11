json.status "ok"
json.timestamp Time.current
json.version Securial::VERSION
json.middlewares Rails.application.middleware.map(&:inspect)
