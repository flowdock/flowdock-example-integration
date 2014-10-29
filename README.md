# Polldock - A Flowdock example integration

This is a simple polling application that illustrates how to integrate an application to Flowdock to receive threaded activities.

## Setup

Install dependencies with bundler (`bundle install`).

To set up the application, register OAuth application for the example application and Flowdock.

In Flowdock, [set up OAuth application](https://www.flowdock.com/oauth/applications/) and use the following values

    Callback URL: <WEB_URL>/auth/flowdock/callback
    Setup URI: <WEB_URL>/flowdock/setup?flow={flow_id}&flow_url={flow_url}
    (Optional) Configuration URI: <WEB_URL>/flowdock/configure?source={source_id}&source_url={source_url}
    Icon: Choose appropriate images for the application. You can use the images found in assets/images

After creating the application you will receive `Application Id` and `Secret` values. Copy the sample.env file to .env and setup the values to the corresponding `FLOWDOCK_CLIENT_` -prefixed environment variables. Set the WEB_URL to match the public endpoint for your application e.g. `http://localhost:3300`

### Running the server

The following command starts server and reloads after filesystem changes:

    bundle exec rerun -- foreman start -p 3300

## Pairing with Flowdock

Open the application's view from https://www.flowdock.com/oauth/applications and use the `Select a flow to generate a Setup URI` -selector to generate a pairing url to the selected flow. Click the generated link to start the pairing routine. The selector uses the Setup URI given to the application and populates the `flow_id`and `flow_url` parameters to the uri.

After setting up the source successfully, the application will show up in the flow's inbox sources -view and in the filters.

## Heroku deployment

1. Create Heroku application
2. Add Postgres to your Heroku application
3. Set all the environment variables to Heroku
  - Remember to set the WEB_URL to match the public endpoint for your Heroku application
4. Push to Heroku

Remember to set up the corresponding Callback, Setup and Configuration URIs to the application in Flowdock.
