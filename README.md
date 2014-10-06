# Polldock - A Flowdock example integration

This is a simple polling application that illustrates how to integrate an application to Flowdock to receive threaded activities.

## Setup

Install dependencies with bundler (`bundle install`).

To set up the application, register OAuth application for the example application and Flowdock.

In Flowdock, [set up OAuth application](https://www.flowdock.com/oauth/applications/) and use the following values

    Callback URL: https://<WEB_URL>/auth/flowdock/callback
    Icon: Choose appropriate images for the application. You can use the images found in assets/images

Copy the sample.env file to .env and setup the received application id and secret keys to the corresponding FLOWDOCK environment variables.
Also set the `WEB_URL` variable to the public endpoint of your app.

OR if you deploy to Heroku, then set the environment variables according to their documentation.

## Usage

Point your browser to `https://<WEB_URL>/flowdock/setup?flow=<flow id>` to start pairing routine. This is done via the
Flowdock account's applications view at some point

The following command starts server and reloads after filesystem changes:

    bundle exec rerun -- foreman start -p 3300

## Heroku deployment

1. Create Heroku application
2. Add Postgres to your Heroku application
3. Set environment variables in Heroku configuration
4. Push to Heroku
