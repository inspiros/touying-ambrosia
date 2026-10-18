// A small Typst grammar for mdBook's bundled highlight.js. Copy buttons remain
// mdBook's native controls, so copied content is the original plain source.
(() => {
  function highlightTypst() {
    if (!window.hljs) return;
    if (!hljs.getLanguage("typst")) {
      hljs.registerLanguage("typst", () => ({
        name: "Typst",
        contains: [
          { className: "comment", begin: /\/\//, end: /$/ },
          { className: "comment", begin: /\/\*/, end: /\*\// },
          { className: "string", begin: /"/, end: /"/, contains: [{ begin: /\\./ }] },
          { className: "keyword", begin: /#(?:import|include|let|set|show|if|else|for|while|return|context)\b/ },
          { className: "title", begin: /#?[a-zA-Z_][a-zA-Z0-9_-]*(?=\s*\()/ },
          { className: "attr", begin: /\b[a-zA-Z_][a-zA-Z0-9_-]*(?=\s*:)/ },
          { className: "literal", begin: /\b(?:true|false|auto|none)\b/ },
          { className: "number", begin: /\b\d+(?:\.\d+)?(?:pt|em|cm|mm|deg|%)?/ },
          { className: "symbol", begin: /@[a-zA-Z0-9_-]+|<[a-zA-Z0-9_-]+>/ },
        ],
      }));
    }
    document.querySelectorAll("code.ambrosia-typst").forEach(code => {
      code.classList.remove("nohighlight");
      code.classList.add("language-typst");
      delete code.dataset.highlighted;
      if (hljs.highlightElement) hljs.highlightElement(code);
      else hljs.highlightBlock(code);
    });
  }
  function brandSidebar() {
    const sidebar = document.querySelector(".sidebar-scrollbox");
    if (!sidebar) return;
    const brand = document.createElement("a");
    brand.className = "manual-brand";
    brand.href = "index.html";
    brand.innerHTML = '<img class="brand-light" src="assets/logos/touying-ambrosia.svg" alt="">'
      + '<img class="brand-dark" src="assets/logos/touying-ambrosia-dark.svg" alt="">'
      + '<div><strong>Ambrosia</strong><span>A Presentation Guide</span></div>';
    sidebar.prepend(brand);
  }

  function imageZoom() {
    const dialog = document.createElement("dialog");
    dialog.className = "ambrosia-lightbox";
    dialog.setAttribute("aria-labelledby", "lightbox-title");
    dialog.innerHTML = '<div class="lightbox-toolbar"><strong id="lightbox-title">Preview</strong>'
      + '<button type="button" class="lightbox-size" aria-pressed="false">Actual Size</button>'
      + '<button type="button" class="lightbox-close" aria-label="Close image preview">Close ×</button></div>'
      + '<div class="lightbox-scroll"><img alt=""></div><p class="lightbox-caption"></p>';
    document.body.append(dialog);
    const fullImage = dialog.querySelector("img");
    const size = dialog.querySelector(".lightbox-size");
    let previousFocus;
    function open(image) {
      previousFocus = document.activeElement;
      dialog.classList.remove("actual-size");
      size.setAttribute("aria-pressed", "false");
      size.textContent = "Actual Size";
      fullImage.src = image.currentSrc || image.src;
      fullImage.alt = image.alt;
      dialog.querySelector(".lightbox-caption").textContent = image.alt;
      dialog.showModal();
    }
    size.addEventListener("click", () => {
      const actual = dialog.classList.toggle("actual-size");
      size.setAttribute("aria-pressed", String(actual));
      size.textContent = actual ? "Fit To Window" : "Actual Size";
    });
    dialog.querySelector(".lightbox-close").addEventListener("click", () => dialog.close());
    dialog.addEventListener("click", event => { if (event.target === dialog) dialog.close(); });
    dialog.addEventListener("close", () => { previousFocus?.focus(); });
    // Keep mdBook's search and chapter hotkeys out of an open modal.
    // Escape closes explicitly before other document listeners can cancel it.
    dialog.addEventListener("keydown", event => {
      if (event.key === "Escape") { event.preventDefault(); dialog.close(); }
      event.stopPropagation();
    });
    document.querySelectorAll("main img:not(.hero-mark-light):not(.hero-mark-dark)").forEach(image => {
      image.dataset.zoomable = "true";
      const link = image.closest("a");
      const label = image.closest("label");
      const trigger = link || label || image;
      if (!link) {
        trigger.tabIndex = 0;
        trigger.setAttribute("role", "button");
      }
      trigger.setAttribute("aria-label", "Enlarge: " + image.alt);
      trigger.setAttribute("aria-haspopup", "dialog");
      trigger.addEventListener("click", event => { event.preventDefault(); open(image); });
      trigger.addEventListener("keydown", event => {
        if (event.key === "Enter" || event.key === " ") { event.preventDefault(); open(image); }
      });
    });
    document.querySelectorAll(".example-zoom").forEach(button => {
      button.setAttribute("aria-haspopup", "dialog");
      button.addEventListener("click", () => open(button.closest("figure").querySelector("img")));
    });
  }

  function setup() { highlightTypst(); brandSidebar(); imageZoom(); }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setup, { once: true });
  } else {
    setup();
  }
})();
