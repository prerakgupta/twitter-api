
This api uses the tweetstream gem to make a connection to the Twitter Streamng API and tracks all the tweets with a particulr hashtag.

Ruby version 2.0.0

<b>Install bundler and gems</b>
	
	gem install bundler
	bundle install

<b> Database creation </b>

	The application uses mysql2 database. Run the config/initialisers/create_db.sql from the mysql console like 
	"source path_to_file" to create the database.
	Add your mysql username and password in the config/database.yml.
	Then run bundle exec rake db:migrate to run the migrations.

<b> Deployment instructions </b>

	To deploy run RAILS_ENV=production rails s -p 3000
	Then open localhost:3000 in your browser and start crunching!
	

