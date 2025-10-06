(local lmrk (require :lunamark))
(local {: truncate-list} (require :util))
(local {: read-file
        : list-dir
        : cat-path
        : split-ext
        : filetype
        : split-dir-file} (require :fs))

(λ find-blog-paths [blog-data-path]
  (let [files (list-dir blog-data-path)]
    (icollect [_i file (ipairs files)]
      {:name file :path (cat-path blog-data-path file)})))

(fn is-md-file? [path]
  (let [(_name ext) (split-ext path)]
    (= ext "md")))

(fn entry-md-file [path entry-files]
  (. (icollect [_i file (ipairs entry-files)]
       (if (is-md-file? file)
           (cat-path path file)
           nil)) 1))

(λ split-blog-files [entry output-dir]
  (let [files (list-dir entry.path)
        md-file (. (icollect [_i file (ipairs files)]
                     (if (is-md-file? file)
                         (cat-path entry.path file)
                         nil)) 1)
        other-files (icollect [_i file (ipairs files)]
                      (if (not (is-md-file? file))
                          {:src-path (cat-path entry.path file)
                           :dst-path (cat-path output-dir entry.name file)}
                          nil))
        extract-title (fn [file]
                        (let [filename-dir (split-ext file)
                              (_dir filename) (filename-dir:match "^(.+)%/(.+)$")]
                          (filename:gsub "\\\\" "/")))]
    (assert md-file (string.format "No markdown file in blog entry \"%s\""
                                   entry.name))
    {:name entry.name :title (extract-title md-file) : md-file : other-files}))

(λ compile-markdown [et parser md-file]
  (let [file-content (read-file md-file)
        parsed (parser file-content)]
    (et:inject "blog-page" {:md_content parsed})))

(λ gen-blog-tree [self {: et : paths}]
  (let [src-path (cat-path paths.data self.name)
        entries (find-blog-paths src-path)
        entries-files (icollect [_i entry (ipairs entries)]
                        (split-blog-files entry
                                          (cat-path paths.output self.name)))
        luna-writer (lmrk.writer.html.new {})
        luna-parser (lmrk.reader.markdown.new luna-writer
                                              {:link_attributes true})
        blog-links (icollect [_i entry (ipairs entries-files)]
                     {:name entry.title
                      :url (.. "/" (cat-path self.name entry.name))})
        tree [(et:page-from-templ "blog"
                                  {:title "blog entries"
                                   :dst-path (cat-path paths.output self.name
                                                       "index.html")}
                                  {:blog_links blog-links})]]
    (each [_i entry (ipairs entries-files)]
      (table.insert tree
                    {:title entry.title
                     :type filetype.page
                     :content (compile-markdown et luna-parser entry.md-file)
                     :dst-path (cat-path paths.output self.name entry.name
                                         "index.html")})
      (each [_j file (ipairs entry.other-files)]
        (table.insert tree {:type filetype.file
                            :src-path file.src-path
                            :dst-path file.dst-path})))
    tree))

(λ top-entries [self paths ?limit]
  (let [entry-paths (find-blog-paths (cat-path paths.data self.name))
        entries (icollect [_i entry (ipairs entry-paths)]
                  (let [md-file (entry-md-file entry.path (list-dir entry.path))
                        (_dir file) (split-dir-file md-file)
                        (filename _ext) (split-ext file)
                        name (filename:gsub "\\\\" "/")
                        url (string.format "/%s/%s" self.name entry.name)]
                    {: url : name}))]
    (if (not= ?limit nil)
        (truncate-list entries ?limit)
        entries)))

{:name "blog" :gen-tree gen-blog-tree : top-entries}
