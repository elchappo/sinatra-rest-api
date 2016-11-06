## Instructions
1. clone project

`git clone git@github.com:noren/sinatra-rest-api.git`

2. start docker inside project directory 

`cd sinatra-rest-api && docker-compose up`

3. Once docker is started you should be able to see api @

`http://127.0.0.1:8080`

## Create users

`curl -X POST http://127.0.0.1:8080/social/bob@co.uk`

`curl -X POST http://127.0.0.1:8080/social/joe@co.uk`

## Add friend 

`curl -X POST http://127.0.0.1:8080/social/bob@co.uk/friends/joe@co.uk`

## Create message

`curl --data "message from joe" http://127.0.0.1:8080/social/joe@co.uk/message`

## Delete friend

`curl -X DELETE http://127.0.0.1:8080/social/bob@co.uk/friends/joe@co.uk`

## Tests

`docker exec -ti api /bin/bash -c 'rspec spec/api_specs.rb`

