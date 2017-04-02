require "net/http"
require "json"

todoist_token = 'd2ebd14d799ec7565b18aa22b818fca49d6649b5'

SCHEDULER.every '5m', :first_in => 0 do |job|
    item_url_string  = 'https://todoist.com/API/v7/sync?token=d2ebd14d799ec7565b18aa22b818fca49d6649b5&resource_types=["items"]&sync_token=\'*\''
    encoded_item_url_string = URI.encode(item_url_string)

    item_uri = URI.parse(encoded_item_url_string)
    http = Net::HTTP.new(item_uri.host, item_uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(item_uri.request_uri)
    response = http.request(request)

    if response.code == "200"
        result = JSON.parse(response.body)
        items = result['items']
        items_array = Array[]
        items.each do |st|
             items_array.push(st['content'])
        end
        puts items_array
        send_event('todoist', {items: items_array})
    else
        puts response.code
        puts "NOT 200"
        puts response.body
        puts item_url_string
    end
end