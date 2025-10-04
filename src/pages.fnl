(local {: cat-path} (require :fs))
(local blog-page (require :blog-page))

(fn gen-index-tree [_self {: et : paths}]
  [(et:page-from-templ "index"
                       {:title "nesktf's page"
                        :dst-path (cat-path paths.output "index.html")}
                       {})])

(local index-page {:name "index" :gen-tree gen-index-tree})

(λ append-page-tree! [main-tree page ctx]
  (let [page-tree (page:gen-tree ctx)]
    (each [_i tree-elem (ipairs page-tree)]
      (table.insert main-tree tree-elem))))

(fn load-pages [et paths]
  (let [pages [index-page blog-page]
        merged-tree []]
    (each [_i page (ipairs pages)]
      (print (string.format "- Compiling page tree for \"%s\"" page.name))
      (append-page-tree! merged-tree page {: et : paths}))
    merged-tree))

{: load-pages}
