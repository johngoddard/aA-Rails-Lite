require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
# require_relative './auth_token'
require 'byebug'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params
  AUTH_TOKEN = "NMKSreatjftG_acXQ4xRDQ"
  # Setup the controller
  def initialize(req, res, route_params = {})
    @res = res
    @req = req
    @params = req.params.merge(route_params)
    @params["authenticity_token"]= AUTH_TOKEN;
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    unless already_built_response?
      @res.set_header('Location', url)
      @res.status = 302
      @already_built_response = true
      session.store_session(@res)
      flash.store_flash(@res)
    else
      raise "Cannot render or redirect twice"
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    unless already_built_response?
      @res['Content-Type'] = content_type
      @res.write(content)
      @already_built_response = true
      session.store_session(@res)
      flash.store_flash(@res)
    else
      raise "Cannot render or redirect twice"
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    path = "views/#{controller_name}/#{template_name}.html.erb"
    binded_template = create_binded_template(path)

    render_content(binded_template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def auth_token
    @auth_token ||= AuthToken.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
    render(name.to_sym) unless @already_built_response
  end

  def form_authenticity_token
    cookie = {}
    cookie[:value] = @params["authenticity_token"]
    cookie[:path] = '/'
    @res.set_cookie('authenticity_token', cookie)
    @params["authenticity_token"]
  end

  def check_authenticity_token
    auth_token = @req.cookies['authenticity_token']
    raise "Invalid authenticity token" unless auth_token && auth_token == @params["authenticity_token"]
  end

  def self.protect_from_forgery
    define_method(:invoke_action) do |name|
      if @req.request_method.upcase != 'GET'
        check_authenticity_token
      end

      self.send(name.to_sym)
      render(name.to_sym) unless @already_built_response
    end
  end

  private

  def create_binded_template(path)
    template = ERB.new(File.read(path))
    template.result(binding)
  end
end
