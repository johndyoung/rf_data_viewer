defmodule RFDataViewerWeb.RFDataUploadLive do
  use RFDataViewerWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:upload_files, [])
     |> allow_upload(:test_data, accept: ~w(.csv))}
  end

  def render(assigns) do
    ~H"""
    <form id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.test_data} /> <button type="submit">Upload</button>
    </form>
    """
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

end
