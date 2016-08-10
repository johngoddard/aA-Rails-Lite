require 'byebug'
require 'pathname'

class Static
  MIME_MAP = {
    '.txt' => 'text/plain',
    '.json' => 'application/json',
    '.zip' => 'application/zip',
    '.jpg' => 'image/jpg',
    '.jpeg' => 'image/jpg',
    '.png' => 'image/png',
    '.gif' => 'impage/gif',
    '.html' => 'text/html',
    '.erb' => 'text/html'
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    path = '/lib' + env['PATH_INFO']

    if /^\/lib\/public\/.+/ =~ path
      res = Rack::Response.new

      content_type = file_type(path)
      res['Content-Type'] = content_type

      root_dir = File.dirname(__FILE__)[0..-5]
      full_path = Pathname.new(root_dir + path)

      if full_path.exist?
        res.status = 200
        res.write(File.read(full_path))
      else
        res.status = 404
      end

      res.finish
    else
      @app.call(env)
    end
  end

  private

  def file_type(path)
    content_type = nil
    extension = /(\..+)$/.match(path)[0]
    MIME_MAP.each{|k, v| content_type = v if extension == k}
    # debugger
    raise "Not a valid file type" unless content_type
    content_type
  end
end
