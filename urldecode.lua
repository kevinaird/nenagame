local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
  end
  
  local urldecode = function(url)
    if url == nil then
      return
    end
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", hex_to_char)
    return url
  end

  return urldecode