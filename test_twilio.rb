require 'twilio-ruby'
require 'dotenv/load'

account_sid = ENV['TWILIO_ACCOUNT_SID']
auth_token = ENV['TWILIO_AUTH_TOKEN']
from_number = ENV['TWILIO_PHONE_NUMBER']

puts "Account SID: #{account_sid}"
puts "From Number: #{from_number}"

client = Twilio::REST::Client.new(account_sid, auth_token)

begin
  call = client.calls.create(
    from: from_number,
    to: '+918999936625',
    url: 'http://demo.twilio.com/docs/voice.xml'
  )
  
  puts "Call created successfully!"
  puts "Call SID: #{call.sid}"
  puts "Status: #{call.status}"
rescue => e
  puts "Error: #{e.message}"
end
