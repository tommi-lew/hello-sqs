require 'dotenv'
require 'aws-sdk-sqs'

Dotenv.load

sqs = Aws::SQS::Client.new(
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  region: 'ap-southeast-1'
)

queue_name = 'hello-sqs-long'
queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url

begin
  poller = Aws::SQS::QueuePoller.new(queue_url)

  # Polling indefinitely by removing idle_timeout
  poller_stats = poller.poll({
    max_number_of_messages: 10,
    idle_timeout: 10
  }) do |messages|
    messages.each do |message|
      puts "Message body: #{message.body}"
      puts "Name: #{message.message_attributes["name"]["string_value"]}"
      puts "Level: #{message.message_attributes["level"]["string_value"]}"
      puts message.message_attributes
      puts '--------------------'
    end
  end
  # Note: If poller.poll is successful, all received messages are automatically deleted from the queue.

rescue Aws::SQS::Errors::NonExistentQueue
  puts "Cannot receive messages using Aws::SQS::QueuePoller for a queue named '#{receive_queue_name}', as it does not exist."
end
