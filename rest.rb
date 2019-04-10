require 'sinatra'
require 'json'
require_relative './models/red_pencil_entry'
require_relative './repositories/item_price_history_source'
require_relative './repositories/red_pencil_source'
require_relative './services/red_pencil_validation'

item_history_source = ItemPriceHistorySource.new
red_pencil_source = RedPencilSource.new

get '/item_history/all' do
  content_type :json
  item_history_source.all.collect(&:to_hash).to_json
end

get '/item_history/:item_id' do
  content_type :json
  item_history_source.get_item_entries(params['item_id']).collect(&:to_hash).to_json
end

post '/item_history' do
  content_type :json
  request.body.rewind
  data = JSON.parse request.body.read
  if data['item_id'].nil? || data['price'].nil? || data['entrydate'].nil? 
    return 400
  end
  item_history_source.add(data['item_id'], data['price'], data['entrydate'])
  item_history_source.get_item_entries(data['item_id']).first.to_hash.to_json
end

get '/red_pencil/all' do
  content_type :json
  red_pencil_source.all.collect(&:to_hash).to_json
end

get '/red_pencil/:item_id' do
  content_type :json
  red_pencil_source.all.collect(&:to_hash).to_json
end

post '/red_pencil/eligibility/:item_id' do
  content_type :json
  item_histories = item_history_source.get_item_entries(params['item_id'])[0..1]
  last_red_pencil = red_pencil_source.get_item_entries(params['item_id']).first
  validator = RedPencilValidation.new(item_histories[0], item_histories[1], last_red_pencil)
  response = {eligible: false}
  if validator.eligible_for_new_red_pencil?
    red_pencil_source.add(validator.new_red_pencil)
    response['eligible'] = true
  elsif validator.should_be_expired?
    red_pencil_source.update(validator.expired_red_pencil)
  elsif validator.exists_and_active?
    response['eligible'] = true
  end
  response.to_json
end

post '/red_pencil' do
  #for testing only, in real scenarios only the eligibility call should add
  content_type :json
  request.body.rewind
  data = JSON.parse request.body.read
  if data['item_id'].nil? || data['price'].nil? || data['entrydate'].nil?
    return 400
  end
  red_pencil_source.add(RedPencilEntry.new(nil, data['item_id'], data['price'], data['entrydate'], nil))
  red_pencil_source.get_item_entries(data['item_id']).first.to_hash.to_json
end