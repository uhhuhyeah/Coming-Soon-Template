require 'rubygems'
require 'sinatra'
require 'erb'
require 'sinatra/static_assets'
# require 'sqlite3'
require 'dm-core'
require 'dm-migrations'

configure :development do
  ## Run
  # sqlite3 test.db "create table mailing_lists (id INTEGER PRIMARY KEY, email STRING, created_at DATETIME);"
  
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/test.db")
  DataMapper.auto_upgrade!
end

configure :production do
  ## ENV['DATABASE_URL'] is provided by heroku for connecting to their Postgres db
  ## See this for more info - http://docs.heroku.com/database#using-the-databaseurl-environment-variable-sequel--datamapper
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'sqlite3://application.db')
end

class MailingList
  include DataMapper::Resource
  property :id,         Serial
  property :email,      String, :length => 150
  property :created_at, DateTime
end

DataMapper.finalize

get '/' do
  @list = MailingList.all.count
  erb :index
end

get '/thanks' do
  erb :thanks
end

post '/subscribe' do
  email = params[:subscribe][:email]
  
  unless email.blank? || email == 'Enter your email address'
    MailingList.create(:email => email, :created_at => Time.now.utc)
  end
  
  redirect '/thanks'
end

__END__

@@ layout
<!doctype html>
<head>
  <meta charset="utf-8">

  <!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame 
       Remove this if you use the .htaccess -->
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

  <title>TwoDaysToDos</title>
  <meta name="description" content="">
  <meta name="author" content="">

  <!--  Mobile viewport optimized: j.mp/bplateviewport -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- Place favicon.ico & apple-touch-icon.png in the root of your domain and delete these references -->
  <link rel="shortcut icon" href="/favicon.png">

  <!-- CSS : implied media="all" -->
  <link rel="stylesheet" href="css/style.css">
</head>

<body>

  <div id="container">
    <header>
			<div id="top-uhy-logo">
				<%= link_to image_tag('images/uhy_logo_small.png'), 'http://uhhuhyeah.com/' %>
			</div>
			<div id="top-social-links">
				<%= link_to image_tag('images/email_26_dark.png'), 'mailto:hello@uhhuhyeah.com', :class => 'top-social-link' %>
				<%= link_to image_tag('images/facebook_26_dark.png'), 'http://www.facebook.com/pages/Uh-Huh-Yeah/101176768856', :class => 'top-social-link' %>
				<%= link_to image_tag('images/twitter_26_dark.png'), 'http://twitter.com/uhhuhyeah', :class => 'top-social-link' %>
			</div>
			<div class="clearfix"></div>
			<div id="main-logo">
				<%= link_to image_tag('images/site_icon.png'), '/' %>
			</div>
    </header>
    
    <div id="main">
			<%= yield %>
    </div>
    
    <footer>
			<p><strong>TwoDaysToDos</strong> - proudly built by <a href="http://uhhuhyeah.com/">Uh Huh Yeah</a></p>
			<p id="small">&copy; Copyright 2010 Uh Huh Yeah | <a href="mailto:hello@uhhuhyeah.com">Contact</a></p>
    </footer>
  </div> <!--! end of #container -->

  <!-- asynchronous google analytics: mathiasbynens.be/notes/async-analytics-snippet 
       change the UA-XXXXX-X to be your site's ID -->
  <script>
   var _gaq = [['_setAccount', 'UA-6668516-13'], ['_trackPageview']];
   (function(d, t) {
    var g = d.createElement(t),
        s = d.getElementsByTagName(t)[0];
    g.async = true;
    g.src = ('https:' == location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    s.parentNode.insertBefore(g, s);
   })(document, 'script');
  </script>
  
</body>
</html>

@@ index
<h1 class="intro-copy">Todos for today, todos for tomorrow and nothing else.</h1>

<div id="features">
	<div id="screenshot">
		<%= image_tag('images/screenshot.png', :id => 'screenshot-image') %>
	</div>
</div>
<div id="email-section">
	<h2 class="intro-copy">Receive an email when <span id="inline-logo">TwoDaysToDos</span> is available in the App Store</h2>
	<div id="email-form-holder">
		<form action='/subscribe' method='post'>
		   <input id='subscribe_email' name='subscribe[email]' type='text' placeholder=" Your email address" >
		   <input class='submit' name='Submit' type='submit' value='Submit'>
		</form>
	</div>
</div>

@@ thanks
<h2 class="intro-copy"><span style="color:#db0096;">Thank You</span> - We'll let you know when <span id="inline-logo">TwoDaysToDos</span> is ready</h2>