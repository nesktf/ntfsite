(local {: find-md-entries : compile-md-entries} (require :markdown))
(local {: truncate-list : epoch-to-str} (require :util))
(local {: cat/ : filetype} (require :fs))

(λ ext-blog-links [entries]
  ;; From newest to oldest
  (table.sort entries (fn [entry-a entry-b]
                        (let [date-a (tonumber entry-a.date)
                              date-b (tonumber entry-b.date)]
                          (> date-a date-b))))
  (icollect [_i entry (ipairs entries)]
    {:name entry.name :url (cat/ "/blog" entry.id) :date entry.date}))

(λ content-post-process [blog-path {:content entry-content :id entry-id}]
  (let [entry-path (cat/ blog-path entry-id)]
    (entry-content:gsub "%%%%DIR%%%%" (.. "/" entry-path))))

(λ inject-blog-entry [et blog-path entry]
  (let [md_content (content-post-process blog-path entry)
        pub_date (epoch-to-str entry.date)]
    (et:inject "markdown-entry" {: md_content : pub_date})))

(λ gen-blog-tree [self {: et : paths}]
  (let [output-dir (cat/ paths.output self.name)
        data-root (cat/ paths.data self.name)
        entries (find-md-entries data-root)
        parsed-entries (compile-md-entries entries)
        tree [(et:page-from-templ "blog"
                                  {:title "Blog Entries"
                                   :dst-path (cat/ paths.output self.name
                                                   "index.html")}
                                  {:epoch_to_str epoch-to-str
                                   :blog_links (ext-blog-links entries)})]]
    (each [_i entry (ipairs parsed-entries)]
      (table.insert tree
                    {:title entry.name
                     :type filetype.page
                     :content (inject-blog-entry et self.name entry)
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
