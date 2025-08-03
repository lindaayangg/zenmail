host = Rails.application.credentials.dig(:app, :host) || "localhost:3000"
Rails.application.routes.default_url_options[:host] = host
