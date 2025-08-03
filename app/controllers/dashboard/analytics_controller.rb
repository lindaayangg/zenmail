module Dashboard
  class AnalyticsController < ApplicationController
    before_action :require_login
    layout "with_navbar"

    def index; end
  end
end
