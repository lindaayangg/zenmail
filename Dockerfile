# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t easystory .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name easystory easystory

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips libpq5 librsvg2-bin \
    fonts-liberation fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install ImageMagick 7 from source
RUN apt-get update && apt-get install -y wget autoconf pkg-config && \
    apt-get install -y --no-install-recommends \
        build-essential autoconf pkg-config wget \
        libjpeg-dev      \
        libpng-dev       \
        libfreetype6-dev \
        libxml2-dev      \
        libfontconfig1-dev && \
    wget https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.1.0-31.tar.gz && \
    tar xzf 7.1.0-31.tar.gz && \
    rm 7.1.0-31.tar.gz && \
    apt-get clean && \
    apt-get autoremove

RUN sh ./ImageMagick-7.1.0-31/configure --prefix=/usr/local --with-jpeg=yes --with-png=yes --with-fontconfig=yes --with-freetype=yes --with-xml=yes --without-magick-plus-plus && \
    make -j$(nproc) && make install && ldconfig /usr/local/lib/

# Add required native build tools
RUN apt-get update && apt-get install -y build-essential python3 g++ pkg-config

# Install node
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config unzip libpq-dev librsvg2-bin \
    fonts-liberation fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV BUN_INSTALL=/usr/local/bun
ENV PATH=/usr/local/bun/bin:$PATH
ARG BUN_VERSION=1.2.15
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules for bun
RUN npm install -O @parcel/watcher-linux-x64-glibc
COPY package.json bun.lock ./
RUN bun add -d @tailwindcss/oxide-linux-x64-gnu
RUN bun install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Ensure bun handles tailwind node bash binary
RUN ln -s /usr/local/bun/bin/bun /usr/local/bun/bin/node

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN TAILWINDCSS_INSTALL_DIR=node_modules/.bin SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Generate sitemap
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails sitemap:refresh

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]