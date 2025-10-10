(local lmrk (require :lunamark))
(local {: write-file
        : make-dir
        : read-file
        : list-dir
        : split-ext
        : is-dir?
        : cat/
        : file-exists?
        : delete-file
        : split-dir-file} (require :fs))

(λ compile-tex [paths equation ?inline]
  (local tex-content-templ "
    \\documentclass[border=5pt]{standalone}
    \\usepackage{amsmath}
    \\usepackage{amssymb}
    \\usepackage[T1]{fontenc}
    \\begin{document}
    \\begin{equation*}
    \\displaystyle
    %s
    \\end{equation*}
    \\end{document}")
  (local tex-cmd-templ
         "pdflatex -interaction=batchmode -output-directory=\"%s\" \"%s\" &>/dev/null")
  (local svg-cmd-templ "pdf2svg \"%s\" \"%s\"")
  (let [tex-dir (cat/ paths.cache "tex_temp")
        tex-file (cat/ tex-dir "eq.tex")
        tex-pdf (cat/ tex-dir "eq.pdf")
        tex-svg (cat/ tex-dir "eq.svg")
        post-equation (if (not ?inline)
                          (.. "\\displaystyle" equation)
                          equation)
        tex-content (string.format tex-content-templ post-equation)
        tex-cmd (string.format tex-cmd-templ tex-dir tex-file)
        svg-cmd (string.format svg-cmd-templ tex-pdf tex-svg)]
    (make-dir tex-dir)
    (write-file tex-file tex-content)
    (os.execute tex-cmd)
    (assert (file-exists? tex-pdf) "Failed to compile tex equation")
    (os.execute svg-cmd)
    (assert (file-exists? tex-svg) "Failed to vectorize tex equation")
    (let [image (read-file tex-svg)]
      (delete-file tex-dir)
      {: equation : image})))

(λ find-md-entries [root-path]
  (fn escape-md-name [name]
    (name:gsub "\\\\" "/"))

  (fn is-md-file? [path]
    (let [(_name ext) (split-ext path)]
      (= ext "md")))

  (fn filter-md [dir-list]
    (icollect [_i {: dir-name : dir-path} (ipairs dir-list)]
      (let [files (list-dir dir-path)
            md-file (. (icollect [_j file (ipairs files)]
                         (if (is-md-file? file)
                             {:src (cat/ dir-path file)
                              :dst (cat/ dir-name file)}
                             nil)) 1)
            (_ name-raw) (split-dir-file (split-ext md-file.dst))
            cpy-files (icollect [_j file (ipairs files)]
                        (if (not (is-md-file? file))
                            {:src (cat/ dir-path file) :dst file}
                            nil))
            (date _) (dir-name:match "^%d+")
            (dst _) (split-dir-file md-file.dst)]
        {: md-file
         : cpy-files
         :name (escape-md-name name-raw)
         :id (dst:gsub "/" "")
         : date})))

  (filter-md (icollect [_i dir-name (ipairs (list-dir root-path))]
               (if (is-dir? (cat/ root-path dir-name))
                   {: dir-name :dir-path (cat/ root-path dir-name)}
                   nil))))

(λ compile-md-entries [md-entries]
  (icollect [_i {: id : name : date : md-file : cpy-files} (ipairs md-entries)]
    (let [luna-writer (lmrk.writer.html.new {})
          luna-parser (lmrk.reader.markdown.new luna-writer
                                                {:link_attributes true})
          md-content (read-file md-file.src)]
      {: name : id : date :files cpy-files :content (luna-parser md-content)})))

{: find-md-entries : compile-md-entries : compile-tex}
