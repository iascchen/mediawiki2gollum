FROM ubuntu:14.04

MAINTAINER Takahiro Suzuki <suttang@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update
RUN apt-get upgrade -y

# Set the locale
RUN locale-gen zh_CN.UTF-8  
ENV LANG zh_CN.UTF-8  
ENV LANGUAGE zh_CN.UTF-8

RUN apt-get install -y -q build-essential ruby1.9.3 python2.7 ruby-bundler libicu-dev libreadline-dev libssl-dev zlib1g-dev git-core
RUN apt-get clean
RUN rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install gollum
RUN gem install gollum chinese_pinyin hpricot git
# RUN gem install kramdown redcarpet github-markdown wikicloth RedCloth asciidoctor
RUN gem install wikicloth RedCloth asciidoctor

# Initialize wiki data
RUN mkdir /root/wikidata
RUN git init /root/wikidata

# Expose default gollum port 4567
EXPOSE 4567

ENTRYPOINT ["/usr/local/bin/gollum", "/root/wikidata"]