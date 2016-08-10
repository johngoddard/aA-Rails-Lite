require 'erb'
require 'byebug'

class ShowExceptions
  CODE_PREVIEW_SIZE = 10

  def initialize(app)
    @app = app
    @error = nil
    @code_preview = nil
  end

  def call(env)
    res = Rack::Response.new

    begin
      @app.call(env)
    rescue Exception => @error
      res['Content-Type'] = 'text/html'
      res.write(render_exception(@error))
      res.finish
      # render_exception(e)
    end
  end

  private

  def render_exception(e)
    path = File.dirname(__FILE__) + '/templates/rescue.html.erb'
    template = ERB.new(File.read(path))
    preview_code(e)
    template.result(binding)
  end

  def preview_code(e)
    top_line = e.backtrace.first
    match_data = /(?<file_path>(.+\/)+.+\.rb):(?<line_num>\d+)/.match(top_line)

    full_path = File.expand_path(__FILE__).split("/")[0..-3]
    full_path += match_data[:file_path].split("/")
    full_path = full_path.join("/")

    code = File.new(full_path).readlines

    problem_line = match_data[:line_num].to_i
    first_line = problem_line - CODE_PREVIEW_SIZE >= 0 ? problem_line - CODE_PREVIEW_SIZE : 0
    last_line = problem_line + CODE_PREVIEW_SIZE > code.size  ? code.size - 1 : problem_line + CODE_PREVIEW_SIZE

    @code_preview = code[first_line..last_line]
  end
end
