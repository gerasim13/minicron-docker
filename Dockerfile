FROM frolvlad/alpine-ruby
MAINTAINER Pavel Litvinenko <gerasim13@gmail.com>
# Install minicron build dependencies
RUN apk update
RUN apk add git bash build-base ruby-dev
RUN apk add sqlite-libs sqlite-dev
RUN apk add libxslt libxslt-dev
RUN apk add libxml2 libxml2-dev
RUN apk add libffi libffi-dev
RUN apk add zlib zlib-dev
RUN apk add ruby-rake ruby-mysql2
RUN apk add libstdc++ less
# Install minicron
ENV APP_PATH=/app
WORKDIR $APP_PATH
ADD Gemfile* $APP_PATH/
RUN gem install nokogiri -- --use-system-libraries
RUN gem install ffi -- --use-system-libraries
RUN gem install erubis net-ssh mail formatador
RUN bundle install
RUN bundle update
CMD ["/usr/bin/irb"]
# Install openssh
RUN apk add openssh
RUN rc-update add sshd
RUN /etc/init.d/sshd start
# Cleanup
RUN apk del build-base ruby-dev sqlite-dev libxslt-dev libxml2-dev libffi-dev zlib-dev && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*
# Expose minicron on port 9292
EXPOSE 9292
# Set up the sqlite database
VOLUME ["/db"]
ONBUILD RUN minicron db setup
