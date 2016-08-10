require 'erb'

class ShowExceptions
  CODE_PREVIEW_SIZE = 10

  attr_reader :app

  def initialize(app)
    @app = app
    @error = nil
    @code_preview = nil
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => @error
      res = Rack::Response.new
      res.status = 500
      res['Content-Type'] = 'text/html'
      res.write(render_exception(@error))
      res.finish
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
    code_file_info = find_file(e)
    code = File.new(code_file_info[:file_path]).readlines

    prev_options = surrounding_code(code, code_file_info[:problem_line])

    @code_preview = {
      code: code[prev_options[:first_line]..prev_options[:end_line]],
      problem_line: prev_options[:problem_line],
      first_line:  prev_options[:first_line]
    }
  end

  def find_file(e)
    top_line = e.backtrace.first
    match_data = /(?<file_path>(.+\/)+.+\.rb):(?<line_num>\d+)/.match(top_line)

    { file_path: match_data[:file_path], problem_line: match_data[:line_num].to_i }
  end

  def surrounding_code(code, line_num)
    preview_options = { problem_line: line_num }

    if line_num - CODE_PREVIEW_SIZE >= 0
      preview_options[:first_line] = line_num - CODE_PREVIEW_SIZE
    else
      preview_options[:first_line] = 0
    end

    if line_num + CODE_PREVIEW_SIZE > code.size
      preview_options[:end_line] = code.size - 1
    else
      preview_options[:end_line] = line_num + CODE_PREVIEW_SIZE
    end

    preview_options
  end
end
