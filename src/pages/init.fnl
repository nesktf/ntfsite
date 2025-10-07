(local {: cat/} (require :fs))
(local {: epoch-to-str} (require :util))
(local blog-page (require :pages.blog))
(local projects-page (require :pages.projects))
(local not-found-page (require :pages.not-found))
(local about-page (require :pages.about))
(local misc-page (require :pages.misc))

(λ gen-index-tree [_self {: et : paths}]
  [(et:page-from-templ "index"
                       {:title "nesktf's website"
                        :dst-path (cat/ paths.output "index.html")}
                       {:epoch_to_str epoch-to-str
                        :projects (projects-page:top-entries paths 5)
                        :blog_entries (blog-page:top-entries paths 5)})])

(local index-page {:name "index" :gen-tree gen-index-tree})

(λ append-page-tree! [main-tree page ctx]
  (let [page-tree (page:gen-tree ctx)]
    (each [_i tree-elem (ipairs page-tree)]
      (table.insert main-tree tree-elem))))

(λ load-pages [et paths]
  (let [pages [index-page
               blog-page
               about-page
               projects-page
               not-found-page
               misc-page]
        merged-tree []]
    (each [_i page (ipairs pages)]
      (print (string.format "- Compiling page tree for \"%s\"" page.name))
      (append-page-tree! merged-tree page {: et : paths}))
    merged-tree))

{: load-pages}
