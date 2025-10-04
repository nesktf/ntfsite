(local lunamark (require :lunamark))
(local {: read-file
        : list-dir
        : cat-path
        : split-ext
        : file-exists?
        : filetype} (require :fs))

(local index-page {:name "index"
                   :gen-tree (fn [_self {: et : paths}]
                               [(et:page-from-templ "index"
                                                    {:title "nesktf's page"
                                                     :dst-path (cat-path paths.output
                                                                         "index.html")}
                                                    {})])})

(λ find-blog-paths [blog-data-path]
  (let [files (list-dir blog-data-path)]
    (icollect [_i file (ipairs files)]
      {:name file :path (cat-path blog-data-path file)})))

(λ split-blog-files [entry output-dir]
  (let [is-md-file? (fn [path]
                      (let [(_name ext) (split-ext path)]
                        (= ext "md")))
        files (list-dir entry.path)
        md-file (cat-path entry.path "index.md")
        other-files (icollect [_i file (ipairs files)]
                      (if (not (is-md-file? file))
                          {:src-path (cat-path entry.path file)
                           :dst-path (cat-path output-dir entry.name file)}
                          nil))]
    (assert (file-exists? md-file)
            (string.format "No markdown file in blog entry \"%s\"" entry.name))
    {:name entry.name : md-file : other-files}))

(λ compile-markdown [et parser md-file]
  (let [file-content (read-file md-file)
        parsed (parser file-content)]
    (et:inject "blog-page" {:md_content parsed})))

(fn gen-blog-tree [self {: et : paths}]
  (let [src-path (cat-path paths.data self.name)
        entries (find-blog-paths src-path)
        entries-files (icollect [_i entry (ipairs entries)]
                        (split-blog-files entry
                                          (cat-path paths.output self.name)))
        luna-writer (lunamark.writer.html.new {})
        luna-parser (lunamark.reader.markdown.new luna-writer {})
        tree []]
    (each [_i entry (ipairs entries-files)]
      (table.insert tree
                    {:title entry.name
                     :type filetype.page
                     :content (compile-markdown et luna-parser entry.md-file)
                     :dst-path (cat-path paths.output self.name entry.name
                                         "index.html")})
      (each [_j file (ipairs entry.other-files)]
        (table.insert tree {:type filetype.file
                            :src-path file.src-path
                            :dst-path file.dst-path})))
    tree))

(local blog-page {:name "blog" :gen-tree gen-blog-tree})

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
