(local {: cat/} (require :fs))

(λ not-found-page-gen [{: et : paths}]
  [(et:page-from-templ "404"
                       {:title "Page Not Found :("
                        :disable-sidebar true
                        :dst-path (cat/ paths.output "not_found.html")}
                       {})])

{: not-found-page-gen}
