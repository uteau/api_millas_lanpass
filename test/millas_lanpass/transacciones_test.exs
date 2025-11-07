defmodule MillasLanpass.TransaccionesTest do
  use MillasLanpass.DataCase

  alias MillasLanpass.Transacciones
  alias MillasLanpass.Transacciones.Transaccion
  alias MillasLanpass.Usuarios

  describe "transacciones" do
    setup do
      usuario = usuario_fixture()
      %{usuario: usuario}
    end

    test "list_transacciones/0 returns all transacciones", %{usuario: usuario} do
      transaccion = transaccion_fixture(usuario.id)
      assert Transacciones.list_transacciones() == [transaccion]
    end

    test "get_transaccion!/1 returns the transaccion with given id", %{usuario: usuario} do
      transaccion = transaccion_fixture(usuario.id)
      assert Transacciones.get_transaccion!(transaccion.id) == transaccion
    end

    test "create_transaccion/1 with valid data creates a transaccion", %{usuario: usuario} do
      valid_attrs = %{
        tipo: "ACUMULACION",
        millas: 1000,
        saldo: 1000,
        descripcion: "Test transaction",
        usuario_id: usuario.id
      }

      assert {:ok, %Transaccion{} = transaccion} = Transacciones.create_transaccion(valid_attrs)
      assert transaccion.tipo == "ACUMULACION"
      assert transaccion.millas == 1000
      assert transaccion.saldo == 1000
      assert transaccion.descripcion == "Test transaction"
      assert transaccion.usuario_id == usuario.id
    end

    test "acumular_millas/1 creates accumulation transaction with correct millas", %{usuario: usuario} do
      params = %{
        "usuario_id" => usuario.id,
        "precio" => 1000,
        "impuestos" => 100,
        "tipo_vuelo" => "nacional"
      }

      assert {:ok, transaccion} = Transacciones.acumular_millas(params)
      assert transaccion.tipo == "ACUMULACION"
      assert transaccion.millas == 2700 # (1000-100) * 3 para LATAM nacional
      assert transaccion.saldo == 2700
      assert transaccion.descripcion =~ "Acumulación por vuelo nacional"
    end

    test "acumular_millas/1 calculates different millas for categories and flight types", %{usuario: usuario} do
      # Actualizar usuario a GOLD
      Usuarios.actualizar_puntos_calificables(usuario.id, 15000)
      Usuarios.verificar_actualizar_categoria(usuario.id)

      params = %{
        "usuario_id" => usuario.id,
        "precio" => 1000,
        "impuestos" => 100,
        "tipo_vuelo" => "internacional"
      }

      assert {:ok, transaccion} = Transacciones.acumular_millas(params)
      assert transaccion.millas == 5400 # (1000-100) * 6 para GOLD internacional
    end

    test "canjear_millas/1 creates redemption when sufficient balance", %{usuario: usuario} do
      # Primero acumular millas
      acum_params = %{
        "usuario_id" => usuario.id,
        "precio" => 1000,
        "impuestos" => 100,
        "tipo_vuelo" => "nacional"
      }
      {:ok, _} = Transacciones.acumular_millas(acum_params)

      # Luego canjear
      canje_params = %{
        "usuario_id" => usuario.id,
        "millas" => 1000,
        "descripcion" => "Canje de prueba"
      }

      assert {:ok, transaccion} = Transacciones.canjear_millas(canje_params)
      assert transaccion.tipo == "REDENCION"
      assert transaccion.millas == 1000
      assert transaccion.saldo == 1700 # 2700 - 1000
    end

    test "canjear_millas/1 returns error when insufficient balance", %{usuario: usuario} do
      canje_params = %{
        "usuario_id" => usuario.id,
        "millas" => 1000,
        "descripcion" => "Canje sin saldo"
      }

      assert {:error, "Saldo insuficiente de millas"} = Transacciones.canjear_millas(canje_params)
    end

    test "listar_transacciones_usuario/1 returns user's transactions", %{usuario: usuario} do
      transaccion = transaccion_fixture(usuario.id)
      transactions = Transacciones.listar_transacciones_usuario(usuario.id)

      assert length(transactions) == 1
      assert List.first(transactions).id == transaccion.id
    end

    test "obtener_saldo_actual/1 returns current balance", %{usuario: usuario} do
      assert Transacciones.obtener_saldo_actual(usuario.id) == 0

      transaccion_fixture(usuario.id, %{saldo: 1500})
      assert Transacciones.obtener_saldo_actual(usuario.id) == 1500
    end

    test "obtener_saldo_actual/1 returns 0 for new user", %{usuario: usuario} do
      assert Transacciones.obtener_saldo_actual(usuario.id) == 0
    end

    test "after_insert callback updates puntos calificables on accumulation", %{usuario: usuario} do
      params = %{
        "usuario_id" => usuario.id,
        "precio" => 1000,
        "impuestos" => 100,
        "tipo_vuelo" => "nacional"
      }

      assert {:ok, _transaccion} = Transacciones.acumular_millas(params)

      # Verificar que los puntos calificables se actualizaron
      updated_usuario = Usuarios.get_usuario!(usuario.id)
      assert updated_usuario.puntos_calificables == 900 # precio - impuestos
    end

    test "obtener_multiplicador/2 returns correct multipliers" do
      assert Transacciones.obtener_multiplicador("LATAM", "nacional") == 3
      assert Transacciones.obtener_multiplicador("LATAM", "internacional") == 5
      assert Transacciones.obtener_multiplicador("GOLD", "nacional") == 4
      assert Transacciones.obtener_multiplicador("GOLD", "internacional") == 6
      assert Transacciones.obtener_multiplicador("PLATINUM", "nacional") == 7
      assert Transacciones.obtener_multiplicador("PLATINUM", "internacional") == 9
      assert Transacciones.obtener_multiplicador("BLACK", "nacional") == 8
      assert Transacciones.obtener_multiplicador("BLACK", "internacional") == 10
      assert Transacciones.obtener_multiplicador("BLACK_SIGNATURE", "nacional") == 9
      assert Transacciones.obtener_multiplicador("BLACK_SIGNATURE", "internacional") == 11
      assert Transacciones.obtener_multiplicador("UNKNOWN", "nacional") == 1
    end
  end

  defp usuario_fixture(attrs \\ %{}) do
    {:ok, usuario} =
      attrs
      |> Enum.into(%{
        nombre: "Test User",
        email: "test#{System.unique_integer()}@example.com",
        rut: "test-rut-#{System.unique_integer()}",
        categoria: "LATAM",
        puntos_calificables: 0
      })
      |> Usuarios.create_usuario()

    usuario
  end

  defp transaccion_fixture(usuario_id, attrs \\ %{}) do
    {:ok, transaccion} =
      attrs
      |> Enum.into(%{
        tipo: "ACUMULACION",
        millas: 1000,
        saldo: 1000,
        descripcion: "Test transaction",
        usuario_id: usuario_id
      })
      |> Transacciones.create_transaccion()

    transaccion
  end
end
