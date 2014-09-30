# Flowdock example integration

This is a simpe Todo-application that shows how to integrate an application to Flowdock to receive notifications.

## Setup

Install dependencies with bundler (`bundle install`).

Then, to set up the application, register OAuth application for the example application and Flowdock.

In Flowdock, [set up OAuth application](https://www.flowdock.com/oauth/applications/) and use the following values

    Callback URL: https://<WEB_URL>/auth/flowdock/callback
    Icon: Some icon

Next copy the sample.env file to .env and setup the received application id and secret keys to the corresponding FLOWDOCK environment variables.
Also set the `WEB_URL` variable to the public endpoint of your app.

## Usage

Point your browser to `https://<WEB_URL>/flowdock/setup?flow=<flow id>` to start pairing routine.

The following command starts server and reloads after filesystem changes:

    bundle exec rerun -- foreman start -p 3300
