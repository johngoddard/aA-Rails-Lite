require 'json'

class Flash

  attr_reader :now

  def initialize(req)
    initialize_now(req)
    @persisting_content = {}
  end

  def [](key)
    @now[key.to_s]
  end

  def []=(key, val)
    @now[key.to_s] = val
    @persisting_content[key.to_s] = val
  end

  def store_flash(res)
    cookie = {}
    cookie[:value] = @persisting_content.to_json
    cookie[:path] = '/'

    res.set_cookie('_rails_lite_app_flash', cookie)
  end

  private

  def initialize_now(req)
    @now = {}
    req_cookie = req.cookies['_rails_lite_app_flash']
    JSON.parse(req_cookie).each { |k, v| @now[k.to_s] = v } if req_cookie
  end
end
