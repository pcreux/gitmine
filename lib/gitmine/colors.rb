module Gitmine::Colors
  # Display the command, run it and raise if it fails.
  def run_cmd(cmd)
    puts blue(cmd)
    raise unless system cmd
  end

  # ### COLORS ###
  # Display colored text in console
  def color(text, color_code)
    "#{color_code}#{text}\e[0m"
  end 

  def bold(text)
    color(text, "\e[1m")
  end 

  def white(text)
    color(text, "\e[37m")
  end 

  def green(text)
    color(text, "\e[32m")
  end 

  def red(text)
    color(text, "\e[31m")
  end 

  def magenta(text)
    color(text, "\e[35m")
  end 

  def yellow(text)
    color(text, "\e[33m")
  end 

  def blue(text)
    color(text, "\e[34m")
  end 

  def grey(text)
    color(text, "\e[90m")
  end 
end
