require 'dotenv'
require 'aws-sdk-sqs'
require 'faker'

Dotenv.load

sqs = Aws::SQS::Client.new(
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  region: 'ap-southeast-1'
)

queue_name = 'hello-sqs-long'
queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url

begin
  (1..50).each do |n|
    name = Faker::Pokemon.name
    level = n

    send_message_result = sqs.send_message({
      queue_url: queue_url,
      message_body: 'Pokemon level update',
      message_attributes: {
        'name' => {
          string_value: name,
          data_type: 'String'
        },
        'level' => {
          string_value: level.to_s,
          data_type: 'Number'
        }
      }
    })

    puts send_message_result.message_id
  end

rescue Aws::SQS::Errors::NonExistentQueue
  puts "A queue named '#{queue_name}' does not exist."
  exit(false)
end
