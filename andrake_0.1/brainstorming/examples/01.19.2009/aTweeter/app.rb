# example andrake application file
#
# all of these things should be in blocks so they can *actually* happen anywhere, 
# the file names are arbitrary  :)
#
Andrake::App.config do

  app 'aTweeter', :version => '1.5.1', :company => 'dattasmoon', :debuggable => 'true',
      :description => 'cool app', # will be available to res as @app.description
      :arbitrary => 'neato'

  permissions :internet, :camera, :vibrate

  service :aTweeterService

  activity :aTweeter, :main => true
  activity :Settings, :theme => 'Theme.Dialog', :action => 'settings'
  activity :ImageCapture, :action => true
  # more ...
  
end
