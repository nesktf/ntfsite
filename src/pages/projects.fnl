(local {: cat-path} (require :fs))
(local {: truncate-list} (require :util))

(λ top-entries [self ?limit]
  (let [entries [{:url "thing.com" :name "test-proj"}]]
    (if (not= ?limit nil)
        (truncate-list entries ?limit)
        entries)))

(λ gen-project-tree [_self {: et : paths}]
  [(et:page-from-templ "projects"
                       {:title "my projects"
                        :dst-path (cat-path paths.output "projects/index.html")}
                       {})])

{:name "projects" :gen-tree gen-project-tree : top-entries}
