# Chat Rooms - Basic Docker Setup
# Elixir 1.14 with Erlang/OTP 25
FROM elixir:1.14.5-alpine

# Set environment
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=this_is_a_very_long_secret_key_for_docker_demo_only_do_not_use_in_production_this_needs_to_be_at_least_64_bytes_long_to_work_with_phoenix_cookie_store
ENV PHX_SERVER=true
ENV PHX_HOST=localhost
ENV PORT=4000

# Install dependencies
RUN apk add --no-cache build-base nodejs npm git

# Set working directory
WORKDIR /app

# Copy source code
COPY server/ .

# Install and compile
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get
RUN mix compile

# Build assets
RUN mix assets.deploy

# Expose port
EXPOSE 4000

# Start server
CMD ["mix", "phx.server"]