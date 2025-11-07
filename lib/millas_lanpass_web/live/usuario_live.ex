defmodule MillasLanpassWeb.UsuarioLive do
  use MillasLanpassWeb, :live_view

  alias MillasLanpass.Usuarios
  alias MillasLanpass.Transacciones
  alias MillasLanpass.Transacciones.Transaccion

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_form(Transacciones.change_transaccion(%Transaccion{}), :acumulacion)
     |> assign_form(Transacciones.change_transaccion(%Transaccion{}), :redencion)
     |> assign(:show_acumular_modal, false)
     |> assign(:show_canjear_modal, false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    usuario = Usuarios.get_usuario!(id)
    saldo_actual = Transacciones.obtener_saldo_actual(id)
    transacciones = Transacciones.listar_transacciones_usuario(id)

    {:noreply,
     socket
     |> assign(:usuario, usuario)
     |> assign(:saldo_actual, saldo_actual)
     |> assign(:transacciones, transacciones)
     |> assign(:page_title, "Usuario: #{usuario.nombre}")}
  end

  # 1.1 Manejar apertura/cierre de modales
  @impl true
  def handle_event("show_acumular_modal", _, socket) do
    {:noreply, socket |> assign(:show_acumular_modal, true)}
  end

  def handle_event("hide_acumular_modal", _, socket) do
    {:noreply, socket |> assign(:show_acumular_modal, false)}
  end

  def handle_event("show_canjear_modal", _, socket) do
    {:noreply, socket |> assign(:show_canjear_modal, true)}
  end

  def handle_event("hide_canjear_modal", _, socket) do
    {:noreply, socket |> assign(:show_canjear_modal, false)}
  end

  # 1.2 Manejar envío del formulario de acumulación
  def handle_event("acumular_millas", %{"transaccion" => params}, socket) do
    usuario_id = socket.assigns.usuario.id
    params_with_user = Map.put(params, "usuario_id", Integer.to_string(usuario_id))

    case Transacciones.acumular_millas(params_with_user) do
      {:ok, _transaccion} ->
        # Actualizar datos después de la transacción exitosa
        saldo_actual = Transacciones.obtener_saldo_actual(usuario_id)
        transacciones = Transacciones.listar_transacciones_usuario(usuario_id)

        {:noreply,
         socket
         |> assign(:saldo_actual, saldo_actual)
         |> assign(:transacciones, transacciones)
         |> assign(:show_acumular_modal, false)
         |> assign_form(Transacciones.change_transaccion(%Transaccion{}), :acumulacion)
         |> put_flash(:info, "Millas acumuladas exitosamente!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign_form(changeset, :acumulacion)}

      {:error, reason} ->
        {:noreply, socket |> put_flash(:error, reason)}
    end
  end

  # 1.3 Manejar envío del formulario de redención
  def handle_event("canjear_millas", %{"transaccion" => params}, socket) do
    usuario_id = socket.assigns.usuario.id
    params_with_user = Map.put(params, "usuario_id", Integer.to_string(usuario_id))

    case Transacciones.canjear_millas(params_with_user) do
      {:ok, _transaccion} ->
        # Actualizar datos después de la transacción exitosa
        saldo_actual = Transacciones.obtener_saldo_actual(usuario_id)
        transacciones = Transacciones.listar_transacciones_usuario(usuario_id)

        {:noreply,
          socket
          |> assign(:saldo_actual, saldo_actual)
          |> assign(:transacciones, transacciones)
          |> assign(:show_canjear_modal, false)
          |> assign_form(Transacciones.change_transaccion(%Transaccion{}), :redencion)
          |> put_flash(:info, "Millas canjeadas exitosamente!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign_form(changeset, :redencion)}

      {:error, reason} ->
        {:noreply, socket
          |> assign(:show_canjear_modal, false)
          |> put_flash(:error, reason)}
    end
  end

  # Helper para asignar forms
  defp assign_form(socket, %Ecto.Changeset{} = changeset, :acumulacion) do
    assign(socket, :acumulacion_form, to_form(changeset))
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset, :redencion) do
    assign(socket, :redencion_form, to_form(changeset))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <!-- Flash messages -->
      <%= if Phoenix.Flash.get(@flash, :info) do %>
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
          <%= Phoenix.Flash.get(@flash, :info) %>
        </div>
      <% end %>

      <%= if Phoenix.Flash.get(@flash, :error) do %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          <%= Phoenix.Flash.get(@flash, :error) %>
        </div>
      <% end %>

      <!-- Header -->
      <div class="bg-white shadow rounded-lg p-6 mb-6">
        <div class="flex justify-between items-center">
          <h1 class="text-2xl font-bold text-gray-900">Perfil de Usuario</h1>
          <div class="flex space-x-3">
            <!-- Botón Acumular Millas -->
            <button
              phx-click="show_acumular_modal"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium"
            >
              Acumular Millas
            </button>

            <!-- Botón Canjear Millas -->
            <button
              phx-click="show_canjear_modal"
              class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg font-medium"
            >
              Canjear Millas
            </button>
          </div>
        </div>
      </div>

      <!-- Información del Usuario -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
        <!-- Datos Personales -->
        <div class="bg-white shadow rounded-lg p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">Datos Personales</h2>
          <div class="space-y-3">
            <div>
              <label class="text-sm font-medium text-gray-500">Nombre</label>
              <p class="text-gray-900"><%= @usuario.nombre %></p>
            </div>
            <div>
              <label class="text-sm font-medium text-gray-500">Email</label>
              <p class="text-gray-900"><%= @usuario.email %></p>
            </div>
            <div>
              <label class="text-sm font-medium text-gray-500">RUT</label>
              <p class="text-gray-900"><%= @usuario.rut %></p>
            </div>
            <div>
              <label class="text-sm font-medium text-gray-500">Categoría</label>
              <span class={categoria_badge_class(@usuario.categoria)}>
                <%= @usuario.categoria %>
              </span>
            </div>
          </div>
        </div>

        <!-- Información de Millas -->
        <div class="bg-white shadow rounded-lg p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">Información de Millas</h2>
          <div class="space-y-4">
            <div class="text-center">
              <label class="text-sm font-medium text-gray-500">Saldo Actual</label>
              <p class="text-3xl font-bold text-blue-600"><%= @saldo_actual %></p>
              <p class="text-sm text-gray-500">millas disponibles</p>
            </div>
            <div>
              <label class="text-sm font-medium text-gray-500">Puntos Calificables</label>
              <p class="text-xl font-semibold text-gray-900"><%= @usuario.puntos_calificables %></p>
            </div>
          </div>
        </div>
      </div>

      <!-- Historial de Transacciones -->
      <div class="bg-white shadow rounded-lg p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-4">Historial de Transacciones</h2>
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tipo</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Millas</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Saldo</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Descripción</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for transaccion <- @transacciones do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <%= transaccion.inserted_at %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class={tipo_badge_class(transaccion.tipo)}>
                      <%= transaccion.tipo %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <%= if transaccion.millas > 0 do %>
                      <span class="text-green-600 font-medium">+<%= transaccion.millas %></span>
                    <% else %>
                      <span class="text-red-600 font-medium"><%= transaccion.millas %></span>
                    <% end %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <%= transaccion.saldo %>
                  </td>
                  <td class="px-6 py-4 text-sm text-gray-900">
                    <%= transaccion.descripcion %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
          <%= if Enum.empty?(@transacciones) do %>
            <div class="text-center py-8 text-gray-500">
              No hay transacciones registradas
            </div>
          <% end %>
        </div>
      </div>

      <!-- Modal Acumular Millas -->
      <.modal :if={@show_acumular_modal}>
        <h2 class="text-xl font-bold mb-4">Acumular Millas</h2>

        <.form
          :let={f}
          for={@acumulacion_form}
          phx-submit="acumular_millas"
          class="space-y-4"
        >
          <!-- Precio -->
          <div>
            <.input
              field={f[:precio]}
              type="number"
              label="Precio del Vuelo (USD)"
              required
            />
          </div>

          <!-- Impuestos -->
          <div>
            <.input
              field={f[:impuestos]}
              type="number"
              label="Impuestos (USD)"
              required
            />
          </div>

          <!-- Tipo de Vuelo -->
          <div>
            <.input
              field={f[:tipo_vuelo]}
              type="select"
              label="Tipo de Vuelo"
              options={[Nacional: "nacional", Internacional: "internacional"]}
              required
            />
          </div>

          <!-- Tipo de Clase -->
          <div>
            <.input
              field={f[:tipo_clase]}
              type="select"
              label="Clase"
              options={[
                Basic: "basic",
                Light: "basic",
                Standard: "basic",
                Full: "full",
                "Premium Economy": "full",
                "Premium Business": "full"
              ]}
            />
          </div>

          <!-- Botones -->
          <div class="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              phx-click="hide_acumular_modal"
              class="px-4 py-2 text-gray-600 hover:text-gray-800"
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg"
            >
              Acumular Millas
            </button>
          </div>
        </.form>
      </.modal>

      <!-- Modal Canjear Millas -->
      <.modal :if={@show_canjear_modal}>
        <h2 class="text-xl font-bold mb-4">Canjear Millas</h2>

        <.form
          :let={f}
          for={@redencion_form}
          phx-submit="canjear_millas"
          class="space-y-4"
        >
          <!-- Millas a Canjear -->
          <div>
            <.input
              field={f[:millas]}
              type="number"
              label="Millas a Canjear"
              required
            />
            <p class="text-sm text-gray-500 mt-1">
              Saldo disponible: <span class="font-semibold"><%= @saldo_actual %></span> millas
            </p>
          </div>

          <!-- Descripción -->
          <div>
            <.input
              field={f[:descripcion]}
              type="text"
              label="Descripción del Canje"
              required
            />
          </div>

          <!-- Botones -->
          <div class="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              phx-click="hide_canjear_modal"
              class="px-4 py-2 text-gray-600 hover:text-gray-800"
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg"
            >
              Canjear Millas
            </button>
          </div>
        </.form>
      </.modal>
    </div>
    """
  end

  defp categoria_badge_class(categoria) do
    base_classes = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"

    case categoria do
      "LATAM" -> "#{base_classes} bg-blue-100 text-blue-800"
      "GOLD" -> "#{base_classes} bg-yellow-100 text-yellow-800"
      "PLATINUM" -> "#{base_classes} bg-gray-100 text-gray-800"
      "BLACK" -> "#{base_classes} bg-black text-white"
      "BLACK_SIGNATURE" -> "#{base_classes} bg-purple-100 text-purple-800"
      _ -> "#{base_classes} bg-gray-100 text-gray-800"
    end
  end

  defp tipo_badge_class(tipo) do
    base_classes = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"

    case tipo do
      "ACUMULACION" -> "#{base_classes} bg-green-100 text-green-800"
      "REDENCION" -> "#{base_classes} bg-red-100 text-red-800"
      _ -> "#{base_classes} bg-gray-100 text-gray-800"
    end
  end
end
