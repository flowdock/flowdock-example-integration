# Polldock - A Flowdock example integration

This is a simple application to create online polls. It illustrates how to send threaded activities into [Flowdock](https://www.flowdock.com/).

![Polldock-Flowdock screenshot](https://raw.githubusercontent.com/flowdock/flowdock-example-integration/master/assets/images/screenshot.png)

## Setup

Install dependencies with bundler (`bundle install`).

In Flowdock, [create an OAuth application](https://www.flowdock.com/oauth/applications/) and use the following values:

    Callback URL: <WEB_URL>/auth/flowdock/callback
    Setup URI: <WEB_URL>/flowdock/setup?flow={flow_id}&flow_url={flow_url}
    (Optional) Configuration URI: <WEB_URL>/flowdock/configure?source={source_id}&source_url={source_url}
    Icon: Choose an appropriate image for the application. You can use the images found in assets/images.

After creating the application, you will receive `Application Id` and `Secret` values. Copy the sample.env file to .env and add these values to the corresponding `FLOWDOCK_CLIENT_` -prefixed environment variables. Change WEB_URL to match the public endpoint for your application e.g. `http://localhost:3300`.

### Running the server

The following command starts the server and reloads it after filesystem changes:

    bundle exec rerun -- foreman start -p 3300

## Pairing with Flowdock

Open the application from [https://www.flowdock.com/oauth/applications] and use the `Select a flow to generate a Setup URI` -selector to generate a pairing url for the selected flow. Click the generated link to start the pairing routine. The selector uses the Setup URI that was given to the application and populates the `flow_id`and `flow_url` parameters to the uri.

After successfully setting up the source, the application will show up in the flow's inbox sources view and in the search filters.

## Heroku deployment

1. Create a Heroku application.
2. Add Postgres to your Heroku application.
3. Set up all the environment variables in Heroku.
  - Remember to change the WEB_URL component of the Callback, Setup and Configuration URIs in Flowdock to match the public endpoint for your Heroku application.
4. Push to Heroku.
