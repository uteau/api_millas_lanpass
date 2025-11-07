defmodule MillasLanpassWeb.TransaccionControllerTest do
  use MillasLanpassWeb.ConnCase

  import MillasLanpass.TransaccionesFixtures
  alias MillasLanpass.Transacciones.Transaccion

  @create_attrs %{
    tipo: "some tipo",
    millas: 42,
    saldo: 42,
    descripcion: "some descripcion",
    precio: 42,
    impuestos: 42,
    tipo_vuelo: "some tipo_vuelo",
    tipo_clase: "some tipo_clase"
  }
  @update_attrs %{
    tipo: "some updated tipo",
    millas: 43,
    saldo: 43,
    descripcion: "some updated descripcion",
    precio: 43,
    impuestos: 43,
    tipo_vuelo: "some updated tipo_vuelo",
    tipo_clase: "some updated tipo_clase"
  }
  @invalid_attrs %{tipo: nil, millas: nil, saldo: nil, descripcion: nil, precio: nil, impuestos: nil, tipo_vuelo: nil, tipo_clase: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all transacciones", %{conn: conn} do
      conn = get(conn, ~p"/api/transacciones")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create transaccion" do
    test "renders transaccion when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/transacciones", transaccion: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/transacciones/#{id}")

      assert %{
               "id" => ^id,
               "descripcion" => "some descripcion",
               "impuestos" => 42,
               "millas" => 42,
               "precio" => 42,
               "saldo" => 42,
               "tipo" => "some tipo",
               "tipo_clase" => "some tipo_clase",
               "tipo_vuelo" => "some tipo_vuelo"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/transacciones", transaccion: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update transaccion" do
    setup [:create_transaccion]

    test "renders transaccion when data is valid", %{conn: conn, transaccion: %Transaccion{id: id} = transaccion} do
      conn = put(conn, ~p"/api/transacciones/#{transaccion}", transaccion: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/transacciones/#{id}")

      assert %{
               "id" => ^id,
               "descripcion" => "some updated descripcion",
               "impuestos" => 43,
               "millas" => 43,
               "precio" => 43,
               "saldo" => 43,
               "tipo" => "some updated tipo",
               "tipo_clase" => "some updated tipo_clase",
               "tipo_vuelo" => "some updated tipo_vuelo"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, transaccion: transaccion} do
      conn = put(conn, ~p"/api/transacciones/#{transaccion}", transaccion: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete transaccion" do
    setup [:create_transaccion]

    test "deletes chosen transaccion", %{conn: conn, transaccion: transaccion} do
      conn = delete(conn, ~p"/api/transacciones/#{transaccion}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/transacciones/#{transaccion}")
      end
    end
  end

  defp create_transaccion(_) do
    transaccion = transaccion_fixture()

    %{transaccion: transaccion}
  end
end
