(local eq-templ "
\\documentclass[border=5pt]{standalone}
\\usepackage{amsmath}
\\usepackage{amssymb}
\\begin{document}
$$%s$$
\\end{document}")

(fn fill-equation [eq-str]
  (string.format eq-templ eq-str))

(fn compile-tex [path]
  (os.execute "pdflatex -interaction=batchmode eq.tex")
  (os.execute (.. "convert -density 300 eq.pdf " path)))
