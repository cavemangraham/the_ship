require 'twilio-ruby'
require 'sinatra'
require 'json'

class Cache
  @@msg = ""

  def self.init()
    @@msg = ""
  end

  def self.current()
    return @@msg
  end

  def self.update(response)
    @@msg = response
  end
end

configure do
  Cache::init()
end

post '/alexa' do
  parsed_request = JSON.parse(request.body.read)
  #puts JSON.pretty_generate(parsed_request)
  #puts "------------------------------------------------"
  message = "I'm sorry, something has gone wrong."
  if parsed_request["request"]["type"] == "LaunchRequest"
    message = "Good morning Sean. What would you like me to do for you today?"
    ask(message)
  else
    task = parsed_request["request"]["intent"]["slots"]["Task"]["value"]
    puts task
    Cache::update(task)
    sleep(6)
    message = Cache::current().to_s
    ask(message)
  end
end

post "/respond" do
  Cache::update(request["message"])
end

get "/" do
  @message = Cache::current().to_s
  erb :index
end

def ask(message)
  {
    version: "1.0",
    sessionAttributes: {
      numberOfRequests: 1 #key value pair for tracking state
    },
    response: {
      outputSpeech: {
        type: "PlainText",
        text: message
      },
      shouldEndSession: false,
    }
  }.to_json
end

def say(message)
  {
    version: "1.0",
    response: {
      outputSpeech: {
        type: "PlainText",
        text: message
      }
    }
  }.to_json
end
