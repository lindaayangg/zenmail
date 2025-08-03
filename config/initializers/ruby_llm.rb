require "ruby_llm"

gemini_api_key = Rails.application.credentials.dig(:gemini, :api_key)

if gemini_api_key.present?
  begin
    RubyLLM.configure do |config|
      config.gemini_api_key = gemini_api_key

      # Set default model for Gemini
      config.default_model = "gemini-1.5-flash"

      # Connection settings
      config.request_timeout = 120
      config.max_retries = 3
      config.retry_interval = 0.1
      config.retry_backoff_factor = 2
      config.retry_interval_randomness = 0.5

      # Logging
      config.logger = Rails.logger
      config.log_level = :info
    end

    Rails.logger.info "RubyLLM client initialized successfully for Google Gemini"
  rescue => e
    Rails.logger.warn "Failed to initialize RubyLLM client: #{e.message}"
  end
else
  Rails.logger.warn "Gemini API key not configured."
end
