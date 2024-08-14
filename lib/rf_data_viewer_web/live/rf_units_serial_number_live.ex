defmodule RFDataViewerWeb.RFUnitsSerialNumberLive do
  alias RFDataViewer.Repo
  use RFDataViewerWeb, :live_view

  def mount(%{"sn_id" => sn_id} = _params, _session, socket) do
    sn =
      RFDataViewer.RFUnits.get_rf_unit_serial_number!(sn_id)
      |> Repo.preload(:unit)

    test_sets = RFDataViewer.RFData.get_test_sets_with_counts(sn.id)

    {:ok, assign(socket, %{sn: sn, test_sets: test_sets})}
  end
end
