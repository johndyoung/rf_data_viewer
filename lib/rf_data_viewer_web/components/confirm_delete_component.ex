defmodule RFDataViewerWeb.ConfirmDeleteComponent do
  use Phoenix.Component
  import RFDataViewerWeb.CoreComponents

  attr :id, :string, required: true
  attr :delete_type, :string, required: true
  attr :delete_data, :string, required: true
  attr :data, :list, required: true
  attr :has_subordinate_data, :string, default: "true"

  def confirm_delete(assigns) do
    ~H"""
    <.modal id={@id}>
      <h1 class="font-bold text-center pb-3">Confirm Delete</h1>

      <dl class="divide-y grid grid-cols-2 justify-center space-x-3">
        <%= for {title, datum} <- @data do %>
          <dt class="font-semibold text-right"><%= title %>:</dt>

          <dd><%= datum %></dd>
        <% end %>
      </dl>

      <p :if={@has_subordinate_data == "true"} class="font-extrabold text-center py-3">
        Any subordinate data will also be deleted.
      </p>

      <div class="grid grid-cols-2">
        <button
          phx-click="confirm_delete"
          phx-value-data={@delete_data}
          class="bg-medium-light text-slate-700 hover:bg-medium rounded-full px-4 py-2 mx-2 font-semibold"
        >
          Delete <%= @delete_type %> Data
        </button>

        <button
          phx-click="cancel_delete"
          class="bg-medium-light text-slate-700 hover:bg-medium rounded-full px-4 py-2 mx-2 font-semibold"
        >
          Cancel
        </button>
      </div>
    </.modal>
    """
  end
end
