FROM frolvlad/alpine-ruby
MAINTAINER Pavel Litvinenko <gerasim13@gmail.com>
# Install minicron build dependencies
RUN apk add --update git bash openssh build-base libstdc++ less \
    sqlite-libs sqlite-dev libxslt libxslt-dev ca-certificates \
    libxml2 libxml2-dev libffi libffi-dev zlib zlib-dev \
    ruby-dev ruby-bundler ruby-rake ruby-irb ruby-mysql2
# Enable auto completion, auto indent and history
RUN echo 'require "irb/completion"' >> "$HOME/.irbrc" && \
    echo 'IRB.conf[:AUTO_INDENT] = true' >> "$HOME/.irbrc" && \
    echo 'IRB.conf[:SAVE_HISTORY] = 1000' >> "$HOME/.irbrc"
# Install minicron
ENV APP_PATH=/app
WORKDIR $APP_PATH
ADD Gemfile* $APP_PATH/
RUN gem install nokogiri -- --use-system-libraries
RUN gem install ffi -- --use-system-libraries
RUN gem install erubis net-ssh mail formatador
RUN bundle install
RUN bundle update
RUN rc-update add sshd
# Cleanup
RUN apk del build-base ruby-dev sqlite-dev libxslt-dev libxml2-dev libffi-dev zlib-dev && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*
# Expose minicron on port 9292
EXPOSE 9292
# Set up the sqlite database
VOLUME ["/db"]
ONBUILD RUN minicron db setup
CMD ["irb"]
