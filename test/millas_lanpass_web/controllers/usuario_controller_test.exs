defmodule MillasLanpassWeb.UsuarioControllerTest do
  use MillasLanpassWeb.ConnCase

  alias MillasLanpass.Usuarios

  @create_attrs %{
    nombre: "Juan Pérez",
    email: "juan@example.com",
    rut: "12345678-9",
    categoria: "LATAM",
    puntos_calificables: 0
  }
  @update_attrs %{
    nombre: "Juan Actualizado",
    email: "juan.actualizado@example.com"
  }
  @invalid_attrs %{nombre: nil, email: nil, rut: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all usuarios", %{conn: conn} do
      conn = get(conn, ~p"/api/usuarios")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create usuario" do
    test "renders usuario when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/usuarios", usuario: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/usuarios/#{id}")
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/usuarios", usuario: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show usuario" do
    setup [:create_usuario]

    test "renders usuario", %{conn: conn, usuario: usuario} do
      conn = get(conn, ~p"/api/usuarios/#{usuario.id}")
      data = json_response(conn, 200)["data"]

      assert data["id"] == usuario.id
      assert data["nombre"] == usuario.nombre
      assert data["email"] == usuario.email
    end

    test "returns 404 when usuario does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, ~p"/api/usuarios/999999")
      end
    end
  end

  describe "estado usuario" do
    setup [:create_usuario]

    test "returns usuario status with millas balance", %{conn: conn, usuario: usuario} do
      conn = get(conn, ~p"/api/usuarios/#{usuario.id}/estado")
      response = json_response(conn, 200)

      assert response["usuario"]["id"] == usuario.id
      assert response["usuario"]["nombre"] == usuario.nombre
      assert response["millas"]["saldo_actual"] == 0
    end
  end

  describe "update usuario" do
    setup [:create_usuario]

    test "renders usuario when data is valid", %{conn: conn, usuario: usuario} do
      conn = put(conn, ~p"/api/usuarios/#{usuario}", usuario: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/usuarios/#{id}")
      assert %{"id" => ^id, "nombre" => "Juan Actualizado"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, usuario: usuario} do
      conn = put(conn, ~p"/api/usuarios/#{usuario}", usuario: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete usuario" do
    setup [:create_usuario]

    test "deletes chosen usuario", %{conn: conn, usuario: usuario} do
      conn = delete(conn, ~p"/api/usuarios/#{usuario}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/usuarios/#{usuario}")
      end
    end
  end

  defp create_usuario(_) do
    usuario = fixture(:usuario)
    %{usuario: usuario}
  end

  defp fixture(:usuario) do
    {:ok, usuario} = Usuarios.create_usuario(@create_attrs)
    usuario
  end
end
