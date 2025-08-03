class ApplicationController < ActionController::Base
  include Clearance::Controller
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  def sitemap
    respond_to do |format|
      format.xml do
        response.headers["Content-Encoding"] = "gzip"
        render file: Rails.root.join("public", "sitemap.xml.gz"), content_type: "application/xml"
      end
    end
  end
end
