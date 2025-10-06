(local {: find-md-entries : compile-md-entries} (require :markdown))
(local {: truncate-list} (require :util))
(local {: cat/ : filetype} (require :fs))

(λ ext-blog-links [entries]
  (icollect [_i entry (ipairs entries)]
    {:name entry.name :url (cat/ "/blog" entry.id)}))

(λ content-post-process [blog-path {:content entry-content :id entry-id}]
  (let [entry-path (cat/ blog-path entry-id)]
    (entry-content:gsub "%%%%DIR%%%%" (.. "/" entry-path))))

(λ gen-blog-tree [self {: et : paths}]
  (let [output-dir (cat/ paths.output self.name)
        data-root (cat/ paths.data self.name)
        entries (find-md-entries data-root)
        parsed-entries (compile-md-entries entries)
        tree [(et:page-from-templ "blog"
                                  {:title "Blog Entries"
                                   :dst-path (cat/ paths.output self.name
                                                   "index.html")}
                                  {:blog_links (ext-blog-links entries)})]]
    (each [_i entry (ipairs parsed-entries)]
      (table.insert tree
                    {:title entry.name
                     :type filetype.page
                     :content (et:inject "blog-page"
                                         {:md_content (content-post-process self.name
                                                                            entry)})
                     :dst-path (cat/ output-dir entry.id "index.html")})
      (each [_j file (ipairs entry.files)]
        (table.insert tree
                      {:type filetype.file
                       :src-path file.src
                       :dst-path (cat/ output-dir entry.id file.dst)})))
    tree))

(λ top-entries [self paths ?limit]
  (let [data-root (cat/ paths.data self.name)
        entries (ext-blog-links (find-md-entries data-root))]
    (if (not= ?limit nil)
        (truncate-list entries ?limit)
        entries)))

{:name "blog" :gen-tree gen-blog-tree : top-entries}
