# Monkey-patch SitemapGenerator to disable all search engine pings (including Google)
module SitemapGenerator
  class LinkSet
    def ping_search_engines(*args)
      # Do nothing
    end
  end
end
