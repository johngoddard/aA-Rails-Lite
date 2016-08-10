class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name
  AUTH_TOKEN = SecureRandom.urlsafe_base64(16)

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    req.request_method == @http_method.to_s.upcase && @pattern =~ req.path
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    route_params = parse_route_params(req)
    controller = @controller_class.new(req, res, route_params)
    controller.invoke_action(@action_name)
  end

  private

  def parse_route_params(req)
    route_params = {}
    match_data = @pattern.match(req.path)
    match_data.names.each { |key| route_params[key] = match_data[key] }

    route_params
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    @routes.each { |route| return route if route.matches?(req) }
    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route = match(req)

    if route
      route.run(req, res)
    else
      res.status = 404
      res.write("The resource you requested could not be found")
    end
  end

end
