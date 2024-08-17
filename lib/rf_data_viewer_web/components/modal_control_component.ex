defmodule RFDataViewerWeb.ModalControlComponent do
  use Phoenix.Component
  alias Phoenix.LiveView
  alias RFDataViewerWeb.CoreComponents

  attr :modal_id, :string, required: true

  def modal_control(assigns) do
    ~H"""
    <div
      id="modal-control"
      class="hidden"
      data-open-modal={CoreComponents.show_modal(@modal_id)}
      data-close-modal={CoreComponents.hide_modal(@modal_id)}
    />
    """
  end

  def assign_modal_id(socket, modal_id), do: assign(socket, :modal_id, modal_id)

  def push_open_modal(socket, modal_id),
    do:
      socket
      |> assign_modal_id(modal_id)
      |> LiveView.push_event("rf-unit-open-modal", Map.new())

  def push_close_modal(socket, modal_id),
    do:
      socket
      |> assign_modal_id(modal_id)
      |> LiveView.push_event("rf-unit-close-modal", Map.new())
end
