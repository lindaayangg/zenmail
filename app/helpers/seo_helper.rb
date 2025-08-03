module SeoHelper
  def meta_title(title = nil)
    content_for(:title) { title } if title.present?
    content_for?(:title) ? content_for(:title) : "ModelMention - LLM Brand Visibility & SEO Analysis"
  end

  def meta_description(desc = nil)
    content_for(:description) { desc } if desc.present?
    content_for?(:description) ? content_for(:description) : "ModelMention tracks your brand's LLM visibility, sentiment, and perception. Analyze mentions, keywords, and more using the latest AI models."
  end

  def meta_image(image = nil)
    content_for(:og_image) { image } if image.present?
    content_for?(:og_image) ? content_for(:og_image) : asset_url("icon.png")
  end

  def meta_keywords(keywords = nil)
    content_for(:keywords) { keywords } if keywords.present?
    content_for?(:keywords) ? content_for(:keywords) : "before and after photos, social media marketing, business marketing, salon marketing, contractor marketing, visual business, AI photo generation, social media automation, before after photos, business transformation photos, social media automation tool, AI marketing tool"
  end

  def meta_tags
    {
      title: meta_title,
      description: meta_description,
      image: meta_image,
      keywords: meta_keywords,
      canonical: request.original_url,
      author: "ModelMention",
      robots: "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1",
      type: "website",
      twitter_card: "summary_large_image",
      twitter_site: "@modelmention",
      twitter_creator: "@modelmention",
      og_site_name: "ModelMention",
      og_locale: "en_US",
      article_published_time: Time.current.iso8601,
      article_modified_time: Time.current.iso8601,
      article_author: "ModelMention",
      article_section: "Business",
      article_tag: meta_keywords.split(", ").first(5)
    }
  end

  def page_specific_meta_tags
    case request.path
    when root_path
      {
        title: "ModelMention - LLM Brand Visibility & SEO Analysis",
        description: "Transform your business with AI-powered before & after photo marketing. Automatically create and post engaging content to Facebook, Instagram, and Google Business Profile.",
        keywords: "before and after photos, AI marketing, social media automation, business transformation, visual marketing"
      }
    when blog_path
      {
        title: "ModelMention Blog - LLM, SEO, and Brand Insights",
        description: "Expert tips on before & after photo marketing, social media strategies, and business growth for visual businesses.",
        keywords: "marketing tips, business growth, before after photos, social media strategy"
      }
    when faq_path
      {
        title: "ModelMention FAQ - Common Questions About LLM Brand Analysis",
        description: "Find answers to common questions about ModelMention's LLM-powered brand visibility and sentiment analysis service.",
        keywords: "FAQ, help, support, before after photos, AI marketing questions"
      }
    else
      {}
    end
  end

  def breadcrumb_schema
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": breadcrumb_items
    }
  end

  def breadcrumb_label(item)
    # If this is the last breadcrumb, use the page title if available
    if item[:last]
      # Use content_for(:title) if set, otherwise humanize the name
      view_context = respond_to?(:view_context) ? view_context : self
      title = view_context.content_for?(:title) ? view_context.content_for(:title) : nil
      return title.presence || item[:name].to_s.titleize
    end

    # For known static segments, use a friendly label
    case item[:name].downcase
    when "blog"
      "Blog"
    when "features"
      "Features"
    when "faq"
      "FAQ"
    when "privacy"
      "Privacy Policy"
    when "terms"
      "Terms of Service"
    else
      item[:name].to_s.titleize
    end
  end

  private

  def breadcrumb_items
    items = []
    path_parts = request.path.split("/").reject(&:empty?)

    # Only add Home as the first item
    items << {
      "@type": "ListItem",
      "position": 1,
      "name": "Home",
      "item": root_url.chomp("/"),
      last: path_parts.empty?
    }

    real_parts = path_parts.reject { |part| part.blank? || part.downcase == "home" }
    real_parts.each_with_index do |part, index|
      items << {
        "@type": "ListItem",
        "position": index + 2,
        "name": part,
        "item": "#{root_url.chomp("/")}/#{real_parts[0..index].join("/")}",
        last: (index == real_parts.length - 1)
      }
    end

    items
  end
end
