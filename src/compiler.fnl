(local etlua (require :etlua))
(local {: list-dir : split-ext : read-file : cat-path : filetype} (require :fs))

(λ inject [self templ-name ?params]
  (assert (. self._templs templ-name)
          (string.format "No template named \"%s\" found" templ-name))
  (let [templ (. self._templs templ-name)]
    (templ ?params)))

(λ page-from-templ [self templ-name layout-params ?page-params]
  (let [content (self:inject templ-name ?page-params)]
    {:type filetype.page
     :title layout-params.title
     : content
     :dst-path layout-params.dst-path}))

(local et-mt {: inject : page-from-templ})

(λ et-load [paths]
  (let [et (setmetatable {} {:__index et-mt})
        templ-dir paths.templ
        files (list-dir templ-dir)
        templs {}]
    (each [_ filename (ipairs files)]
      (let [(name ext) (split-ext filename)]
        (when (= ext "etlua")
          (print (string.format "- Compiling template \"%s\"..." name))
          (set (. templs name)
               (etlua.compile (read-file (cat-path templ-dir filename)))))))
    (assert (. templs "layout") "No layout file in template folder")
    (set et._templs templs)
    et))

{: et-load}
