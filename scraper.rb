module Scraper

  #Homemade string parser
  def snag(data,start_text,end_text=nil)
    begin
      start_count = data.index(start_text) + start_text.size
      if end_text != nil
        end_count = data.index(end_text,start_count) - 1
        return data[start_count..end_count].strip
      else
        return data[start_count..data.size].strip    
      end
    rescue
      return ''
    end
  end
end