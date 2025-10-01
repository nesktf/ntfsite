(local lfs (require :lfs))

(λ read-file [path]
  (case (io.open path "r")
    file (let [content (file:read "*all")]
           (file:close)
           content)
    (nil err) (values nil err)))

(λ write-file [path content]
  (case (io.open path "w")
    file (file:write content)
    (nil err) (values nil err)))

(λ list-dir [dir-path]
  (let [files []]
    (each [file (lfs.dir dir-path)]
      (when (and (not= file ".") (not= file ".."))
        (table.insert files file)))
    files))

(λ file-exists? [path]
  (case (io.open path "r")
    file (do
           (file:close)
           true)
    (nil _err) false))

(fn cat-path [...]
  (let [dirs [...]]
    (table.concat dirs "/")))

{: read-file : write-file : list-dir : file-exists? : cat-path}
