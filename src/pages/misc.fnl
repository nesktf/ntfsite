(local {: cat/} (require :fs))

(λ gen-about-tree [_self {: et : paths}]
  [(et:page-from-templ "pages"
                       {:title "Other pages"
                        :dst-path (cat/ paths.output "pages/index.html")}
                       {})])

{:name "misc" :gen-tree gen-about-tree}
