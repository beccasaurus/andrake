# ruby version of BasicUI.java - which 'compiles' to the same code but also has simpler access to resources, etc

import         %w( apache.foo something.* )
import_android %w( view.View content.Intent os.Bundle widget.* )

class BasicUI < Activity
  layout :main
  ui_elements :txt, :btn1, :foo, :button2, :btn3, :btn4

  # should be able to do BOTH of these on_create's ... or any combination ... it'll just concatenate into onCreate()
  on_create do
    ruby_that_emits_java
  end
  on_create %{
    JAVA
  }

  events do |handle|
    handle.click :btn1, :on_click

    # raw Java
    handle.click :button2, %{
      txt.setTitle('foo!');
    }

    handle.click :btn3 do
      msgbox 'hello!'
    end

    handle.click :btn4 do
      msgbox txt.text # should call txt.getText()
    end

    handle.click :btn5 do
      txt.text = 'neato' # should call txt.setText('neato');
      msgbox txt.text # should make a popup dialog with the text of txt (txt.getText())
    end
  end

  # raw java to stick in the class
  java %[
    public void whatever() {}
  ]
end
