# frozen_string_literal: true

class TestApplication
  def call(env)
    req = Rack::Request.new(env)
    if req.path.start_with?("/status")
      [200, { "Content-Type" => "text/html" }, ["OK"]]
    elsif req.path.start_with?("/protected")
      [200, { "Content-Type" => "text/html" }, ["Protected stuff."]]
    else
      [404, { "Content-Type" => "text/html" }, ["Not found"]]
    end
  end
end
