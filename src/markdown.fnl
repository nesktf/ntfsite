(local lmrk (require :lunamark))
(local {: read-file : list-dir : split-ext : is-dir? : cat/ : split-dir-file}
       (require :fs))

(λ is-md-file? [path]
  (let [(_name ext) (split-ext path)]
    (= ext "md")))

(λ escape-md-name [name]
  (name:gsub "\\\\" "/"))

(λ find-md-entries [root-path]
  (let [filter-md (fn [dir-list]
                    (icollect [_i {: dir-name : dir-path} (ipairs dir-list)]
                      (let [files (list-dir dir-path)
                            md-file (. (icollect [_j file (ipairs files)]
                                         (if (is-md-file? file)
                                             {:src (cat/ dir-path file)
                                              :dst (cat/ dir-name file)}
                                             nil))
                                       1)
                            (_ name-raw) (split-dir-file (split-ext md-file.dst))
                            cpy-files (icollect [_j file (ipairs files)]
                                        (if (not (is-md-file? file))
                                            {:src (cat/ dir-path file)
                                             :dst file}
                                            nil))
                            (date _) (dir-name:match "^%d+")
                            (dst _) (split-dir-file md-file.dst)]
                        {: md-file
                         : cpy-files
                         :name (escape-md-name name-raw)
                         :id (dst:gsub "/" "")
                         : date})))]
    (filter-md (icollect [_i dir-name (ipairs (list-dir root-path))]
                 (if (is-dir? (cat/ root-path dir-name))
                     {: dir-name :dir-path (cat/ root-path dir-name)}
                     nil)))))

(λ compile-md-entries [md-entries]
  (icollect [_i {: id : name : date : md-file : cpy-files} (ipairs md-entries)]
    (let [luna-writer (lmrk.writer.html.new {})
          luna-parser (lmrk.reader.markdown.new luna-writer
                                                {:link_attributes true})
          md-content (read-file md-file.src)]
      {: name : id : date :files cpy-files :content (luna-parser md-content)})))

{: find-md-entries : compile-md-entries}
