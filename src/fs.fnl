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
    file (do
           (file:write content)
           (file:close))
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

(fn cat/ [...]
  (let [dirs [...]]
    (table.concat dirs "/")))

(λ split-ext [filename]
  (filename:match "^(.+)%.(.+)$"))

(λ make-dir [path]
  ;; Dirty hack
  (os.execute (string.format "mkdir -p \"%s\"" path))
  path)

(λ split-dir-file [path-with-file]
  (let [(dir file) (path-with-file:match "^(.+)%/(.+)$")]
    (values (.. dir "/") file)))

(λ copy-file [from to]
  ;; Dirty hack again
  (let [(dir _name) (split-dir-file to)]
    (make-dir dir)
    (os.execute (string.format "cp \"%s\" \"%s\"" from to))))

(λ delete-file [path]
  ;; I love dirty hacks
  (os.execute (string.format "rm -rf \"%s\"" path)))

(λ is-dir? [path]
  (let [attr (lfs.attributes path)]
    (= attr.mode "directory")))

{: read-file
 : write-file
 : list-dir
 : file-exists?
 : cat/
 : split-ext
 : filetype
 : copy-file
 : make-dir
 : split-dir-file
 : delete-file
 : is-dir?}
