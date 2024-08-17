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
    # {_, [entry | _]} = uploaded_entries(socket, :gain_upload)

    # file_name = entry.client_name
    {:noreply, socket}
  end

  # liveview upload example...
  #   <div class="p-5" phx-drop-target={@uploads.gain_upload.ref}>
  #   <%!-- upload form --%>
  #   <form id="gain-upload-form" phx-submit="save" phx-change="validate">
  #     <.live_file_input upload={@uploads.gain_upload} />
  #     <button type="submit">Upload Gain Data</button>
  #   </form>
  #    <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
  #   <section>
  #     <%!-- render each gain file entry --%>
  #     <%= for entry <- @uploads.gain_upload.entries do %>
  #       <article class="upload-entry">
  #         <figure>
  #           <.live_img_preview entry={entry} />
  #           <figcaption><%= entry.client_name %></figcaption>
  #         </figure>
  #          <%!-- entry.progress will update automatically for in-flight entries --%>
  #         <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>
  #         <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
  #         <button
  #           type="button"
  #           phx-click="cancel_upload"
  #           phx-value-ref={entry.ref}
  #           aria-label="cancel"
  #         >
  #           &times;
  #         </button>
  #          <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
  #         <%= for err <- upload_errors(@uploads.gain_upload, entry) do %>
  #           <p class="alert alert-danger"><%= error_to_string(err) %></p>
  #         <% end %>
  #       </article>
  #     <% end %>
  #      <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
  #     <%= for err <- upload_errors(@uploads.gain_upload) do %>
  #       <p class="alert alert-danger"><%= error_to_string(err) %></p>
  #     <% end %>
  #   </section>
  # </div>
end
