module AppHelpers

  def symbolize(hash)
    Hash[hash.map{|(k,v)| [k.to_sym,v]}]
  end

  def json_route
    response['Content-Type'] = 'application/json'
  end

  def params
    symbolize request.params
  end
  
end
