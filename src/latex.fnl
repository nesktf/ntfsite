(local {: cat/
        : filetype
        : write-file
        : read-file
        : make-dir
        : file-exists?
        : delete-file} (require :fs))

(λ compile-tex [paths equation inline?]
  "Compile a LaTeX equation that might be inline. Uses `paths.cache` as cache directory.
Returns a table with the tex equation and the source for an svg file with the rendered equation."
  (local tex-content-templ "
    \\documentclass[border=5pt]{standalone}
    \\usepackage{amsmath}
    \\usepackage{amssymb}
    \\usepackage[T1]{fontenc}
    \\usepackage{xcolor} 
    \\begin{document}
    \\color{white}
    \\begin{equation*}
    \\displaystyle
    %s
    \\end{equation*}
    \\end{document}")
  (local tex-cmd-templ
         "pdflatex -interaction=batchmode -output-directory=\"%s\" \"%s\" >/dev/null 2>&1")
  (local svg-cmd-templ "pdf2svg \"%s\" \"%s\"")
  (let [tex-dir (cat/ paths.cache "tex_temp")
        tex-file (cat/ tex-dir "eq.tex")
        tex-pdf (cat/ tex-dir "eq.pdf")
        tex-svg (cat/ tex-dir "eq.svg")
        post-equation (if (not inline?)
                          (.. "\\displaystyle " equation)
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

(λ tex-md-inject [{: content : files : paths}]
  "Replaces LaTeX equations in the format `$$<eq>$$` or `$<eq>$` inside a markdown page context.
Renders each found equation as an SVG, appends them to the context files and replaces the original
equation text with an <img> tag, wrapped around a <div> if its a block equation (`$$<eq>$$`).
Returns a string with the new markdown content"
  (var eq-id 1)

  (fn make-tag [inline? src alt title]
    (if inline?
        ;; No title in inline blocks
        (string.format "<img class=\"tex-image-inline\"
                             src=\"%%%%DIR%%%%/%s\"
                             alt=\"%s\" />" src alt)
        (string.format "<div class=\"tex-image-cont\">
                          <img class=\"tex-image-block\"
                               src=\"%%%%DIR%%%%/%s\"
                               alt=\"%s\"
                               title=\"%s\" />
                        </div>" src alt title)))

  (fn replace-eq [matched inline?]
    (let [{: equation : image} (compile-tex paths matched inline?)
          image-file (string.format "eq_%d.svg" eq-id)
          img-tag (make-tag inline? image-file equation
                            (string.format "Equation %d" eq-id))]
      (table.insert files {:type filetype.file-write
                           :content image
                           :dst image-file})
      (set eq-id (+ eq-id 1))
      img-tag))

  ;; Replace equation blocks ($$ $$) and then inline equations ($ $)
  (let [first-replace (content:gsub "%$%$(.-)%$%$" #(replace-eq $1 false))]
    (first-replace:gsub "%$(.-)%$" #(replace-eq $1 true))))

{: compile-tex : tex-md-inject}
