require 'spec_helper.rb'

require_relative '../api.rb' 

describe 'api' do

	before(:all) do
	    DatabaseCleaner.clean
	end	

	describe 'account feature' do	

		it 'create user' do 
		    post '/social/bob@co.uk'

		    json = JSON.parse(last_response.body)
			expect(last_response.status).to eq(201)
			expect(json['email']).to eq('bob@co.uk')
		end

	end

	describe 'friends feature' do	

		before(:all) do
		    post '/social/bob@co.uk'
		end	

		it 'add a friend' do 
		    post '/social/bob@co.uk/friends/john@co.uk'

		    json = JSON.parse(last_response.body)
			expect(last_response.status).to eq(201)
			expect(json['friend']).to eq('john@co.uk')
		end

		it 'see your friends' do 
			get '/social/bob@co.uk/friends'

			json = JSON.parse(last_response.body)
			expect(json[0]['friend']).to eq('john@co.uk')
			expect(last_response.status).to eq(200)
		end

		it 'see your friend details' do 
			get '/social/bob@co.uk/friends/john@co.uk'

			json = JSON.parse(last_response.body)
			expect(json[0]['friend']).to eq('john@co.uk')
			expect(last_response.status).to eq(200)
		end

		it 'remove a friend' do 
			delete '/social/bob@co.uk/friends/john@co.uk'
			expect(last_response.status).to eq(202)
		end

	end

	describe 'message feature' do	

		before(:all) do
		    post '/social/bob@co.uk'
		    post '/social/john@co.uk'
		    post '/social/bob@co.uk/friends/john@co.uk'
		end	

		it 'add a new message' do 
		    post '/social/john@co.uk/message', 'message for john'

		    json = JSON.parse(last_response.body)
			expect(last_response.status).to eq(201)
			expect(json['message']).to eq('message for john')
		end

		it 'see friends messages' do 
			get '/social/bob@co.uk'
			
			json = JSON.parse(last_response.body)
			expect(json[0]['message']).to eq('message for john')
			expect(last_response.status).to eq(200)
		end

	end

end

