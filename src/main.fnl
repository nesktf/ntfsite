(local inspect (require :inspect))
(local {: write-file : copy-file : filetype : split-dir-file : make-dir}
       (require :fs))

(local {: et-load} (require :compiler))
(local {: load-pages} (require :pages))

(fn on-die [msg]
  (print (string.format "ERROR: %s" msg))
  (os.exit 1))

(fn parse-paths []
  (let [paths {:templ (. arg 1)
               :src (. arg 2)
               :output (. arg 3)
               :data (. arg 4)}]
    (each [name path (pairs paths)]
      (when (not path)
        (on-die (string.format "Path '%s' missing" name)))
      (print (string.format "- Using path '%s' for %s directory" path name)))
    paths))

(fn handle-write-content [et page comp-date]
  (let [content (et:inject "layout"
                           {:content page.content
                            :comp_date comp-date
                            :title page.title})
        (dir _file) (split-dir-file page.dst-path)]
    (make-dir dir)
    (write-file page.dst-path content)))

(fn handle-copy-file [page]
  (copy-file page.src-path page.dst-path))

(fn write-page-files! [et page comp-date]
  (if (= page.type filetype.page)
      (handle-write-content et page comp-date)
      (handle-copy-file page)))

(let [paths (parse-paths)
      comp-date (os.date "%Y/%m/%d @ %H:%M (GMT-3)")
      et-ctx (et-load paths)
      pages (load-pages et-ctx paths)]
  (each [_i page (ipairs pages)]
    (write-page-files! et-ctx page comp-date))
  (print (string.format "- Page compiled at %s " comp-date)))
