# Encoding: utf-8
require 'rubygems'
require 'bundler'

Bundler.require

require 'sinatra'
require 'mongoid'
require 'roar/json/hal'
require 'rack/conneg'

configure do
  Mongoid.load!('config/mongoid.yml', settings.environment)
  set :server, :puma 
end

use(Rack::Conneg) { |conneg|
  conneg.set :accept_all_extensions, false
  conneg.set :fallback, :json
  conneg.provide([:json])
}

before do
  content_type :json
end

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :email, type: String
end

class Friend
  include Mongoid::Document
  include Mongoid::Timestamps
  field :email, type: String
  field :friend, type: String
end

class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :email, type: String
  field :message, type: String
  field :friends, type: Array
end

module UserRepresenter
  include Roar::JSON::HAL
  property :email
  property :created_at, :writeable=>false
  link :self do
    "/social/#{email}"
  end
end

module FriendRepresenter
  include Roar::JSON::HAL
  property :friend
  property :created_at, :writeable=>false
  link :self do
    "/social/#{email}/friends/#{friend}"
  end
end

module MessageRepresenter
  include Roar::JSON::HAL
  property :message
  property :created_at, :writeable=>false
end

get '/social/:email' do |email|

  if !User.where(email: email).exists?
    halt 400, {:message=>'This user doesnt exist. Please create user first.'}.to_json
  end

  messages = Message.where(friends: email)
  MessageRepresenter.for_collection.prepare(messages).to_json

end

get '/social/:email/friends' do |email|
  
  if !User.where(email: email).exists?
    halt 400, {:message=>'This user doesnt exist. Please create user first.'}.to_json
  end

  friends = Friend.where(email: email)
  FriendRepresenter.for_collection.prepare(friends).to_json

end

get '/social/:email/friends/:friend_email' do |email,friend_email|

  if !User.where(email: email).exists?
    halt 400, {:message=>'This user doesnt exist. Please create user first.'}.to_json
  end

  if !Friend.where(email: email, :friend=>friend_email).exists?
    halt 400, {:message=>'Those users are not friends.'}.to_json
  end

  friend = Friend.where(email: email, friend: friend_email)

  FriendRepresenter.for_collection.prepare(friend).to_json

end

post '/social/:email' do |email|

  if User.where(email: email).exists?
    halt 400, {:message=>'This user already exist.'}.to_json
  end

  user = User.new(:email=>email)

  if user.save
    [201, user.extend(UserRepresenter).to_json]
  else
    [500, {:message=>'Failed to create user.'}.to_json]
  end

end

post '/social/:email/message' do |email|

  if !User.where(email: email).exists?
    halt 400, {:message=>'This user doesnt exist. Please create user first.'}.to_json
  end

  friend_emails = Friend.only(:email).where(friend: email).distinct(:email)

  message = Message.new(:email=>email, :message=>request.body.read, :friends=>friend_emails.entries)

  if message.save
    [201, message.extend(MessageRepresenter).to_json]
  else
    [500, {:message=>'Failed to add message.'}.to_json]
  end

end

post '/social/:email/friends/:friend_email' do |email,friend_email|

  if !User.where(email: email).exists?
    halt 400, {:message=>'This user doesnt exist. Please create user first.'}.to_json
  end

  if Friend.where(email: email, :friend=>friend_email).exists?
    halt 400, {:message=>'This user has that friend already.'}.to_json
  end

  friend = Friend.new(:email=>email, :friend=>friend_email)

  if friend.save
    [201, friend.extend(FriendRepresenter).to_json]
  else
    [500, {:message=>'Failed to add friend to account.'}.to_json]
  end

end

delete '/social/:email/friends/:friend_email' do |email,friend_email|

  if !User.where(email: email).exists?
    halt 400, {:message=>'This user doesnt exist. Please create user first.'}.to_json
  end

  if !Friend.where(email: email, :friend=>friend_email).exists?
    halt 400, {:message=>'Those users are not friends.'}.to_json
  end

  friend = Friend.where(email: email, friend: friend_email)

  if friend.delete
    [202, {:message=>'Friend removed.'}.to_json]
  else
    [500, {:message=>'Failed to remove friend.'}.to_json]
  end

end
