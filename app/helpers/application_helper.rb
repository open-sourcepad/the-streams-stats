module ApplicationHelper

  def sec_to_hour(seconds)
    hour = seconds/3600
    min = (hour - hour.to_i) * 60
    "#{hour.to_i}:#{min.to_i}"
  end

  def random_quote
    ["Get Better Everyday",
    "Direct with Respect",
	  "Have Fun",
    "Ownership",
    "Create Value",
    "Confident, but Humble",
    "Max out",
    "Be Fair and Empathetic"].sample
  end

end
