defmodule MillasLanpassWeb.PageController do
  use MillasLanpassWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
