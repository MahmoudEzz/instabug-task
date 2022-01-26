# Instabug Back End Challenge

This project is to build a Chat Application API.

The technologies used:

● Ruby on Rails(V5) for building the API and the workers. 
● MySQL as your main datastore. 
● Sidekiq as queuing system.
● REDIS for caching.
● Elastic search.


## Getting Started


### Installing Dependencies
You should have Docker installed on your OS.

### Set environment variables
Create .env file in root directory of the project
Make a copy of .env_copy as .env file

### Run Docker
```bash
docker-compose up -d
```

### Building DB and Run Migrations
```bash
docker-compose run app rake db:create
docker-compose run app rake db:migrate
```

## Check Server Health
```bash
docker-compose ps
```

## API Reference

### Getting Started

* Run Instabug_Task.postman_collection file which is encluded in the repo
* You can find the endpoints for App API 
