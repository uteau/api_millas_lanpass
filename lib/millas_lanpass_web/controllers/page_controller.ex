defmodule MillasLanpassWeb.PageController do
  use MillasLanpassWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def login(conn, _params) do
    IO.puts("Carga pagina login")
    render(conn, :login, layout: false)
  end

  def dashboard(conn, _params) do
    usuarios = [
      %{id: 1, nombre: "Bruno", email: "bruno_gmail.com"},
      %{id: 2, nombre: "Jere", email: "jere_gmail.com"}
    ]
    #render(conn, :dashboard, usuarios: usuarios, layout: false)
    json(conn, %{usuarios: usuarios})

  end
end
