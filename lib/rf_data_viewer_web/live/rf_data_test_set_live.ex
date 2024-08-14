defmodule RFDataViewerWeb.RFDataTestSetLive do
  use RFDataViewerWeb, :live_view

  def mount(%{"test_set_id" => ts_id} = _params, _session, socket) do
    {ts, ds_count, data_count} = RFDataViewer.RFData.get_rf_test_set_with_count!(ts_id)

    ds = RFDataViewer.RFData.get_rf_data_sets_with_counts(ts.id)

    {:ok,
     assign(socket, %{
       test_set: ts,
       data_set_count: ds_count,
       data_count: data_count,
       data_sets: ds
     })}
  end
end
