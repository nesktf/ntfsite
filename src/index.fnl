(local {: read-file : cat-path} (require :fs))
(local doc-title "nesktf's page")

(fn gen-doc [{: et-compile : et-inject : paths}]
  (let [file-content (read-file (cat-path paths.src "index.etlua"))
        html-templ (et-compile file-content)
        html-content (et-inject html-templ file-content {})]
    {:title doc-title :tree {: html-content :path "index.html" :files []}}))

(setmetatable {:name "index"}
              {:__call (fn [_self ...]
                         (gen-doc ...))})
