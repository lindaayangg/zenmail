class PwaController < ApplicationController
  def manifest
    render template: "pwa/manifest", content_type: "application/json"
  end
end
