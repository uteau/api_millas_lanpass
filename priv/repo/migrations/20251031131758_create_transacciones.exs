defmodule MillasLanpass.Repo.Migrations.CreateTransacciones do
  use Ecto.Migration

  def change do
    create table(:transacciones) do
      add :usuario_id, references(:usuarios, on_delete: :delete_all)
      add :tipo, :string, null: false
      add :millas, :integer, null: false
      add :saldo, :integer, null: false
      add :descripcion, :string, null: false
      add :precio, :integer
      add :impuestos, :integer
      add :tipo_vuelo, :string
      add :tipo_clase, :string

      timestamps(type: :utc_datetime)
    end

    create index(:transacciones, [:usuario_id])
    create index(:transacciones, [:tipo])
  end
end
