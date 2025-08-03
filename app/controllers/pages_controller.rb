# frozen_string_literal: true

class PagesController < ApplicationController
  def blog_post
    slug = params[:slug]
    template_path = "pages/blog/#{slug}"
    if template_exists?(template_path)
      render template: template_path
    else
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end
end
