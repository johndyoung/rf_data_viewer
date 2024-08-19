// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import CanvasJS from "@canvasjs/charts";

let hooks = {};
hooks.InfiniteScroll = {
  loadMore(entries) {
    const target = entries[0];
    if (target.isIntersecting && !this.el.disabled) {
      this.el.click();
    }
  },
  mounted() {
    this.observer = new IntersectionObserver((entries) =>
      this.loadMore(entries)
    );
    this.observer.observe(this.el);
  },
  beforeDestroy() {
    this.observer.unobserve(this.el);
  },
};

hooks.MultiFileUpload = {
  mounted() {
    this.el.addEventListener("input", (e) => {
      e.preventDefault();
      this.upload("dir", e.target.files);
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// TODO: organize resource specific functionality better
// RESOURCE: /rf/units/manage

// ensure RF unit form is opened on detected server event
window.addEventListener("phx:rf-unit-open-modal", (e) => {
  let el = document.getElementById("modal-control");
  liveSocket.execJS(el, el.getAttribute("data-open-modal"));
});

// ensure RF unit form is closed on detected server event
window.addEventListener("phx:rf-unit-close-modal", (e) => {
  let el = document.getElementById("modal-control");
  liveSocket.execJS(el, el.getAttribute("data-close-modal"));
});

// RESOURCE: /rf/data/data_set

window.addEventListener("phx:rf-data-generate-chart", (e) => {
  var chart = new CanvasJS.Chart(e.detail.graph_container_id, {
    animationEnabled: true,
    title: {
      text: e.detail.title,
    },
    axisX: {
      title: "Frequency (MHz)",
      includeZero: true,
    },
    axisY: {
      title: e.detail.y_axis,
      includeZero: true,
    },
    data: [
      {
        type: "line",
        name: "Path RF Characterization",
        connectNullData: true,
        dataPoints: e.detail.data,
      },
    ],
  });
  chart.render();
});
