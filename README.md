# Installation

The following is a list of notes to help install the main PointGaming application.

## Required Software

* Git
* ruby 1.9.3
* RubyGems
* Nginx
* MongoDB
* Redis
* RabbitMQ

## Instructions

1. Clone the Git repo

```shell
git clone <repo_url>
cd <directory>
```

2. Install the gems required by the application

```shell
bundle install
```

## Application Configuration

The applications default configuration should work pretty well, though you may need to change some things depending on your environment.

1. MongoDB Configuration Location

```shell
./config/mongoid.yml
```

2. Redis Configuration

We are using Redis as an in-memory session storage, which will allow us to share user sessions across multiple rails apps.

```shell
./config/environments/production.rb
```

Within this file, you can find the following line:

```shell
config.session_store :redis_store, :key => '_pg_session', :domain => '.pointgaming.com'
```

You may need to change it like so:

```shell
config.session_store :redis_store, :key => '_pg_session', :domain => '.pointgaming.com', :servers => "redis://:secret@127.0.0.1:6999/10"
```

3. RabbitMQ Configuration

We need to expose an easy way to configure the RabbitMQ server.

4. General configuration

The applications general configuration allows us to specify things like the url to the PointGaming Forums as well as the API password to use when communicating with the PointGaming Store API.

```shell
./config/config.yml
```

## Webserver Configuration

You will need to configure an SSL and non-SSL virtual host in the Nginx configuration file to point to the ./public directory in the PointGaming Application folder.

```shell
On our servers, it is located at:
/opt/nginx/config/nginx.conf
```

```shell
server {
  listen 80;
  server_name dev.pointgaming.com dev.pointgaming.net;
  root /point-gaming-rails/public;
  passenger_enabled on;
}

server {
  listen 443;
  ssl on;
  ssl_certificate /etc/ssl/certs/star_pointgaming_com.pem;
  ssl_certificate_key /opt/nginx/keys/server.key;
  server_name dev.pointgaming.com dev.pointgaming.net;
  root /point-gaming-rails/public;
  passenger_enabled on;
}
```

## Load the default data

We will need to populate the database with some necessary data (games and example tournaments)

```shell
bundle exec rake db:seed
```
