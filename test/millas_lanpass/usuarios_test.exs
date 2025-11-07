defmodule MillasLanpass.UsuariosTest do
  use MillasLanpass.DataCase

  alias MillasLanpass.Usuarios
  alias MillasLanpass.Usuarios.Usuario

  describe "usuarios" do
    @valid_attrs %{
      nombre: "Juan Pérez",
      email: "juan@example.com",
      rut: "12345678-9",
      categoria: "LATAM",
      puntos_calificables: 0
    }
    @invalid_attrs %{nombre: nil, email: nil, rut: nil}

    test "list_usuarios/0 returns all usuarios" do
      usuario = usuario_fixture()
      assert Usuarios.list_usuarios() == [usuario]
    end

    test "get_usuario!/1 returns the usuario with given id" do
      usuario = usuario_fixture()
      assert Usuarios.get_usuario!(usuario.id) == usuario
    end

    test "create_usuario/1 with valid data creates a usuario" do
      assert {:ok, %Usuario{} = usuario} = Usuarios.create_usuario(@valid_attrs)
      assert usuario.nombre == "Juan Pérez"
      assert usuario.email == "juan@example.com"
      assert usuario.rut == "12345678-9"
      assert usuario.categoria == "LATAM"
      assert usuario.puntos_calificables == 0
    end

    test "create_usuario/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Usuarios.create_usuario(@invalid_attrs)
    end

    test "obtener_usuario_por_email/1 returns usuario by email" do
      usuario = usuario_fixture()
      assert Usuarios.obtener_usuario_por_email("juan@example.com") == usuario
      assert Usuarios.obtener_usuario_por_email("nonexistent@example.com") == nil
    end

    test "actualizar_puntos_calificables/2 updates puntos calificables" do
      usuario = usuario_fixture()
      assert {:ok, updated_usuario} = Usuarios.actualizar_puntos_calificables(usuario.id, 5000)
      assert updated_usuario.puntos_calificables == 5000
    end

    test "verificar_actualizar_categoria/1 upgrades categoria when puntos reach threshold" do
      usuario = usuario_fixture(%{puntos_calificables: 12000, categoria: "LATAM"})
      assert {:ok, updated_usuario} = Usuarios.verificar_actualizar_categoria(usuario.id)
      assert updated_usuario.categoria == "GOLD"
    end

    test "verificar_actualizar_categoria/1 maintains categoria when puntos below threshold" do
      usuario = usuario_fixture(%{puntos_calificables: 5000, categoria: "LATAM"})
      assert {:ok, updated_usuario} = Usuarios.verificar_actualizar_categoria(usuario.id)
      assert updated_usuario.categoria == "LATAM"
    end

    test "calcular_categoria/1 returns correct categoria for puntos" do
      # Test de la función privada a través de verificar_actualizar_categoria
      usuario1 = usuario_fixture(%{puntos_calificables: 5000})
      {:ok, usuario1} = Usuarios.verificar_actualizar_categoria(usuario1.id)
      assert usuario1.categoria == "LATAM"

      usuario2 = usuario_fixture(%{puntos_calificables: 15000})
      {:ok, usuario2} = Usuarios.verificar_actualizar_categoria(usuario2.id)
      assert usuario2.categoria == "GOLD"

      usuario3 = usuario_fixture(%{puntos_calificables: 40000})
      {:ok, usuario3} = Usuarios.verificar_actualizar_categoria(usuario3.id)
      assert usuario3.categoria == "PLATINUM"

      usuario4 = usuario_fixture(%{puntos_calificables: 110000})
      {:ok, usuario4} = Usuarios.verificar_actualizar_categoria(usuario4.id)
      assert usuario4.categoria == "BLACK"

      usuario5 = usuario_fixture(%{puntos_calificables: 250000})
      {:ok, usuario5} = Usuarios.verificar_actualizar_categoria(usuario5.id)
      assert usuario5.categoria == "BLACK_SIGNATURE"
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
end
