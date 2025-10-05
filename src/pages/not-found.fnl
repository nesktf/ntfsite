(local {: cat-path} (require :fs))

(λ gen-404-tree [_self {: et : paths}]
  (let [pages [(et:page-from-templ "404"
                                   {:title "page not found"
                                    :disable-sidebar true
                                    :dst-path (cat-path paths.output "404.html")}
                                   {})]]
    pages))

{:name "404" :gen-tree gen-404-tree}
