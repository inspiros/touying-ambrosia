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
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", highlightTypst, { once: true });
  } else {
    highlightTypst();
  }
})();
