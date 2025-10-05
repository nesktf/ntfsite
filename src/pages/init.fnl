(local {: cat-path} (require :fs))
(local blog-page (require :pages.blog))
(local projects-page (require :pages.projects))

(λ gen-index-tree [_self {: et : paths}]
  [(et:page-from-templ "index"
                       {:title "nesktf's website"
                        :dst-path (cat-path paths.output "index.html")}
                       {:projects (projects-page:top-entries)
                        :blog_entries (blog-page:top-entries paths.data)})])

(local index-page {:name "index" :gen-tree gen-index-tree})

(λ gen-about-tree [_self {: et : paths}]
  [(et:page-from-templ "about"
                       {:title "about me"
                        :dst-path (cat-path paths.output "about/index.html")}
                       {})])

(local about-page {:name "about" :gen-tree gen-about-tree})

(λ append-page-tree! [main-tree page ctx]
  (let [page-tree (page:gen-tree ctx)]
    (each [_i tree-elem (ipairs page-tree)]
      (table.insert main-tree tree-elem))))

(λ load-pages [et paths]
  (let [pages [index-page blog-page about-page projects-page]
        merged-tree []]
    (each [_i page (ipairs pages)]
      (print (string.format "- Compiling page tree for \"%s\"" page.name))
      (append-page-tree! merged-tree page {: et : paths}))
    merged-tree))

{: load-pages}
