SitemapGenerator::Sitemap.default_host = "https://modelmention.ai"

SitemapGenerator::Sitemap.create do
  # Home page with high priority and frequent updates
  add root_path,
      changefreq: "daily",
      priority: 1.0,
      lastmod: Time.current

  # Public static pages
  add privacy_path,
      changefreq: "monthly",
      priority: 0.6,
      lastmod: Time.current
  add terms_path,
      changefreq: "monthly",
      priority: 0.6,
      lastmod: Time.current
  add faq_path,
      changefreq: "monthly",
      priority: 0.7,
      lastmod: Time.current
  add blog_path,
      changefreq: "weekly",
      priority: 0.8,
      lastmod: Time.current
  add features_path,
      changefreq: "monthly",
      priority: 0.9,
      lastmod: Time.current

  # Auth pages (important for conversion)
  add sign_up_path,
      changefreq: "monthly",
      priority: 0.9,
      lastmod: Time.current
  add sign_in_path,
      changefreq: "monthly",
      priority: 0.8,
      lastmod: Time.current

  # Blog posts
  blog_posts = Dir.glob(Rails.root.join("app/views/pages/blog/*.html.erb"))
  blog_posts.each do |post_file|
    slug = File.basename(post_file, ".html.erb")
    add blog_post_path(slug),
        changefreq: "monthly",
        priority: 0.7,
        lastmod: Time.current
  end
end
