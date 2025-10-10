(local langs {0 {:lang-name "generic"
                 :parse-body (fn [body]
                               body)}})

(λ highlight-code-block [code-lang code-body]
  (let [{: lang-name : parse-body} (. langs
                                      (if (not= (. langs code-lang) nil)
                                          code-lang
                                          0))
        new-body (parse-body code-body)]
    (string.format "<code class=\"%s-code\">%s</code>" lang-name new-body)))

{: highlight-code-block}
