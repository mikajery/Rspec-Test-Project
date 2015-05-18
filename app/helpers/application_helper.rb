module ApplicationHelper
  def page_title(page_title = nil)
    base_title = $config.service_name
    
    if page_title.blank?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end
