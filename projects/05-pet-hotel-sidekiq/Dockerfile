FROM ruby:3.3-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libsqlite3-0 libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/rails", "s", "-b", "0.0.0.0"]
