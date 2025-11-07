defmodule MillasLanpass.Usuarios.Usuario do
  use Ecto.Schema
  import Ecto.Changeset

  @categorias_validas ["LATAM", "GOLD", "PLATINUM", "BLACK", "BLACK_SIGNATURE"]

  schema "usuarios" do
    field :nombre, :string
    field :email, :string
    field :rut, :string
    field :categoria, :string, default: "LATAM"
    field :puntos_calificables, :integer, default: 0

    # Relación con transacciones
    has_many :transacciones, MillasLanpass.Transacciones.Transaccion

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(usuario, attrs) do
    usuario
    |> cast(attrs, [:nombre, :email, :rut, :categoria, :puntos_calificables])
    |> validate_required([:nombre, :email, :rut, :categoria, :puntos_calificables])
    |> validate_inclusion(:categoria, @categorias_validas)
    |> unique_constraint(:email)
    |> unique_constraint(:rut)
    |> validate_number(:puntos_calificables, greater_than_or_equal_to: 0)
  end

  # Función helper para crear usuario inicial
  def registration_changeset(usuario, atributos) do
    usuario
    |> changeset(atributos)
    |> put_change(:categoria, "LATAM")
    |> put_change(:puntos_calificables, 0)
  end
end
