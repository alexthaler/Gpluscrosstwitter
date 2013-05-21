##GplusCrossTwitter

#####What is it?

This is a simple ruby script I wrote up to cross post my Google+ posts to my Twitter account. 

 

#####How do I run it?

Install the dependencies from the Gemfile

    bundle install
    
Input your api keys (for more info on how to do this see below) into gplus_twitter_config.yml

To ensure that you don't post your entire Google+ history when starting the app be sure to run the populate_last_etag script before starting the app.
    
    ./populate_last_etag.sh

Run

    ./run.sh
    
    
#####Disclaimer

*FYI:* Use this on your own risk, if there are bugs in the code, which there almost certainly is, this app has access to post to your twitter account and annoy all of your followers.

#####Gems Used

I used the following gems and all credit for their awesome libraries goes to them.

[twitter](https://github.com/sferik/twitter)

[google_plus](https://github.com/seejohnrun/google_plus)

[googl](https://github.com/zigotto/googl)

[oj](https://github.com/ohler55/oj)
