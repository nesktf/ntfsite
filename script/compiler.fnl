(local inspect (require :inspect))
(local fennel (require :fennel))
(local {: read-file : write-file : list-dir : file-exists?} (require :fs))
(local etlua (require :etlua))
(local paths {:templ (. arg 1) :src (. arg 2) :output (. arg 3)})

(fn on-die [msg]
  (print (string.format "ERROR: %s" msg))
  (os.exit 1))

(fn compile-etlua [templ-src]
  (etlua.compile templ-src))

(fn inject-etlua [templ params]
  (templ params))

(fn split-ext [filename]
  (filename:match "^(.+)%.(.+)$"))

(λ parse-src-file-tree [src-files]
  (let [file-tree {}
        filter-ext (fn [files ext]
                     (icollect [_ file (ipairs files)]
                       (if (file:find ext)
                           file
                           nil)))
        append-files (fn [file-list]
                       (each [_ filename (ipairs file-list)]
                         (let [(name ext) (split-ext filename)]
                           (when (not (. file-tree name))
                             (set (. file-tree name) {}))
                           (set (. file-tree name ext) filename))))
        et-files (filter-ext src-files ".etlua")
        meta-files (filter-ext src-files ".fnl")]
    (append-files et-files)
    (append-files meta-files)
    file-tree))

(λ parse-templs [templ-dir]
  (let [templs {}
        files (list-dir templ-dir)]
    (each [_ filename (ipairs files)]
      (let [(name ext) (split-ext filename)]
        (when (= ext "etlua")
          (set (. templs name)
               (compile-etlua (read-file (.. paths.templ "/" filename)))))))
    (if (not (. templs "layout"))
        (values nil "No layout file in template folder")
        templs)))

(fn setup-global-env! [templs]
  (set _G.from_templ (λ [templ-name params]
                       (let [templ-func (. templs templ-name)]
                         (assert templ-func
                                 (string.format "Invalid template '%s'"
                                                templ-name))
                         (templ-func params))))
  (set _G.comp_date "01/01/1970"))

(fn compile-files [src-path layout-templ]
  (let [html-out {}
        src-files (list-dir src-path)
        file-tree (parse-src-file-tree src-files)]
    (each [src-name {:etlua etlua-file :fnl fnl-file} (pairs file-tree)]
      (assert etlua-file (string.format "No etlua source for file '%s'"
                                        src-name))
      (assert fnl-file
              (string.format "No fennel source for file '%s'" src-name))
      (let [fnl-return (fennel.dofile (.. src-path "/" fnl-file))
            etlua-content (read-file (.. src-path "/" etlua-file))
            et-templ (compile-etlua etlua-content)
            layout-content (inject-etlua et-templ fnl-return)
            html-content (inject-etlua layout-templ
                                       {:meta {:comp_date _G.comp_date}
                                        :title fnl-return.title
                                        :content layout-content})]
        (set (. html-out src-name) html-content)))
    html-out))

(each [name path (pairs paths)]
  (when (not path)
    (on-die (string.format "Path '%s' missing" name)))
  (print (string.format "- Using path '%s' for %s directory" path name)))

(case-try (parse-templs paths.templ)
  templs (do
           (setup-global-env! templs)
           (pcall compile-files paths.src templs.layout))
  (true compiled-html) (each [name html-src (pairs compiled-html)]
                         (write-file (.. paths.output "/" name ".html")
                                     html-src)
                         (print name html-src))
  (catch (nil templ-error) (on-die templ-error) (_ compile-error)
         (on-die compile-error)))
