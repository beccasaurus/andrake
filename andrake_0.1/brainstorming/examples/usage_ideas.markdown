usage ideas
===========

so ... maybe we wanna rails-esque project with generators and whatnot ...

    $ sudo gem install andrake
    $ andrake myapp && cd myapp # <--- should have a full blown hello world
    $ ... has some files ... incl a Rakefile to help with building etc ... and some dir (with a ., should be hidden) for the actual output ...

how about ... installing, generating a project (hello world, by default) and then running it??

    $ sudo gem install andrake
    $ andrake myapp
    $ cd myapp
    $ rake      # or rake run or rake debug or ... something

how about making 1 file that's a full-blown Android app?  we need to run it somehow ...

    $ vi myapp.rb
    $ andrake myapp.rb  # if andrake gets passed a file, run that sucker!
