(local {: cat/} (require :fs))

(λ gen-404-tree [_self {: et : paths}]
  (let [pages [(et:page-from-templ "404"
                                   {:title "Page Not Found :("
                                    :disable-sidebar true
                                    :dst-path (cat/ paths.output "404.html")}
                                   {})]]
    pages))

{:name "404" :gen-tree gen-404-tree}
