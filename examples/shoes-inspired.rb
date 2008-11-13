Andrake.app 'Mini Android App' do
  button 'Click Me!' do
    msgbox "Hello Android!"
  end
end

#-------------------------------------------------------

Andrake.app 'Mini Android App' do
  relative_layout :background => :white do
    txt = text_edit
    button 'click me' do
      txt.text = 'clicked!'
    end
  end
end
