require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @res = res
    @req = req
    @params = req.params
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
    else
      raise "Cannot render or redirect twice"
    end
  end


  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    path = "views/#{controller_name}/#{template_name}.html.erb"

    template_file = File.read(path)
    debugger
    template = ERB.new(template_file)

    result = template.result(binding)

    render_content(result, 'text/html')
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
