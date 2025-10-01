(local lmrk (require :lunamark))

(λ compile-markdown [md-src ?refs]
  (let [html-writer (lmrk.writer.html.new)
        md-parser (lmrk.reader.markdown.new html-writer
                                            {:smart true :references ?refs})
        (result meta) (md-parser md-src)]
    (values result meta)))

{: compile-markdown}
