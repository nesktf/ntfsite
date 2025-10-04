(local lfs (require :lfs))
(local filetype {:page 1 :file 2})

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

(λ split-ext [filename]
  (filename:match "^(.+)%.(.+)$"))

(λ copy-file [from to]
  (case-try (io.open from "rb")
    from-file (values (io.open to "w") from-file)
    (to-file from-file) (let [content (from-file:read "*all")]
                          (to-file:write content)
                          (to-file:close)
                          (from-file:close)
                          content)
    (catch (nil err) (values nil err) (nil err file)
           (do
             (file:close)
             (values nil err)))))

(λ make-dir [path]
  ;; Dirty hack
  (os.execute (string.format "mkdir -p \"%s\"" path))
  path)

(λ split-dir-file [path-with-file]
  (let [(dir file) (path-with-file:match "^(.+)%/(.+)$")]
    (values (.. dir "/") file)))

{: read-file
 : write-file
 : list-dir
 : file-exists?
 : cat-path
 : split-ext
 : filetype
 : copy-file
 : make-dir
 : split-dir-file}
