(local {: cat/} (require :fs))

(λ gen-about-tree [_self {: et : paths}]
  [(et:page-from-templ "about"
                       {:title "About Me"
                        :dst-path (cat/ paths.output "about/index.html")}
                       {})])

{:name "about" :gen-tree gen-about-tree}
