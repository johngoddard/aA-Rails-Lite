class AuthToken

  def initialize(req)
    req_cookie = req.cookies['authenticity_token']
    @cookie_content = req_cookie ? JSON.parse(req_cookie) : {}
  end

  def [](key)
    @cookie_content[key]
  end

  # def []=(key, val)
  #   @cookie_content[key] = val
  # end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_auth_token(res, token)
    cookie = {}
    cookie[:value] = token
    cookie[:path] = '/'

    res.set_cookie('authenticity_token', cookie)
  end
end
