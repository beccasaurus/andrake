# Android application configuration

#app_name    'Basic UI'
#app_package 'com.android.basicui'

set :application, 'Basic UI' # optional - use directory name
set :package,     'com.android.basicui' # optional, use com.android.[application]

Andrake.config do |config|

  config.icon 'path/to/icon.png' # should use a good default ... if you simply update the .png

  # these should all come out-of-the-box ... this is better for custom intent filters!
  config.activity :BasicUI, :main => true do |activity|
    activity.intent_filter :action => 'main', :category => 'launcher'
  end

  # these should all come out-of-the-box (all activities will auto be included) ... this is better for custom intent filters!
  config.activity :another_view
  config.activity :UiResult # case to use?

end
