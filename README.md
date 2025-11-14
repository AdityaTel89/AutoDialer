# Autodialer - Ruby on Rails

A bulk autodialer web application built with Rails 7. Supports batch phone calls to Indian numbers using Twilio, AI voice prompts, CSV/text upload, live call log, and dashboard statistics.

## Features

- Bulk or single call initiation via web dashboard
- Upload numbers via CSV/text or paste directly
- Custom AI voice prompt per call
- Uses Twilio API for call automation
- Tracks call status, answer rate, and duration
- Dashboard view with live call logs and stats
- Ready for cloud deployment (Render, Railway, etc.)

## Requirements

- Ruby 3.4+
- Rails 7.1+
- PostgreSQL and Redis databases
- Twilio account (+ live/verified number)
- Optional: OpenAI & ElevenLabs API keys for advanced prompts

## Quick Setup

1. **Clone the repo:**
git clone <your-repo-url>
cd autodialer


2. **Install dependencies:**
bundle install
yarn install

3. **Configure environment variables:**
- Copy `.env.example` to `.env`
- Add your Twilio, DB, and AI API keys

4. **Setup the database:**
rails db:setup


5. **Start the app (development):**
rails server
rails tailwindcss:watch # in a separate terminal

6. **Optional: Run background jobs**
- For small-scale: Inline jobs (default, no worker needed)
- For production bulk: Set up Sidekiq and a Redis instance

## Deployment

- Deploy to Render, Railway, or any cloud platform.
- Set all production environment variables (see `.env.example`).
- Point your Twilio webhook URLs to `/webhooks/voice` and `/webhooks/status` on your deployed domain.
- For batch call features, you may need worker support (Sidekiq or Inline).

## Usage

1. Access the dashboard at `/`
2. Paste/upload numbers and set your caller message
3. Click to start calls; monitor results in the call log area

## License

MIT
