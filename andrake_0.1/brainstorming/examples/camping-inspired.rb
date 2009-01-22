Andrake.goes :MiniAndroidApp

module MiniAndroidApp::Activities
  class HelloAndroid < Activity
    layout :main
    
    events do |handle|
      handle.click :btn { txt.text = 'clicked!' }
    end
  end
end

module MiniAndroidApp::Layouts
  def main
    relative_layout do
      text_edit.txt!
      button.btn! 'Click Me'
    end
  end
end

module MiniAndroidApp::Services; end
module MiniAndroidApp::IntentReceivers; end
