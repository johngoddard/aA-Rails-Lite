require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req_cookie = req.cookies['_rails_lite_app']
    @cookie_content = req_cookie ? JSON.parse(req_cookie) : {}
  end

  def [](key)
    @cookie_content[key]
  end

  def []=(key, val)
    @cookie_content[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = {}
    cookie[:value] = @cookie_content.to_json
    cookie[:path] = '/'

    res.set_cookie('_rails_lite_app', cookie)
  end
end
