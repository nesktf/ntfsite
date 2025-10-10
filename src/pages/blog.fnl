(local inspect (require :inspect))
(local {: truncate-list : epoch-to-str} (require :util))
(local {: cat/ : filetype} (require :fs))
(local {: find-md-entries : compile-md-entries : compile-tex}
       (require :markdown))

(local blog-page {:route "blog"})

(λ ext-blog-links [entries]
  ;; From newest to oldest
  (table.sort entries (fn [entry-a entry-b]
                        (let [date-a (tonumber entry-a.date)
                              date-b (tonumber entry-b.date)]
                          (> date-a date-b))))
  (icollect [_i entry (ipairs entries)]
    {:name entry.name :url (cat/ "/blog" entry.id) :date entry.date}))

(λ pre-process-entry! [{: content : files : paths}]
  (var eq-id 0)

  (fn make-tag [inline? src title alt]
    (if inline?
        (string.format "<img class=\"tex-image-inline\"
                             src=\"%%%%DIR%%%%/%s\"
                             title=\"%s\"
                             alt=\"%s\" />" src title
                       alt)
        (string.format "<div class=\"tex-image-cont\">
                          <img class=\"tex-image-block\"
                               src=\"%%%%DIR%%%%/%s\"
                               title=\"%s\"
                               alt=\"%s\" />
                        </div>" src title alt)))

  (fn replace-eq [matched inline?]
    (let [{: equation : image} (compile-tex paths matched inline?)
          image-file (string.format "eq_%d.svg" eq-id)
          img-tag (make-tag inline? image-file equation
                            (string.format "eq_%d" eq-id))]
      (table.insert files {:type filetype.file-write
                           :content image
                           :dst image-file})
      (set eq-id (+ eq-id 1))
      img-tag))

  (local nc (content:gsub "%$%$(.-)%$%$" #(replace-eq $1 false)))
  (local nc2 (nc:gsub "%$(.-)%$" #(replace-eq $1 true)))
  nc2)

(λ blog-page-gen [{: et : paths}]
  (fn content-post-process [blog-path {:content entry-content :id entry-id}]
    (let [entry-path (cat/ blog-path entry-id)]
      (entry-content:gsub "%%%%DIR%%%%" (.. "/" entry-path))))

  (fn inject-blog-entry [et blog-path entry]
    (let [md_content (content-post-process blog-path entry)
          pub_date (epoch-to-str entry.date)]
      (et:inject "markdown-entry" {: md_content : pub_date})))

  (let [output-dir (cat/ paths.output blog-page.route)
        data-root (cat/ paths.data blog-page.route)
        entries (find-md-entries data-root)
        parsed-entries (compile-md-entries paths entries pre-process-entry!)
        tree [(et:page-from-templ "blog"
                                  {:title "Blog Entries"
                                   :dst-path (cat/ paths.output blog-page.route
                                                   "index.html")}
                                  {:epoch_to_str epoch-to-str
                                   :blog_links (ext-blog-links entries)})]]
    (each [_i entry (ipairs parsed-entries)]
      (table.insert tree
                    {:title entry.name
                     :type filetype.page
                     :content (inject-blog-entry et blog-page.route entry)
                     :dst-path (cat/ output-dir entry.id "index.html")})
      (each [_j file (ipairs entry.files)]
        (table.insert tree
                      {:type file.type
                       :content file.content
                       :src-path file.src
                       :dst-path (cat/ output-dir entry.id file.dst)})))
    tree))

(λ blog-top-entries [paths ?limit]
  (let [data-root (cat/ paths.data blog-page.route)
        entries (ext-blog-links (find-md-entries data-root))]
    (if (not= ?limit nil)
        (truncate-list entries ?limit)
        entries)))

{: blog-page-gen : blog-top-entries}
