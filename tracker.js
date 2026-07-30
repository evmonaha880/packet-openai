/* ============================================================
   Packet analytics — GoatCounter (no cookies, no PII).
   Async, fail-safe: if this file or GoatCounter is blocked,
   the site renders and every link works, unaffected.
   To activate: replace __GC_CODE__ with the GoatCounter site
   code (e.g. "evanmonahan"). Until then this is a silent no-op.
   ============================================================ */
(function () {
  "use strict";
  var CODE = "evanmonahan";
  if (/^__GC/.test(CODE)) return; // not configured yet — do nothing

  try {
    // 1. Load the GoatCounter counter (auto-counts a pageview on load).
    window.goatcounter = window.goatcounter || {};
    var s = document.createElement("script");
    s.async = true;
    s.src = "//gc.zgo.at/count.js";
    s.setAttribute("data-goatcounter", "https://" + CODE + ".goatcounter.com/count");
    (document.head || document.documentElement).appendChild(s);

    var fire = function (path, title) {
      if (window.goatcounter && typeof window.goatcounter.count === "function") {
        window.goatcounter.count({ path: path, title: title, event: true });
      }
    };

    // 2. Which of the packet items got clicked (PDF opens + outbound links).
    document.addEventListener("click", function (e) {
      var a = e.target.closest ? e.target.closest("a.doc[data-doc]") : null;
      if (!a) return;
      var id = a.getAttribute("data-doc");
      fire("click-" + id, "Click: " + id);
    }, true);

    // 3. Read-to-end signal on long pages (thesis .sources, hub .colophon).
    var end = document.querySelector(".sources, .colophon");
    if (end && "IntersectionObserver" in window) {
      var done = false;
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (en) {
          if (en.isIntersecting && !done) {
            done = true;
            var page = (location.pathname.split("/").pop() || "index").replace(".html", "") || "index";
            fire("read-" + page, "Read to end: " + page);
            io.disconnect();
          }
        });
      });
      io.observe(end);
    }
  } catch (err) { /* silent — analytics must never break the page */ }
})();
