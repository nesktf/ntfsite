(local {: read-file : cat-path : list-dir} (require :fs))
(local doc-title "nesktf's blog")

(λ find-blog-entries [data-path]
  (let [blog-data-path (cat-path data-path "blog")
        files (list-dir blog-data-path)]
    (icollect [_i file (ipairs files)]
      (cat-path blog-data-path file))))

(fn gen-doc [_templs _meta paths]
  (let [content (read-file (cat-path paths.src "blog.etlua"))]
    {:title doc-title :content {:index content}}))

(setmetatable {:name "blog"}
              {:__call (fn [_self ...]
                         (gen-doc ...))})
