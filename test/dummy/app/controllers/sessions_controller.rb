class SessionsController < Zaikio::OAuthClient::SessionsController
  before_action :do_sth

  def do_sth
    puts "HELLO FROM CUSTOM CONTROLLER"
  end
end
